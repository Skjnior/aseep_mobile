/// Représente un niveau avec ses propriétés et son emploi du temps
class Niveau {
  // Propriétés principales
  final String ID; // Identifiant unique du niveau
  final String name; // Nom du niveau
  final String imagePath; // Chemin de l'image associée au niveau

  // Emploi du temps : clé = jour, valeur = liste des cours
  final Map<String, Map<String, dynamic>> emploiDuTemps;

  /// Constructeur de la classe `Niveau`
  Niveau({
    required this.ID,
    required this.name,
    required this.imagePath,
    required this.emploiDuTemps,
  });

  /// Constructeur nommé `fromJson` pour créer un objet à partir d'une structure JSON
  Niveau.fromJson(Map<String, dynamic> json)
      : ID = json['ID'] as String,
        name = json['name'] as String,
        imagePath = json['imagePath'] as String,
        emploiDuTemps = (json['emploiDuTemps'] as Map<String, dynamic>).map(
              (jour, details) => MapEntry(
            jour,
            details as Map<String, dynamic>,
          ),
        );

  /// Convertit l'objet `Niveau` en une structure JSON
  Map<String, dynamic> toJson() => {
    'ID': ID,
    'name': name,
    'imagePath': imagePath,
    'emploiDuTemps': emploiDuTemps.map(
          (jour, details) => MapEntry(jour, details),
    ),
  };

}