using Microsoft.EntityFrameworkCore;
using Vertigo.Data;
using Vertigo.Models;

namespace Vertigo.Services
{
    public class Service
    {
        private readonly VertigoContext _db;
        private readonly IVertigoApiClient _vertigoApi;
        private readonly INotificationService _notificationService;
        private readonly ILogger<Service> _logger;

        public Service(
            VertigoContext db,
            IVertigoApiClient vertigoApi,
            INotificationService notificationService,
            ILogger<Service> logger)
        {
            _db = db;
            _vertigoApi = vertigoApi;
            _notificationService = notificationService;
            _logger = logger;
        }

        public async Task ProcessSubscriptionAsync(
            RecurringSubscription subscription, CancellationToken ct)
        {
            // Version temporaire qui compile
            _logger.LogInformation("Processing subscription {Id}", subscription.Id);
            await Task.CompletedTask;
        }

        private async Task HandleFailureAsync(
            RecurringSubscription subscription,
            string reason,
            int attemptNumber,
            DateTime today,
            CancellationToken ct)
        {
            await Task.CompletedTask;
        }
    }

    public class VertigoBasket
    {
        public Guid Id { get; set; }
        public int BoutiqueId { get; set; }
        public bool IsAvailable { get; set; }
        public decimal OriginalPrice { get; set; }
        public decimal DiscountedPrice { get; set; }
        public DateTime PickupTime { get; set; }
    }

    public interface IVertigoApiClient
    {
        Task<VertigoBasket?> GetAvailableBasketAsync(int boutiqueId, CancellationToken ct);
    }

    public interface INotificationService
    {
        Task SendAsync(int utilisateurId, string title, string message);
    }
}