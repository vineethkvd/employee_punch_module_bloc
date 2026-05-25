import 'package:equatable/equatable.dart';

class PunchEntity extends Equatable {
  final String message;
  final bool isSuccess;

  const PunchEntity({required this.message, required this.isSuccess});

  @override
  List<Object?> get props => [message, isSuccess];
}