// import 'package:hive/hive.dart';

// part 'tipmodel.g.dart';

// @HiveType(typeId: 0)
// class TipModel {
//   @HiveField(0)
//   int id;
//   @HiveField(1)
//   String title;
//   @HiveField(2)
//   String description;
//   @HiveField(3)
//   DateTime createdAt;
//   bool favourite;

//   TipModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.createdAt,
//     this.favourite = false,
//   });

//   // gettters
//   int get getId => id;
//   String get getTitle => title;
//   String get getDescription => description;
//   DateTime get getCreatedAt => createdAt;
//   bool get getFavourite => favourite;

//   factory TipModel.fromJson(Map<String, dynamic> json) => TipModel(
//         id: json["id"],
//         title: json["title"],
//         description: json["description"],
//         createdAt: json["created_at"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "title": title,
//         "description": description,
//         "created_at": createdAt,
//       };
// }
