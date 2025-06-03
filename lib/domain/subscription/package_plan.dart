import 'dart:convert';

import 'package:equatable/equatable.dart';

class PackagePlan extends Equatable {
  final String id;
  final String name;
  final double price;
  final String currency;
  final int period;
  final String periodUnit;

  const PackagePlan({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.period,
    required this.periodUnit,
  });

  PackagePlan copyWith({
    String? id,
    String? name,
    double? price,
    String? currency,
    int? period,
    String? periodUnit,
  }) {
    return PackagePlan(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      periodUnit: periodUnit ?? this.periodUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'currency': currency,
      'period': period,
      'periodUnit': periodUnit,
    };
  }

  factory PackagePlan.fromMap(Map<String, dynamic> map) {
    return PackagePlan(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      currency: map['currency'] ?? '',
      period: map['period']?.toInt() ?? 0,
      periodUnit: map['period_unit'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory PackagePlan.fromJson(String source) =>
      PackagePlan.fromMap(json.decode(source));

  @override
  String toString() {
    return 'PackagePlan(id: $id, name: $name, price: $price, currency: $currency, period: $period, periodUnit: $periodUnit)';
  }

  @override
  List<Object> get props {
    return [
      id,
      name,
      price,
      currency,
      period,
      periodUnit,
    ];
  }
}
