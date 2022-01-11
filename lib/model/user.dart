class User {
  late String name;
  late String uuid;
  late int? sex;
  late int? age;
  late String? imagePath;

  User({required this.name, required this.uuid, this.sex, this.age, this.imagePath});
}