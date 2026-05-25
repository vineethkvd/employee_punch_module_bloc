import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/punch_model.dart';
import '../../domain/usecases/submit_punch_usecase.dart';
import '../../domain/entities/punch_entity.dart';

part 'punch_event.dart';
part 'punch_state.dart';

class PunchBloc extends Bloc<PunchEvent, PunchState> {
  final SubmitPunchUseCase submitPunchUseCase;

  PunchBloc({required this.submitPunchUseCase}) : super(const PunchInitial()) {
    on<SubmitPunchEvent>(_onSubmitPunchEvent);
  }

  Future<void> _onSubmitPunchEvent(
      SubmitPunchEvent event,
      Emitter<PunchState> emit,
      ) async {
    emit(const PunchLoading());
    try {
      final apiResponse = await submitPunchUseCase.postApi(
        p_flag: "EMPLOYEE_PUNCH",
        p_pageval: "${event.empCode}~${event.password}~${event.image}",
        p_paraval: "1",
      );

      final result = PunchModel.fromJson(apiResponse);

      emit(PunchSuccess(result));
    } catch (e) {
      emit(PunchFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}