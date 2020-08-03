import 'dart:convert';

ThoughtModel clientFromJson(String str) {
  final jsonData = json.decode(str);
  return ThoughtModel.fromMap(jsonData);
}

String clientToJson(ThoughtModel data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class ThoughtModel {
  int id;
  String content;
  String datetime;
  String distortions;

  ThoughtModel({this.id, this.content, this.datetime, this.distortions});

  factory ThoughtModel.fromMap(Map<String, dynamic> json) => ThoughtModel(
      id: json["id"],
      content: json["content"],
      datetime: json["datetime"],
      distortions: json["distortions"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "content": content,
        "datetime": datetime,
        "distortions": distortions,
      };

  @override
  String toString() {
    // return super.toString();
    return id.toString() + " " + content;
  }
}
