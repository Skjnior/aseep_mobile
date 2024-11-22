/// Enumération pour représenter le statut de l'information
enum Statut {
  important,
  moyen,
  tresImportant,
}

/// Classe pour représenter une information
class Information {
  final String ID;
  final String message;
  final Statut statut;

  /// Constructeur
  Information({
    required this.ID,
    required this.message,
    required this.statut,
  });

  /// Constructeur pour créer une `Information` à partir d'un JSON
  Information.fromJson(Map<String, dynamic> json)
      : ID = json['ID'] as String,
        message = json['message'] as String,
        statut = Statut.values.firstWhere(
              (e) => e.toString() == 'Statut.${json['statut']}',
          orElse: () => Statut.moyen, // Valeur par défaut si le statut est invalide
        );

  /// Méthode pour convertir une `Information` en JSON
  Map<String, dynamic> toJson() => {
    'ID': ID,
    'message': message,
    'statut': statut.name, // Convertit l'enum en chaîne de caractères
  };
}
