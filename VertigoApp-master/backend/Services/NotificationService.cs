namespace Vertigo.Services
{
    public class VertigoApiClient : IVertigoApiClient
    {
        public Task<VertigoBasket?> GetAvailableBasketAsync(int boutiqueId, CancellationToken ct)
        {
            var basket = new VertigoBasket
            {
                Id = Guid.NewGuid(),
                BoutiqueId = boutiqueId,
                IsAvailable = true,
                OriginalPrice = 15.00m,
                DiscountedPrice = 5.00m,
                PickupTime = DateTime.UtcNow.AddHours(3)
            };
            return Task.FromResult<VertigoBasket?>(basket);
        }
    }

    public class NotificationService : INotificationService
    {
        private readonly ILogger<NotificationService> _logger;

        public NotificationService(ILogger<NotificationService> logger)
        {
            _logger = logger;
        }

        public Task SendAsync(int utilisateurId, string title, string message)
        {
            _logger.LogInformation("[NOTIF] User={UserId} | {Title} | {Message}",
                utilisateurId, title, message);
            return Task.CompletedTask;
        }
    }
}