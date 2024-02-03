class TipModel {
  int id;
  String title;
  String description;
  DateTime createdAt;

  TipModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory TipModel.fromJson(Map<String, dynamic> json) => TipModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "created_at": createdAt,
      };
}
