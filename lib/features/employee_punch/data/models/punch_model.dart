import '../../domain/entities/punch_entity.dart';

class PunchModel extends PunchEntity {
  const PunchModel({required super.message, required super.isSuccess});

  factory PunchModel.fromJson(Map<String, dynamic> json) {
    return PunchModel(
      message: json['message'] ?? 'Unknown response',
      isSuccess: json['isSuccess'] ?? true,
    );
  }
}
