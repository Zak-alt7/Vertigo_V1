using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Vertigo.Models
{
    public class Favori
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int UtilisateurId { get; set; }

        [Required]
        public int PanierId { get; set; }

        [Required]
        public DateTime DateAjout { get; set; } = DateTime.UtcNow;

        // Navigation (sans cascade, configurée dans OnModelCreating)
        [ForeignKey("UtilisateurId")]
        public virtual Utilisateur? Utilisateur { get; set; }

        [ForeignKey("PanierId")]
        public virtual Panier? Panier { get; set; }
    }
}