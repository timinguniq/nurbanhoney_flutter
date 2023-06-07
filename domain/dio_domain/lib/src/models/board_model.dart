class BoardModel {
  int id;
  int type;
  String name;
  String address;

  BoardModel({
    required this.id,
    required this.type,
    required this.name,
    required this.address,
  });

  get getId => id;
  get getType => type;
  get getName => name;
  get getAddress => address;

  factory BoardModel.fromJson(Map<String, dynamic> json) {
    return BoardModel(
      id: json["id"],
      type: json["type"],
      name: json["name"],
      address: json["address"],
    );
  }
}
