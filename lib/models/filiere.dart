import 'dart:convert';

class Filiere {
  final String ID;
  final String name;
  final String sigle;
  // Les proprietes ne pas obligatoire
  final String? imagePath;
  final String? chefDepartement;
  final String? niveau;
  final String? domaine;
  final String? slogan;

  Filiere(
      this.sigle, this.ID, this.name,
      // Les proprietes qui sont dans les crochets ne sont pas obligatoire
      [
       this.imagePath,
       this.chefDepartement,
       this.niveau,
       this.domaine,
       this.slogan
      ]
  );

  // Constructeur nommer, qui permet de cree un departement a partir d'une structure Map<string, dynamic>
  Filiere.fromJson(Map<String, dynamic> json)
      : ID = json['ID'] as String,
        name = json['name'] as String,
        sigle = json['email'] as String,
        imagePath = json['imagePath'] as String,
        chefDepartement = json['chefDepartement'] as String,
        niveau = json['imageChefDepartement'] as String,
        domaine = json['domaine'] as String,
        slogan = json['slogan'] as String;

  // Cette méthode convertit un objet Departement en une structure JSON (Map<String, dynamic>).
  Map<String, dynamic> toJson() => {
    'ID': ID,
    'name': name,
    'sigle': sigle,
    'imagePath': imagePath,
    'chefDepartement': chefDepartement,
    'imageChefDepartement': niveau,
    'domaine': domaine,
    'slogan': slogan,
  };
}