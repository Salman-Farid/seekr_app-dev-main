import 'dart:convert';

import 'package:equatable/equatable.dart';

class OcrBlocks extends Equatable {
  final List<Block> blocks;

  const OcrBlocks({
    required this.blocks,
  });

  OcrBlocks copyWith({
    List<Block>? blocks,
  }) =>
      OcrBlocks(
        blocks: blocks ?? this.blocks,
      );

  factory OcrBlocks.fromJson(String str) => OcrBlocks.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OcrBlocks.fromMap(Map<String, dynamic> json) => OcrBlocks(
        blocks: List<Block>.from(json["blocks"].map((x) => Block.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "blocks": List<dynamic>.from(blocks.map((x) => x.toMap())),
      };

  @override
  List<Object> get props => [blocks];
}

class Block {
  final List<Line> lines;

  Block({
    required this.lines,
  });

  Block copyWith({
    List<Line>? lines,
  }) =>
      Block(
        lines: lines ?? this.lines,
      );

  factory Block.fromJson(String str) => Block.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Block.fromMap(Map<String, dynamic> json) => Block(
        lines: List<Line>.from(json["lines"].map((x) => Line.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "lines": List<dynamic>.from(lines.map((x) => x.toMap())),
      };
}

class Line extends Equatable {
  final String text;

  const Line({
    required this.text,
  });

  Line copyWith({
    String? text,
  }) =>
      Line(
        text: text ?? this.text,
      );

  factory Line.fromJson(String str) => Line.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Line.fromMap(Map<String, dynamic> json) => Line(
        text: json["text"],
      );

  Map<String, dynamic> toMap() => {
        "text": text,
      };

  @override
  List<Object> get props => [
        text,
      ];
}
