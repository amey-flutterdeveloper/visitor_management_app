import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/visitor_repository.dart';

import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc(this._repository) : super(const ScannerState()) {
    on<ScannerLookupStarted>(_onLookupStarted);
    on<ScannerVisitorFound>(_onVisitorFound);
    on<ScannerVisitorNotFound>(_onVisitorNotFound);
    on<ScannerLookupFailed>(_onLookupFailed);
    on<ScannerInvalidQr>(_onInvalidQr);
    on<ScannerReset>(_onReset);
  }

  final VisitorRepository _repository;

  Future<void> _onLookupStarted(
    ScannerLookupStarted event,
    Emitter<ScannerState> emit,
  ) async {
    final visitorId = event.visitorId.trim();

    if (visitorId.isEmpty) {
      emit(
        const ScannerState(
          status: ScannerStatus.error,
          message: 'This QR code does not contain a visitor ID.',
        ),
      );
      return;
    }

    emit(
      const ScannerState(
        status: ScannerStatus.processing,
        message: 'Looking up visitor...',
      ),
    );

    try {
      final visitor = await _repository.getVisitor(visitorId);

      if (visitor.id.trim() != visitorId) {
        emit(
          ScannerState(
            status: ScannerStatus.error,
            message: 'No visitor found for ID: $visitorId',
          ),
        );
        return;
      }

      emit(
        ScannerState(
          status: ScannerStatus.success,
          message: 'Visitor verified',
          visitor: visitor,
        ),
      );
    } catch (error) {
      emit(
        ScannerState(
          status: ScannerStatus.error,
          message: _errorMessage(error),
        ),
      );
    }
  }

  void _onVisitorFound(
    ScannerVisitorFound event,
    Emitter<ScannerState> emit,
  ) {
    emit(
      ScannerState(
        status: ScannerStatus.success,
        message: 'Visitor verified',
        visitor: event.visitor,
      ),
    );
  }

  void _onVisitorNotFound(
    ScannerVisitorNotFound event,
    Emitter<ScannerState> emit,
  ) {
    emit(
      ScannerState(
        status: ScannerStatus.error,
        message: 'No visitor found for ID: ${event.visitorId}',
      ),
    );
  }

  void _onLookupFailed(
    ScannerLookupFailed event,
    Emitter<ScannerState> emit,
  ) {
    emit(
      ScannerState(
        status: ScannerStatus.error,
        message: event.message,
      ),
    );
  }

  void _onInvalidQr(
    ScannerInvalidQr event,
    Emitter<ScannerState> emit,
  ) {
    emit(
      const ScannerState(
        status: ScannerStatus.error,
        message: 'This QR code does not contain a visitor ID.',
      ),
    );
  }

  void _onReset(
    ScannerReset event,
    Emitter<ScannerState> emit,
  ) {
    emit(const ScannerState());
  }

  String _errorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();

    if (message.isEmpty) {
      return 'Unable to look up this visitor. Check your connection and try again.';
    }

    return message;
  }
}
