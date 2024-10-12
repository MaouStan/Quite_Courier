class OrderPeople {
  String name;
  String telephone;

  OrderPeople({required this.name, required this.telephone});

  Map<String, dynamic> toJson() => {
        'name': name,
        'telephone': telephone,
      };

  static OrderPeople fromJson(Map<String, dynamic> json) => OrderPeople(
        name: json['name'],
        telephone: json['telephone'],
      );
}
