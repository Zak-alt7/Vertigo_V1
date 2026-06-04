using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using Vertigo.Data;
using Vertigo.Utils;
using Vertigo.Models; 

namespace Vertigo.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly VertigoContext _context;

        public AuthController(VertigoContext context)
        {
            _context = context;
        }

        // POST /api/auth/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest req)
        {
            if (string.IsNullOrWhiteSpace(req.Email) || string.IsNullOrWhiteSpace(req.Password))
                return BadRequest(new { message = "Email et mot de passe requis." });

            var user = await _context.Utilisateur
                .FirstOrDefaultAsync(u => u.Email == req.Email);

            if (user == null)
                return Unauthorized(new { message = "Email ou mot de passe incorrect." });

            if (user.BAN)
                return Unauthorized(new { message = "Compte suspendu." });

            var valid = SecurityHelper.VerifyPassword(req.Password, user.MotDePasse);
            if (!valid)
                return Unauthorized(new { message = "Email ou mot de passe incorrect." });

            // Créer le cookie de session
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, user.ID.ToString()),
                new Claim(ClaimTypes.Name,           user.Nom),
                new Claim(ClaimTypes.Email,          user.Email),
                new Claim(ClaimTypes.Role,           user.Role),
            };

            var identity  = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            var principal = new ClaimsPrincipal(identity);

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                principal,
                new AuthenticationProperties
                {
                    IsPersistent = true,
                    ExpiresUtc   = DateTimeOffset.UtcNow.AddDays(14)
                });

            return Ok(new
            {
                id    = user.ID,
                nom   = user.Nom,
                email = user.Email,
                role  = user.Role,
            });
        }

        // POST /api/auth/register
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest req)
        {
            // Vérifier si l'email existe déjà
            var existing = await _context.Utilisateur
                .FirstOrDefaultAsync(u => u.Email == req.Email);
            
            if (existing != null)
                return BadRequest(new { message = "Cet email est déjà utilisé." });

            // Créer le nouvel utilisateur
            var user = new Utilisateur
            {
                Nom = req.Nom,
                Email = req.Email,
                MotDePasse = SecurityHelper.HashPassword(req.Password),
                Telephone = req.Telephone ?? "",
                Role = "Client",
                DateInscription = DateTime.UtcNow,
                NBReport = 0,
                Report = new List<string>(),
                Etudiant = req.Etudiant ?? false,
                NumCarteEtu = req.NumCarteEtu,
                BAN = false,
                ProfilImagePath = "/images/default-profile.png"
            };

            _context.Utilisateur.Add(user);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                id = user.ID,
                nom = user.Nom,
                email = user.Email,
                role = user.Role,
                message = "Compte créé avec succès"
            });
        }

        // POST /api/auth/logout
        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return Ok(new { message = "Déconnecté." });
        }

        // GET /api/auth/me
        [HttpGet("me")]
        public async Task<IActionResult> Me()
        {
            var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (idStr == null) return Unauthorized();

            var user = await _context.Utilisateur
                .AsNoTracking()
                .FirstOrDefaultAsync(u => u.ID == int.Parse(idStr));

            if (user == null) return Unauthorized();

            return Ok(new
            {
                id    = user.ID,
                nom   = user.Nom,
                email = user.Email,
                role  = user.Role,
            });
        }
    }

    // Modèles (en dehors de la classe)
    public record LoginRequest(string Email, string Password);
    public record RegisterRequest(
        string Nom,
        string Email,
        string Password,
        string? Telephone,
        bool? Etudiant,
        string? NumCarteEtu
    );
}