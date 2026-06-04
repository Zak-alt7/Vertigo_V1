using Microsoft.EntityFrameworkCore;
using Vertigo.Data;
using Vertigo.Models;
using Vertigo.Services;

namespace Vertigo.BackgroundServices
{
    public class SubscriptionWorker : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<SubscriptionWorker> _logger;
        private static readonly TimeSpan Interval = TimeSpan.FromMinutes(15);

        public SubscriptionWorker(
            IServiceScopeFactory scopeFactory,
            ILogger<SubscriptionWorker> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("SubscriptionWorker started");

            using var timer = new PeriodicTimer(Interval);

            while (await timer.WaitForNextTickAsync(stoppingToken))
            {
                try
                {
                    await ProcessDueSubscriptionsAsync(stoppingToken);
                }
                catch (Exception ex) when (ex is not OperationCanceledException)
                {
                    _logger.LogError(ex, "Unhandled error in worker");
                }
            }
        }

        private async Task ProcessDueSubscriptionsAsync(CancellationToken ct)
        {
            await using var scope = _scopeFactory.CreateAsyncScope();
            var db = scope.ServiceProvider.GetRequiredService<VertigoContext>();
            var reservationService = scope.ServiceProvider.GetRequiredService<Service>();

            var now = DateTime.UtcNow;
            var franceTime = now.AddHours(2);
            var currentDay = franceTime.DayOfWeek;
            var currentTime = franceTime.TimeOfDay;

            // Hors créneaux Vertigo (avant 18h)
            if (currentTime.Hours < 18)
            {
                return;
            }

            // Abonnements éligibles
            var dueSubscriptions = await db.Subscriptions
                .Where(s => s.Status == SubscriptionStatus.Active || s.Status == SubscriptionStatus.Failed)
                .Where(s => s.TargetDay == currentDay)
                .Where(s => s.TargetTime <= currentTime)  // L'heure cible est passée ou maintenant
                .Where(s => currentTime <= s.TargetTime.Add(TimeSpan.FromMinutes(45))) // Tolérance 45 min
                .Where(s => s.LastAttemptAt == null || s.LastAttemptAt.Value.Date != franceTime.Date) // Une tentative par jour
                .Where(s => s.FailureCount < s.MaxFailures)
                .Include(s => s.Boutique)
                .Include(s => s.Utilisateur)
                .ToListAsync(ct);

            if (!dueSubscriptions.Any())
                return;

            _logger.LogInformation("Processing {Count} due subscriptions at {Time}", dueSubscriptions.Count, franceTime.ToString("HH:mm"));

            var semaphore = new SemaphoreSlim(5);
            var tasks = dueSubscriptions.Select(async sub =>
            {
                await semaphore.WaitAsync(ct);
                try
                {
                    await reservationService.ProcessSubscriptionAsync(sub, ct);
                }
                finally
                {
                    semaphore.Release();
                }
            });

            await Task.WhenAll(tasks);
        }
    }
}