part of 'punch_bloc.dart';

sealed class PunchState extends Equatable {
  const PunchState();

  @override
  List<Object?> get props => [];
}

class PunchInitial extends PunchState {
  const PunchInitial();
}

class PunchLoading extends PunchState {
  const PunchLoading();
}

class PunchSuccess extends PunchState {
  final PunchEntity result;

  const PunchSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class PunchFailure extends PunchState {
  final String message;

  const PunchFailure(this.message);

  @override
  List<Object?> get props => [message];
}