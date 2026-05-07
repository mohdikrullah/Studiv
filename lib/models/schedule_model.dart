import 'package:hive/hive.dart';

class ScheduleModel {
  String id;
  String subject;
  String time;
  String room;
  String? day;
  String? lecturer;

  ScheduleModel({
    required this.id,
    required this.subject,
    required this.time,
    required this.room,
    this.day,
    this.lecturer,
  });
}

// Manual Hive TypeAdapter to avoid build_runner dependency
class ScheduleModelAdapter extends TypeAdapter<ScheduleModel> {
  @override
  final int typeId = 0;

  @override
  ScheduleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleModel(
      id: fields[0] as String,
      subject: fields[1] as String,
      time: fields[2] as String,
      room: fields[3] as String,
      day: fields[4] as String?,
      lecturer: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(3)
      ..write(obj.room)
      ..writeByte(4)
      ..write(obj.day)
      ..writeByte(5)
      ..write(obj.lecturer);
  }
}
