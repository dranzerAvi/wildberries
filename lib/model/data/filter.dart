class Filter {
  String id, filterName;
  String type;
  List options;
  Filter.fromMap(Map<String, dynamic> data) {
    filterName = data["filterName"];
    options = data["options"];

    id = data["_id"];
  }
  Map<String, dynamic> toMap() {
    return {'filterName': filterName, 'options': options, '_id': id};
  }

  Filter(this.id, this.filterName, this.options, {this.type});
}
