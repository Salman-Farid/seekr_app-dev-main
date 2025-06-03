import 'package:equatable/equatable.dart';

class DeviceInfo extends Equatable {
  final String brand;
  final String model;
  final String version;
  const DeviceInfo({
    required this.brand,
    required this.model,
    required this.version,
  });

  DeviceInfo copyWith({
    String? brand,
    String? model,
    String? version,
  }) {
    return DeviceInfo(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      version: version ?? this.version,
    );
  }

  factory DeviceInfo.example() {
    return const DeviceInfo(
      brand: 'ExampleBrand',
      model: 'ExampleModel',
      version: '1.0.0',
    );
  }

  @override
  String toString() =>
      'DeviceInfo(brand: $brand, model: $model, version: $version)';

  @override
  List<Object> get props => [brand, model, version];
}
