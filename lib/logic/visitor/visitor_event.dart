import 'package:equatable/equatable.dart';
import 'package:visitor_management_app/models/visitor.dart';

abstract class VisitorEvent extends Equatable {
  const VisitorEvent();

  @override
  List<Object?> get props => [];
}

class VisitorsRequested extends VisitorEvent {
  const VisitorsRequested();
}

class VisitorSaved extends VisitorEvent {
  const VisitorSaved(this.visitor);

  final Visitor visitor;

  @override
  List<Object?> get props => [visitor];
}

class VisitorDeleted extends VisitorEvent {
  const VisitorDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class VisitorCheckInRequested extends VisitorEvent {
  const VisitorCheckInRequested(this.visitor);

  final Visitor visitor;

  @override
  List<Object?> get props => [visitor];
}

class VisitorCheckOutRequested extends VisitorEvent {
  const VisitorCheckOutRequested(this.visitor);

  final Visitor visitor;

  @override
  List<Object?> get props => [visitor];
}

class VisitorByIdRequested extends VisitorEvent {
  const VisitorByIdRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class VisitorSearchChanged extends VisitorEvent {
  const VisitorSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
