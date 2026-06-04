using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using Vertigo.Data;
using Vertigo.Dtos;
using Vertigo.Models;
using Vertigo.Services;

namespace Vertigo.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MerchantsController : ControllerBase
    {
        private readonly VertigoContext _context;
        private readonly ILogger<MerchantsController> _logger;
        private readonly FileService _fileService;

        public MerchantsController(VertigoContext context, ILogger<MerchantsController> logger, FileService fileService)
        {
            _context = context;
            _logger = logger;
            _fileService = fileService;
        }
            // POST /api/merchants/apply — submit application to become a merchant
            [HttpPost("apply")]
        public async Task<ActionResult<MerchantApplicationDto>> Apply([FromBody] MerchantApplicationRequest req)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();
            var userDetail = await _context.Utilisateur.FindAsync(userId);
            if (userDetail.Role != "Client") return Unauthorized();
            if (userDetail.BAN) return Unauthorized();
            if (userDetail.Etudiant) return BadRequest( new {message = "Désolé, les comptes étudiants ne peuvent pas créer de boutique."});
            
            var existing = await _context.Boutique.FirstOrDefaultAsync(b => b.IdGerant == userId.Value);
            if (existing != null) return BadRequest(new { message = "You already have a pending or approved application." });

            var existingBoutique = await _context.Boutique
                            .Where(u => (u.NomBoutique == req.NomBoutique || u.Localisation == req.Localisation || u.Registre == req.Registre))
                            .Select(u => new { u.NomBoutique, u.Localisation, u.Registre })
                            .AsNoTracking()
                            .FirstOrDefaultAsync();

            if (existingBoutique != null)
            {
                var errors = new List<object>();

                if (existingBoutique.NomBoutique == req.NomBoutique)
                    errors.Add(new { field = "Nom", message = "Ce nom est déjà pris." }); 

                if (existingBoutique.Localisation == req.Localisation)
                    errors.Add(new { field = "Localisation", message = "Cet Localisation est déjà utilisé." });

                if (existingBoutique.Registre == req.Registre)
                    errors.Add(new { field = "Registre", message = "Ce Registre est déjà lié à une." });

                return BadRequest(new { errors });
            }

            var boutique = new Boutique
            {
                NomBoutique = req.NomBoutique,
                Ville = req.Ville,
                Description = req.Description,
                Localisation = req.Localisation,
                Registre = req.Registre,
                IdGerant = userId.Value,
                Latitude = req.Latitude,
                Longitude = req.Longitude,
                CuisineType = req.CuisineType,
                PhoneNumber = req.PhoneNumber,
                BoutiqueImagePath = req.BoutiqueImagePath ?? string.Empty,
                Valide = false,
                BAN = false,
                NBvente = 0,
                NBReport = 0,
                Report = new List<string>(),
                DateCreation = DateTime.UtcNow,
                Note = new Evaluation { NbNote = 0, Note = 0 }
            };

            _context.Boutique.Add(boutique);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Utilisateur {UserId} a déposé un dossier pour la boutique {Nom}", userId, req.NomBoutique);

            return Ok(await BuildDto(boutique.IDBoutique));
        }

        // GET /api/merchants/mine — current user's boutique (any status)
        [HttpGet("mine")]
        public async Task<ActionResult<MerchantApplicationDto?>> Mine()
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            var b = await _context.Boutique
                .Include(x => x.Gerant)
                .FirstOrDefaultAsync(x => x.IdGerant == userId.Value);

            if (b == null) return Ok(null);
            return Ok(ToDto(b));
        }

        // GET /api/merchants/pending — admin: list pending (unvalidated) applications
        [HttpGet("pending")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<IEnumerable<MerchantApplicationDto>>> Pending()
        {
            var list = await _context.Boutique
                .Include(b => b.Gerant)
                .Where(b => !b.Valide && !b.BAN)
                .OrderBy(b => b.DateCreation)
                .ToListAsync();
            return Ok(list.Select(ToDto));
        }

        // POST /api/merchants/{id}/approve — admin: approve application
        [HttpPost("{id:int}/approve")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Approve(int id)
        {
            var b = await _context.Boutique
                .Include(x => x.Gerant)
                .FirstOrDefaultAsync(x => x.IDBoutique == id);
            if (b == null) return NotFound();
            if (b.Valide) return BadRequest(new { message = "Already approved." });

            b.Valide = true;
            if (b.Gerant != null && b.Gerant.Role != Roles.Admin) b.Gerant.Role = Roles.Gerant;

            await _context.SaveChangesAsync();
            var adminId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            _logger.LogInformation("L'administrateur {AdminId} a approuvé la boutique {BoutiqueId}", adminId, id);

            return Ok(new { message = "Application approved." });
        }

        // POST /api/merchants/{id}/reject — admin: reject and delete the application
        [HttpPost("{id:int}/reject")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> Reject(int id)
        {
            var b = await _context.Boutique.FirstOrDefaultAsync(x => x.IDBoutique == id);
            if (b == null) return NotFound();
            if (b.Valide) return BadRequest(new { message = "Can't reject an approved merchant." });
            
            _fileService.DeleteFile(b.BoutiqueImagePath);
            _context.Boutique.Remove(b);
            
            await _context.SaveChangesAsync();
            var adminId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            _logger.LogWarning("L'administrateur {AdminId} a rejete la boutique {BoutiqueId}", adminId, id);

            return Ok(new { message = "Application rejected." });
        }

        private int? GetUserId()
        {
            var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(idStr, out var id) ? id : (int?)null;
        }

        private async Task<MerchantApplicationDto> BuildDto(int id)
        {
            var b = await _context.Boutique.Include(x => x.Gerant).FirstAsync(x => x.IDBoutique == id);
            return ToDto(b);
        }

        private static MerchantApplicationDto ToDto(Boutique b) => new MerchantApplicationDto
        {
            Id = b.IDBoutique,
            NomBoutique = b.NomBoutique,
            Ville = b.Ville,
            Description = b.Description,
            Localisation = b.Localisation,
            Registre = b.Registre,
            CuisineType = b.CuisineType,
            PhoneNumber = b.PhoneNumber,
            Latitude = b.Latitude,
            Longitude = b.Longitude,
            BoutiqueImagePath = b.BoutiqueImagePath,
            Valide = b.Valide,
            DateCreation = b.DateCreation,
            IdGerant = b.IdGerant,
            GerantNom = b.Gerant?.Nom ?? string.Empty,
            GerantEmail = b.Gerant?.Email ?? string.Empty
        };
    }
}
