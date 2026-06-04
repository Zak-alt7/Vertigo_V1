class Utilisateur {
  final int id;
  String nom;
  String email;
  String telephone;
  bool etudiant;
  final String role;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.etudiant,
    this.role = 'Client',
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      etudiant: json['etudiant'],
      role: json['role'] ?? 'Client',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'email': email,
    'telephone': telephone,
    'etudiant': etudiant,
    'role': role,
  };
}
