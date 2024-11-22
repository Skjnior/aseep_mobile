import 'package:aseep/models/filiere.dart';
import 'package:aseep/models/niveau.dart';

class Student {
  final String ID; // Identifiant unique de l'étudiant
  final String firstName; // Prénom de l'étudiant
  final String lastName; // Nom de famille de l'étudiant
  final String brithDay; // Date de naissance sous forme de chaîne
  final String imagePath; // Chemin de l'image de l'étudiant
  final Filiere filiere; // Filière à laquelle l'étudiant appartient
  final Niveau niveau; // Niveau d'étude de l'étudiant
  final bool isMember; // Statut si l'étudiant est membre (par exemple d'un club)
  final DateTime anneeScolaire; // Année scolaire de l'étudiant
  final int? anneeAdhesion; // Année d'adhésion si l'étudiant est membre
  final String? role; // Rôle ou fonction de l'étudiant dans l'organisation (s'il est membre)

  // Constructeur de la classe Student
  Student({
    required this.ID,
    required this.firstName,
    required this.lastName,
    required this.brithDay,
    required this.imagePath,
    required this.filiere,
    required this.niveau,
    required this.isMember,
    required this.anneeScolaire,
    this.anneeAdhesion, // Optionnel, uniquement si l'étudiant est membre
    this.role, // Optionnel, uniquement si l'étudiant est membre
  });

  // Constructeur pour créer un étudiant à partir d'un JSON
  Student.fromJson(Map<String, dynamic> json)
      : ID = json['ID'] as String,
        firstName = json['firstName'] as String,
        lastName = json['lastName'] as String,
        brithDay = json['brithDay'] as String,
        imagePath = json['imagePath'] as String,
        filiere = Filiere.fromJson(json['filiere'] as Map<String, dynamic>),
        niveau = Niveau.fromJson(json['niveau'] as Map<String, dynamic>),
        isMember = json['isMember'] as bool,
        anneeScolaire = DateTime.parse(json['anneeScolaire'] as String), // Conversion de la chaîne en DateTime
        anneeAdhesion = json['anneeAdhesion'] != null ? json['anneeAdhesion'] as int : null,
        role = json['role'];

  // Méthode pour convertir un étudiant en JSON
  Map<String, dynamic> toJson() => {
    'ID': ID,
    'firstName': firstName,
    'lastName': lastName,
    'brithDay': brithDay,
    'imagePath': imagePath,
    'filiere': filiere.toJson(),
    'niveau': niveau.toJson(),
    'isMember': isMember,
    'anneeScolaire': anneeScolaire.toIso8601String(),
    if (anneeAdhesion != null) 'anneeAdhesion': anneeAdhesion, // Inclus uniquement si non nul
    if (role != null) 'role': role, // Inclus uniquement si non nul
  };
}
