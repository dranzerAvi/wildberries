class Offer {
  Map discountOn, discount;
  String id, title, banner, description, createdAt, updatedAt;
  bool active, firstOrder;
  int perUserLimit;
  Offer.fromMap(Map<String, dynamic> data) {
    discountOn = data["discountOn"];
    discount = data["discount"];
    title = data["title"];
    banner = data["banner"];
    description = data["description"];
    active = data["active"];
    firstOrder = data["firstOrder"];
    createdAt = data["createdAt"];
    updatedAt = data["updatedAt"];
    perUserLimit = data["perUserLimit"];

    id = data["_id"];
  }
  Map<String, dynamic> toMap() {
    return {
      'discountOn': discountOn,
      'discount': discount,
      'title': title,
      'banner': banner,
      'description': description,
      'active': active,
      'firstOrder': firstOrder,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'perUserLimit': perUserLimit,
      '_id': id
    };
  }

  Offer(
      this.id,
      this.createdAt,
      this.firstOrder,
      this.title,
      this.updatedAt,
      this.description,
      this.banner,
      this.discount,
      this.active,
      this.discountOn,
      this.perUserLimit);
}
