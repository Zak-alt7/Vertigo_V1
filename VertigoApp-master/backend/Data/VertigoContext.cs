using Microsoft.EntityFrameworkCore;
using Vertigo.Models;

namespace Vertigo.Data
{
    public class VertigoContext : DbContext
    {
        public VertigoContext(DbContextOptions<VertigoContext> options)
            : base(options) { }

        public DbSet<Utilisateur> Utilisateur { get; set; }
        public DbSet<Boutique> Boutique { get; set; }
        public DbSet<Commande> Commande { get; set; }
        public DbSet<Panier> Panier { get; set; }
        public DbSet<Favori> Favoris { get; set; }
        public DbSet<RecurringSubscription> Subscriptions => Set<RecurringSubscription>();
        public DbSet<ReservationAttempt> Attempts => Set<ReservationAttempt>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // ── Commande ──────────────────────────────────────────────────────
            modelBuilder.Entity<Commande>()
                .HasOne(c => c.Client)
                .WithMany()
                .HasForeignKey(c => c.ClientID)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Commande>()
                .HasOne(c => c.Panier)
                .WithMany()
                .HasForeignKey(c => c.PanierID)
                .OnDelete(DeleteBehavior.NoAction);

            // ── RecurringSubscription ─────────────────────────────────────────
            modelBuilder.Entity<RecurringSubscription>()
                .HasOne(s => s.Boutique)
                .WithMany()
                .HasForeignKey(s => s.BoutiqueId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<RecurringSubscription>()
                .HasOne(s => s.Utilisateur)
                .WithMany()
                .HasForeignKey(s => s.UtilisateurId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<RecurringSubscription>()
                .Property(s => s.Status)
                .HasConversion<string>();

            modelBuilder.Entity<RecurringSubscription>()
                .Property(s => s.TargetDay)
                .HasConversion<int>();

            // ── Favori ────────────────────────────────────────────────────────
            modelBuilder.Entity<Favori>(entity =>
            {
                entity.HasKey(f => f.Id);

                entity.HasIndex(f => new { f.UtilisateurId, f.PanierId }).IsUnique();

                entity.HasOne(f => f.Utilisateur)
                    .WithMany()
                    .HasForeignKey(f => f.UtilisateurId)
                    .OnDelete(DeleteBehavior.NoAction);

                entity.HasOne(f => f.Panier)
                    .WithMany()
                    .HasForeignKey(f => f.PanierId)
                    .OnDelete(DeleteBehavior.NoAction);
            });
        }
    }
}