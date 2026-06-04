using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using Vertigo.Data;
using Vertigo.Models;
using Vertigo.Services;

var builder = WebApplication.CreateBuilder(args);

// ── Services ──────────────────────────────────────────────────────────────────
builder.Services.AddControllersWithViews();
builder.Services.AddControllers();
builder.Services.AddOpenApi();
builder.Services.AddScoped<FileService>();
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/Login";
        options.ExpireTimeSpan = TimeSpan.FromDays(14);
        options.SlidingExpiration = true;

        options.Events = new CookieAuthenticationEvents
        { 
            OnValidatePrincipal = async context =>
            {
                var userIdClaim = context.Principal.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim == null) return;

                var dbContext = context.HttpContext.RequestServices.GetRequiredService<VertigoContext>();

                var user = await dbContext.Utilisateur 
                    .AsNoTracking()
                    .FirstOrDefaultAsync(u => u.ID == int.Parse(userIdClaim.Value));

                if (user == null)
                {
                    context.RejectPrincipal(); // L'utilisateur n'existe plus
                    return;
                }

                // Est-ce que le rôle en base est différent du rôle dans le cookie ?
                var currentRoleClaim = context.Principal.FindFirst(ClaimTypes.Role);
                if (currentRoleClaim == null || currentRoleClaim.Value != user.Role)
                {
                    // MISE À JOUR SILENCIEUSE DU COOKIE
                    var identity = (ClaimsIdentity)context.Principal.Identity;

                    // On remplace le claim de rôle
                    if (currentRoleClaim != null) identity.RemoveClaim(currentRoleClaim);
                    identity.AddClaim(new Claim(ClaimTypes.Role, user.Role));

                    // Cette ligne dit à ASP.NET de renvoyer le cookie mis à jour au client
                    context.ShouldRenew = true;
                }
            }
        };
    });

builder.Services.AddDbContext<VertigoContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));
builder.Services.AddScoped<Service>();
builder.Services.AddScoped<IVertigoApiClient, VertigoApiClient>();
builder.Services.AddScoped<INotificationService, NotificationService>();

builder.Services.AddHostedService<Vertigo.BackgroundServices.SubscriptionWorker>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactApp",
        policy => policy
            .SetIsOriginAllowed(origin =>
            {
                if (string.IsNullOrEmpty(origin)) return false;
                var uri = new Uri(origin);
                return uri.Host == "localhost" || uri.Host == "127.0.0.1";
            })
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials());
});

var app = builder.Build();

// ── Middleware pipeline ───────────────────────────────────────────────────────
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}
else
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
    app.UseHttpsRedirection();
}

app.UseCors("AllowReactApp");
app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();

app.MapControllers();

// ── Seed dev data (idempotent) ────────────────────────────────────────────────
using (var scope = app.Services.CreateScope())
{
    var ctx = scope.ServiceProvider.GetRequiredService<VertigoContext>();
    await SeedData.EnsureSeededAsync(ctx);
}

app.Run();
