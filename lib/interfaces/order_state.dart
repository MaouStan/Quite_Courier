enum OrderState {
  pending('Pending'),
  accepted('Accepted'),
  onDelivery('On Delivery'),
  completed('Completed'),
  canceled('Canceled');

  final String name;

  const OrderState(this.name);

  static OrderState fromJson(String json) => OrderState.values.firstWhere(
        (e) => e.name.toLowerCase() == json.toLowerCase(),
        orElse: () => OrderState.pending,
      );

  String toJson() => name;

  @override
  String toString() => name;
}
