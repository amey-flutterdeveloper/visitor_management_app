import 'package:equatable/equatable.dart';

import '../../models/visitor.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();

  @override
  List<Object?> get props => [];
}

class ScannerLookupStarted extends ScannerEvent {
  final String visitorId;

  const ScannerLookupStarted(this.visitorId);

  @override
  List<Object?> get props => [visitorId];
}

class ScannerVisitorFound extends ScannerEvent {
  final Visitor visitor;

  const ScannerVisitorFound(this.visitor);

  @override
  List<Object?> get props => [visitor];
}

class ScannerVisitorNotFound extends ScannerEvent {
  final String visitorId;

  const ScannerVisitorNotFound(this.visitorId);

  @override
  List<Object?> get props => [visitorId];
}

class ScannerLookupFailed extends ScannerEvent {
  final String message;

  const ScannerLookupFailed({
    this.message =
        'Unable to look up this QR code. Check your connection and try again.',
  });

  @override
  List<Object?> get props => [message];
}

class ScannerInvalidQr extends ScannerEvent {
  const ScannerInvalidQr();
}

class ScannerReset extends ScannerEvent {
  const ScannerReset();
}
