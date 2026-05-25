import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';
import '../../domain/usecases/submit_punch_usecase.dart';
import '../../domain/entities/punch_entity.dart';
part 'punch_event.dart';
part 'punch_state.dart';







// --- BLOC ---
class PunchBloc extends Bloc<PunchEvent, PunchState> {
  final SubmitPunchUseCase submitPunchUseCase;

  PunchBloc({required this.submitPunchUseCase}) : super(PunchInitial()) {
    on<SubmitPunchEvent>((event, emit) async {
      emit(PunchLoading());
      try {
        final result = await submitPunchUseCase.call(event.empCode, event.password, event.image);
        emit(PunchSuccess(result));
      } catch (e) {
        emit(PunchFailure(e.toString().replaceAll('Exception: ', '')));
      }
    });
  }
}
