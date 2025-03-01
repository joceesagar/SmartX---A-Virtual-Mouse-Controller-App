// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DataModels {
  final String type;
  final double gestureSensitivity;
  final bool hapticOutput;
  final int hapticMode;
  final String leftClick;
  final String rightClick;
  final String doubleClick;
  final String scrollGesture;
  final double scrollSpeed;
  final String deviceName;
  final DateTime createdAt;
  final DateTime updatedAt;

  DataModels({
    this.type = 'N',
    this.gestureSensitivity = 70.0,
    this.hapticOutput = true,
    this.hapticMode = 0,
    this.leftClick = 'Index',
    this.rightClick = 'Ring',
    this.doubleClick = 'Index',
    this.scrollGesture = 'IndexMiddle',
    this.scrollSpeed = 20.0,
    this.deviceName = 'Default Device',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DataModels copyWith({
    String? type,
    double? gestureSensitivity,
    bool? hapticOutput,
    int? hapticMode,
    String? leftClick,
    String? rightClick,
    String? doubleClick,
    String? scrollGesture,
    double? scrollSpeed,
    String? deviceName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DataModels(
      type: type ?? this.type,
      gestureSensitivity: gestureSensitivity ?? this.gestureSensitivity,
      hapticOutput: hapticOutput ?? this.hapticOutput,
      hapticMode: hapticMode ?? this.hapticMode,
      leftClick: leftClick ?? this.leftClick,
      rightClick: rightClick ?? this.rightClick,
      doubleClick: doubleClick ?? this.doubleClick,
      scrollGesture: scrollGesture ?? this.scrollGesture,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      deviceName: deviceName ?? this.deviceName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'gestureSensitivity': gestureSensitivity,
      'hapticOutput': hapticOutput,
      'hapticMode': hapticMode,
      'leftClick': leftClick,
      'rightClick': rightClick,
      'doubleClick': doubleClick,
      'scrollGesture': scrollGesture,
      'scrollSpeed': scrollSpeed,
      'deviceName': deviceName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory DataModels.fromMap(Map<String, dynamic> map) {
    return DataModels(
      type: map['type'] ?? 'N',
      gestureSensitivity:
          (map['gestureSensitivity'] as num?)?.toDouble() ?? 70.0,
      hapticOutput: map['hapticOutput'] ?? true,
      hapticMode: map['hapticMode'] ?? 0,
      leftClick: map['leftClick'] ?? 'Index',
      rightClick: map['rightClick'] ?? 'Ring',
      doubleClick: map['doubleClick'] ?? 'Index',
      scrollGesture: map['scrollGesture'] ?? 'IndexMiddle',
      scrollSpeed: (map['scrollSpeed'] as num?)?.toDouble() ?? 20.0,
      deviceName: map['deviceName'] ?? 'Default Device',
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DataModels.fromJson(String source) =>
      DataModels.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DataModels(type: $type, gestureSensitivity: $gestureSensitivity, hapticOutput: $hapticOutput, hapticMode: $hapticMode, leftClick: $leftClick, rightClick: $rightClick, doubleClick: $doubleClick, scrollGesture: $scrollGesture, scrollSpeed: $scrollSpeed, deviceName: $deviceName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant DataModels other) {
    if (identical(this, other)) return true;

    return other.type == type &&
        other.gestureSensitivity == gestureSensitivity &&
        other.hapticOutput == hapticOutput &&
        other.hapticMode == hapticMode &&
        other.leftClick == leftClick &&
        other.rightClick == rightClick &&
        other.doubleClick == doubleClick &&
        other.scrollGesture == scrollGesture &&
        other.scrollSpeed == scrollSpeed &&
        other.deviceName == deviceName &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        gestureSensitivity.hashCode ^
        hapticOutput.hashCode ^
        hapticMode.hashCode ^
        leftClick.hashCode ^
        rightClick.hashCode ^
        doubleClick.hashCode ^
        scrollGesture.hashCode ^
        scrollSpeed.hashCode ^
        deviceName.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
