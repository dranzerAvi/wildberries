class LeafCategory {
  String parentId;
  String id;
  String name;
  bool active;
  String banner;
  int __v;
  String description;
  int upToOff;
  LeafCategory.fromMap(Map<String, dynamic> data) {
    // String altBanner = data['banner'].toString().replaceAll('\\', '/');

    parentId = data["parentId"];
    id = data["_id"];
    name = data["name"];
    active = data["active"];
    banner = data['banner'].toString().replaceAll('\\', '/');
    __v = data["__v"];
    description = data["description"];
    upToOff = data["upToOff"];
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      '_id': id,
      'name': name,
      'active': active,
      'banner': banner,
      '__v': name,
      'description': description,
      'upToOff': upToOff
    };
  }
}
