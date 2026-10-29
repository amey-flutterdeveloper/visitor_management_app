import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visitor_management_app/logic/visitor/visitor_event.dart';
import 'package:visitor_management_app/logic/visitor/visitor_state.dart';
import 'package:visitor_management_app/util/visitor_enum.dart';

import '../../data/visitor_api.dart';
import '../../data/visitor_repository.dart';
import '../../models/visitor.dart';

class VisitorBloc extends Bloc<VisitorEvent, VisitorState> {
  VisitorBloc(this._repository) : super(const VisitorState()) {
    on<VisitorsRequested>(_onLoad);
    on<VisitorSaved>(_onSave);
    on<VisitorDeleted>(_onDelete);
    on<VisitorCheckInRequested>(_onCheckIn);
    on<VisitorCheckOutRequested>(_onCheckOut);
    on<VisitorByIdRequested>(_onById);
    on<VisitorSearchChanged>(
      (event, emit) {
        emit(state.copyWith(searchQuery: event.query));
      },
    );
  }

  final VisitorRepository _repository;

  Future<Visitor?> lookupVisitor(String id) async {
    try {
      return await _repository.getVisitor(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _onLoad(
    VisitorsRequested event,
    Emitter<VisitorState> emit,
  ) async {
    emit(
      state.copyWith(
        status: VisitorStatus.loading,
        clearError: true,
        clearNotice: true,
      ),
    );

    try {
      final visitors = await _repository.getVisitors();

      emit(
        state.copyWith(
          status: VisitorStatus.loaded,
          visitors: visitors,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: VisitorStatus.failure,
          errorMessage: _message(error),
        ),
      );
    }
  }

  Future<void> _onSave(
    VisitorSaved event,
    Emitter<VisitorState> emit,
  ) async {
    final isNewVisitor = event.visitor.id.isEmpty;

    emit(
      state.copyWith(
        status: VisitorStatus.saving,
        clearError: true,
        clearNotice: true,
      ),
    );

    try {
      final savedVisitor = isNewVisitor
          ? await _repository.createVisitor(event.visitor)
          : await _repository.updateVisitor(event.visitor);

      if (savedVisitor.id.trim().isEmpty) {
        throw const ApiException(
          'The API did not return a visitor ID.',
        );
      }

      final visitors = await _refreshVisitors(
        savedVisitor,
        state.visitors,
      );

      final selectedVisitor = visitors.firstWhere(
        (visitor) => visitor.id == savedVisitor.id,
        orElse: () => savedVisitor,
      );

      emit(
        state.copyWith(
          status: VisitorStatus.loaded,
          visitors: visitors,
          selectedVisitor: selectedVisitor,
          clearError: true,
          notice: isNewVisitor
              ? 'Visitor registered successfully.'
              : 'Visitor updated successfully.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: VisitorStatus.loaded,
          errorMessage: _message(error),
        ),
      );
    }
  }

  Future<void> _onDelete(
    VisitorDeleted event,
    Emitter<VisitorState> emit,
  ) async {
    emit(
      state.copyWith(
        status: VisitorStatus.saving,
        clearError: true,
        clearNotice: true,
      ),
    );

    try {
      await _repository.deleteVisitor(event.id);

      final visitors = await _repository.getVisitors();

      emit(
        state.copyWith(
          status: VisitorStatus.loaded,
          visitors: visitors,
          clearSelected: state.selectedVisitor?.id == event.id,
          clearError: true,
          notice: 'Visitor deleted successfully.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: VisitorStatus.loaded,
          errorMessage: _message(error),
        ),
      );
    }
  }

  Future<void> _onCheckIn(
    VisitorCheckInRequested event,
    Emitter<VisitorState> emit,
  ) async {
    await _changeStatus(event.visitor, true, emit);
  }

  Future<void> _onCheckOut(
    VisitorCheckOutRequested event,
    Emitter<VisitorState> emit,
  ) async {
    await _changeStatus(event.visitor, false, emit);
  }

  Future<void> _changeStatus(
    Visitor visitor,
    bool checkIn,
    Emitter<VisitorState> emit,
  ) async {
    emit(
      state.copyWith(
        status: VisitorStatus.saving,
        clearError: true,
        clearNotice: true,
      ),
    );

    try {
      final updatedVisitor = checkIn
          ? await _repository.checkIn(visitor)
          : await _repository.checkOut(visitor);

      final visitors = await _refreshVisitors(
        updatedVisitor,
        state.visitors,
      );

      final selectedVisitor = visitors.firstWhere(
        (item) => item.id == updatedVisitor.id,
        orElse: () => updatedVisitor,
      );

      emit(
        state.copyWith(
          status: VisitorStatus.loaded,
          visitors: visitors,
          selectedVisitor: selectedVisitor,
          clearError: true,
          notice: checkIn
              ? 'Visitor checked in successfully.'
              : 'Visitor checked out successfully.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: VisitorStatus.loaded,
          errorMessage: _message(error),
        ),
      );
    }
  }

  Future<List<Visitor>> _refreshVisitors(
    Visitor updatedVisitor,
    List<Visitor> currentVisitors,
  ) async {
    try {
      return await _repository.getVisitors();
    } catch (_) {
      final visitors = List<Visitor>.of(currentVisitors);
      final index = visitors.indexWhere(
        (visitor) => visitor.id == updatedVisitor.id,
      );

      if (index == -1) {
        visitors.add(updatedVisitor);
      } else {
        visitors[index] = updatedVisitor;
      }

      return visitors;
    }
  }

  Future<void> _onById(
    VisitorByIdRequested event,
    Emitter<VisitorState> emit,
  ) async {
    try {
      final visitor = await _repository.getVisitor(event.id);

      emit(
        state.copyWith(
          status: VisitorStatus.loaded,
          selectedVisitor: visitor,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: VisitorStatus.loaded,
          errorMessage: _message(error),
          clearSelected: true,
        ),
      );
    }
  }

  String _message(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
