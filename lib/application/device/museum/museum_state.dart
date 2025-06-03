import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class MuseumState extends Equatable {
  final bool isMuseum;
  final String? museumName;
  const MuseumState({
    required this.isMuseum,
    this.museumName,
  });

  @override
  List<Object?> get props => [isMuseum, museumName];

  MuseumState copyWith({
    bool? isMuseum,
    ValueGetter<String?>? museumName,
  }) {
    return MuseumState(
      isMuseum: isMuseum ?? this.isMuseum,
      museumName: museumName != null ? museumName() : this.museumName,
    );
  }
}
