class Product {
  final int? id;
  final String name;
  final double price;
  final int stock;
  final DateTime? createdAt;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.createdAt,
  });

  Product copyWith({
    int? id,
    String? name,
    double? price,
    int? stock,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:
          json['PRODUCTID'] is int
              ? json['PRODUCTID']
              : (json['PRODUCTID'] != null
                  ? int.parse(json['PRODUCTID'].toString())
                  : null),
      name: json['PRODUCTNAME'] as String? ?? '',
      price:
          (json['PRICE'] is num)
              ? (json['PRICE'] as num).toDouble()
              : double.tryParse(json['PRICE'].toString()) ?? 0.0,
      stock:
          (json['STOCK'] is int)
              ? json['STOCK'] as int
              : int.tryParse(json['STOCK'].toString()) ?? 0,
      createdAt:
          (() {
            final val =
                json['CREATED_AT'] ?? json['createdAt'] ?? json['created_at'];
            if (val == null) return null;
            if (val is DateTime) return val;
            try {
              return DateTime.parse(val.toString());
            } catch (_) {
              return null;
            }
          })(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'name': name, 'price': price, 'stock': stock};
    if (id != null) map['id'] = id;
    if (createdAt != null) map['createdAt'] = createdAt!.toIso8601String();
    return map;
  }
}
