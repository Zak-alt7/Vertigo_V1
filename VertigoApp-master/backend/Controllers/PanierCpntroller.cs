using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Vertigo.Data;

namespace Vertigo.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PaniersController : ControllerBase
    {
        private readonly VertigoContext _context;
        public PaniersController(VertigoContext context) => _context = context;

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var paniers = await _context.Panier
                .Include(p => p.Boutique)
                .Where(p => p.IsActive && p.NBdispo > 0)
                .ToListAsync();
            return Ok(paniers);
        }
    }
}