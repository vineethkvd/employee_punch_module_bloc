part of 'punch_bloc.dart';

abstract class PunchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitPunchEvent extends PunchEvent {
  final String empCode;
  final String password;
  final XFile image;

  SubmitPunchEvent({required this.empCode, required this.password, required this.image});

  @override
  List<Object?> get props => [empCode, password, image.path];
}
