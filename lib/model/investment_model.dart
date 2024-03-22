class Investment {
  final String stockSymbol;
  final String stockName;
  final String stockExchange;
  final double costPrice;
  final int quantity;

  Investment({
    required this.stockSymbol,
    required this.stockName,
    required this.stockExchange,
    required this.costPrice,
    required this.quantity,
  });

  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      stockSymbol: json['stockSymbol'] as String,
      stockName: json['stockName'] as String,
      stockExchange: json['stockExchange'] as String,
      costPrice: json['costPrice'] as double,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stockSymbol'] = this.stockSymbol;
    data['stockName'] = this.stockName;
    data['stockExchange'] = this.stockExchange;
    data['costPrice'] = this.costPrice;
    data['quantity'] = this.quantity;
    return data;
  }
}
