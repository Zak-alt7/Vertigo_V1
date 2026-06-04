using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Vertigo.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Attempts",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    SubscriptionId = table.Column<int>(type: "INTEGER", nullable: false),
                    AttemptedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Success = table.Column<bool>(type: "INTEGER", nullable: false),
                    FailureReason = table.Column<string>(type: "TEXT", nullable: true),
                    ReservedOfferId = table.Column<Guid>(type: "TEXT", nullable: true),
                    AttemptNumber = table.Column<int>(type: "INTEGER", nullable: false),
                    OriginalPrice = table.Column<decimal>(type: "TEXT", nullable: true),
                    DiscountedPrice = table.Column<decimal>(type: "TEXT", nullable: true),
                    AppliedDiscountPercentage = table.Column<int>(type: "INTEGER", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Attempts", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Utilisateur",
                columns: table => new
                {
                    ID = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Nom = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    Email = table.Column<string>(type: "TEXT", nullable: false),
                    MotDePasse = table.Column<string>(type: "TEXT", nullable: false),
                    Telephone = table.Column<string>(type: "TEXT", nullable: false),
                    Role = table.Column<string>(type: "TEXT", nullable: false),
                    DateInscription = table.Column<DateTime>(type: "TEXT", nullable: false),
                    NBReport = table.Column<int>(type: "INTEGER", nullable: false),
                    Report = table.Column<string>(type: "TEXT", nullable: false),
                    Etudiant = table.Column<bool>(type: "INTEGER", nullable: false),
                    NumCarteEtu = table.Column<string>(type: "TEXT", nullable: true),
                    BAN = table.Column<bool>(type: "INTEGER", nullable: false),
                    ProfilImagePath = table.Column<string>(type: "TEXT", nullable: false),
                    Wilaya = table.Column<string>(type: "TEXT", maxLength: 50, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Utilisateur", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "Boutique",
                columns: table => new
                {
                    IDBoutique = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    NomBoutique = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    Ville = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    Description = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    IdGerant = table.Column<int>(type: "INTEGER", nullable: false),
                    Localisation = table.Column<string>(type: "TEXT", nullable: false),
                    Registre = table.Column<string>(type: "TEXT", nullable: false),
                    Valide = table.Column<bool>(type: "INTEGER", nullable: false),
                    Note_NbNote = table.Column<int>(type: "INTEGER", nullable: false),
                    Note_Note = table.Column<double>(type: "REAL", nullable: false),
                    NBvente = table.Column<int>(type: "INTEGER", nullable: false),
                    NBReport = table.Column<int>(type: "INTEGER", nullable: false),
                    Report = table.Column<string>(type: "TEXT", nullable: false),
                    BAN = table.Column<bool>(type: "INTEGER", nullable: false),
                    BoutiqueImagePath = table.Column<string>(type: "TEXT", nullable: false),
                    DateCreation = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Latitude = table.Column<double>(type: "REAL", nullable: true),
                    Longitude = table.Column<double>(type: "REAL", nullable: true),
                    CuisineType = table.Column<string>(type: "TEXT", maxLength: 100, nullable: true),
                    PhoneNumber = table.Column<string>(type: "TEXT", maxLength: 30, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Boutique", x => x.IDBoutique);
                    table.ForeignKey(
                        name: "FK_Boutique_Utilisateur_IdGerant",
                        column: x => x.IdGerant,
                        principalTable: "Utilisateur",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Panier",
                columns: table => new
                {
                    ID = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Name = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false),
                    Description = table.Column<string>(type: "TEXT", nullable: false),
                    Types = table.Column<string>(type: "TEXT", nullable: false),
                    IdBoutique = table.Column<int>(type: "INTEGER", nullable: false),
                    PanierPrix = table.Column<decimal>(type: "TEXT", nullable: false),
                    Note_NbNote = table.Column<int>(type: "INTEGER", nullable: false),
                    Note_Note = table.Column<double>(type: "REAL", nullable: false),
                    NBdispo = table.Column<int>(type: "INTEGER", nullable: false),
                    Statut = table.Column<bool>(type: "INTEGER", nullable: false),
                    PanierImagePath = table.Column<string>(type: "TEXT", nullable: false),
                    OriginalPrice = table.Column<decimal>(type: "TEXT", nullable: false),
                    DiscountPercentage = table.Column<decimal>(type: "TEXT", nullable: false),
                    ValidFrom = table.Column<DateTime>(type: "TEXT", nullable: true),
                    ValidUntil = table.Column<DateTime>(type: "TEXT", nullable: true),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Panier", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Panier_Boutique_IdBoutique",
                        column: x => x.IdBoutique,
                        principalTable: "Boutique",
                        principalColumn: "IDBoutique",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Subscriptions",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    UtilisateurId = table.Column<int>(type: "INTEGER", nullable: false),
                    BoutiqueId = table.Column<int>(type: "INTEGER", nullable: false),
                    TargetDay = table.Column<int>(type: "INTEGER", nullable: false),
                    TargetTime = table.Column<TimeSpan>(type: "TEXT", nullable: false),
                    Status = table.Column<string>(type: "TEXT", nullable: false),
                    FailureCount = table.Column<int>(type: "INTEGER", nullable: false),
                    MaxFailures = table.Column<int>(type: "INTEGER", nullable: false),
                    LastAttemptAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    LastSuccessAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                    LastFailureReason = table.Column<string>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    CancelledAt = table.Column<DateTime>(type: "TEXT", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Subscriptions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Subscriptions_Boutique_BoutiqueId",
                        column: x => x.BoutiqueId,
                        principalTable: "Boutique",
                        principalColumn: "IDBoutique");
                    table.ForeignKey(
                        name: "FK_Subscriptions_Utilisateur_UtilisateurId",
                        column: x => x.UtilisateurId,
                        principalTable: "Utilisateur",
                        principalColumn: "ID");
                });

            migrationBuilder.CreateTable(
                name: "Commande",
                columns: table => new
                {
                    ID = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    Reduction = table.Column<bool>(type: "INTEGER", nullable: false),
                    ClientID = table.Column<int>(type: "INTEGER", nullable: false),
                    PanierID = table.Column<int>(type: "INTEGER", nullable: false),
                    DateDeCommande = table.Column<DateTime>(type: "TEXT", nullable: false),
                    Prix = table.Column<decimal>(type: "TEXT", nullable: false),
                    Statut = table.Column<bool>(type: "INTEGER", nullable: false),
                    Status = table.Column<string>(type: "TEXT", maxLength: 20, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Commande", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Commande_Panier_PanierID",
                        column: x => x.PanierID,
                        principalTable: "Panier",
                        principalColumn: "ID");
                    table.ForeignKey(
                        name: "FK_Commande_Utilisateur_ClientID",
                        column: x => x.ClientID,
                        principalTable: "Utilisateur",
                        principalColumn: "ID");
                });

            migrationBuilder.CreateTable(
                name: "Favoris",
                columns: table => new
                {
                    Id = table.Column<int>(type: "INTEGER", nullable: false)
                        .Annotation("Sqlite:Autoincrement", true),
                    UtilisateurId = table.Column<int>(type: "INTEGER", nullable: false),
                    PanierId = table.Column<int>(type: "INTEGER", nullable: false),
                    DateAjout = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Favoris", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Favoris_Panier_PanierId",
                        column: x => x.PanierId,
                        principalTable: "Panier",
                        principalColumn: "ID");
                    table.ForeignKey(
                        name: "FK_Favoris_Utilisateur_UtilisateurId",
                        column: x => x.UtilisateurId,
                        principalTable: "Utilisateur",
                        principalColumn: "ID");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Boutique_IdGerant",
                table: "Boutique",
                column: "IdGerant");

            migrationBuilder.CreateIndex(
                name: "IX_Commande_ClientID",
                table: "Commande",
                column: "ClientID");

            migrationBuilder.CreateIndex(
                name: "IX_Commande_PanierID",
                table: "Commande",
                column: "PanierID");

            migrationBuilder.CreateIndex(
                name: "IX_Favoris_PanierId",
                table: "Favoris",
                column: "PanierId");

            migrationBuilder.CreateIndex(
                name: "IX_Favoris_UtilisateurId_PanierId",
                table: "Favoris",
                columns: new[] { "UtilisateurId", "PanierId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Panier_IdBoutique",
                table: "Panier",
                column: "IdBoutique");

            migrationBuilder.CreateIndex(
                name: "IX_Subscriptions_BoutiqueId",
                table: "Subscriptions",
                column: "BoutiqueId");

            migrationBuilder.CreateIndex(
                name: "IX_Subscriptions_UtilisateurId",
                table: "Subscriptions",
                column: "UtilisateurId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Attempts");

            migrationBuilder.DropTable(
                name: "Commande");

            migrationBuilder.DropTable(
                name: "Favoris");

            migrationBuilder.DropTable(
                name: "Subscriptions");

            migrationBuilder.DropTable(
                name: "Panier");

            migrationBuilder.DropTable(
                name: "Boutique");

            migrationBuilder.DropTable(
                name: "Utilisateur");
        }
    }
}
