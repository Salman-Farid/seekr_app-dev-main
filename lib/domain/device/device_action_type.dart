import 'package:equatable/equatable.dart';
import 'package:xml/xml.dart';

enum DeviceActionType {
  switchToNextMode,
  switchToPreviousMode,
  capturePhoto,
  longPress,
  idle,
}

class DeviceAction extends Equatable {
  final DeviceActionType action;
  final DateTime time;

  const DeviceAction({required this.action, required this.time});

  @override
  List<Object> get props => [action, time];
}

class DeviceActionObject extends Equatable {
  final int cmd;
  final int status;
  const DeviceActionObject({
    required this.cmd,
    required this.status,
  });

  DeviceActionObject copyWith({
    int? cmd,
    int? status,
  }) {
    return DeviceActionObject(
      cmd: cmd ?? this.cmd,
      status: status ?? this.status,
    );
  }

  factory DeviceActionObject.fromXml(XmlDocument doc) {
    final functionElement = doc.findAllElements('Function').first;
    final cmd = int.parse(functionElement.getElement('Cmd')!.innerText);
    final status = int.parse(functionElement.getElement('Status')!.innerText);

    return DeviceActionObject(
      cmd: cmd,
      status: status,
    );
  }

  @override
  List<Object> get props => [cmd, status];

  @override
  String toString() => 'cmd: $cmd, status: $status';
}
