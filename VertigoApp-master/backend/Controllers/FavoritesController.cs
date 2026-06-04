using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using Vertigo.Data;
using Vertigo.Models;

namespace Vertigo.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class FavoritesController : ControllerBase
    {
        private readonly VertigoContext _context;

        public FavoritesController(VertigoContext context)
        {
            _context = context;
        }

        private int? GetUserId()
        {
            var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(idStr, out var id) ? id : (int?)null;
        }

        // GET /api/favorites
        [HttpGet]
        public async Task<ActionResult<List<int>>> GetFavorites()
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            var favorites = await _context.Favoris
                .Where(f => f.UtilisateurId == userId)
                .Select(f => f.PanierId)
                .ToListAsync();

            return Ok(favorites);
        }

        // POST /api/favorites
        [HttpPost]
        public async Task<IActionResult> AddFavorite([FromBody] int panierId)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            var existing = await _context.Favoris
                .FirstOrDefaultAsync(f => f.UtilisateurId == userId && f.PanierId == panierId);

            if (existing != null) return Ok(new { message = "Deja en favori" });

            var favori = new Favori
            {
                UtilisateurId = userId.Value,
                PanierId = panierId,
                DateAjout = DateTime.UtcNow
            };

            _context.Favoris.Add(favori);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Ajoute aux favoris" });
        }

        // DELETE /api/favorites/{panierId}
        [HttpDelete("{panierId:int}")]
        public async Task<IActionResult> RemoveFavorite(int panierId)
        {
            var userId = GetUserId();
            if (userId == null) return Unauthorized();

            var favori = await _context.Favoris
                .FirstOrDefaultAsync(f => f.UtilisateurId == userId && f.PanierId == panierId);

            if (favori == null) return NotFound(new { message = "Favori non trouve" });

            _context.Favoris.Remove(favori);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Retire des favoris" });
        }
    }
}