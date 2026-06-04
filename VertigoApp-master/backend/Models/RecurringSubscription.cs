namespace Vertigo.Models
{
    public class RecurringSubscription
    {
        public int Id { get; set; }
        public int UtilisateurId { get; set; }
        public int BoutiqueId { get; set; }
        public DayOfWeek TargetDay { get; set; }
        public TimeSpan TargetTime { get; set; }
        public SubscriptionStatus Status { get; set; } = SubscriptionStatus.Active;
        public int FailureCount { get; set; } = 0;
        public int MaxFailures { get; set; } = 3;
        public DateTime? LastAttemptAt { get; set; }
        public DateTime? LastSuccessAt { get; set; }
        public string? LastFailureReason { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? CancelledAt { get; set; }

        // Navigation
        public virtual Boutique? Boutique { get; set; }
        public virtual Utilisateur? Utilisateur { get; set; }
    }
    public enum SubscriptionStatus
    {
        Active = 0,
        Processing = 1,
        Reserved = 2,
        Failed = 3,
        Suspended = 4,
        Cancelled = 5
    }

    public class ReservationAttempt
    {
        public int Id { get; set; } 
        public int SubscriptionId { get; set; }
        public DateTime AttemptedAt { get; set; } = DateTime.UtcNow;
        public bool Success { get; set; }
        public string? FailureReason { get; set; }
        public Guid? ReservedOfferId { get; set; }
        public int AttemptNumber { get; set; }
        public decimal? OriginalPrice { get; set; }
        public decimal? DiscountedPrice { get; set; }
        public int? AppliedDiscountPercentage { get; set; }
    }
}
