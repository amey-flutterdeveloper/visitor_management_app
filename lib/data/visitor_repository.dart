import '../models/visitor.dart';
import 'visitor_api.dart';

class VisitorRepository {
  VisitorRepository({VisitorApi? api}) : _api = api ?? VisitorApi();

  final VisitorApi _api;

  Future<List<Visitor>> getVisitors() {
    return _api.getVisitors();
  }

  Future<Visitor> getVisitor(String id) {
    return _api.getVisitor(id);
  }

  Future<Visitor> createVisitor(Visitor visitor) {
    return _api.createVisitor(visitor);
  }

  Future<Visitor> updateVisitor(Visitor visitor) {
    return _api.updateVisitor(visitor);
  }

  Future<void> deleteVisitor(String id) {
    return _api.deleteVisitor(id);
  }

  Future<Visitor> checkIn(Visitor visitor) {
    if (visitor.status != 'Registered') {
      throw const ApiException(
        'Only registered visitors can check in.',
      );
    }

    final updatedVisitor = visitor.copyWith(
      status: 'Checked In',
      checkInTime: DateTime.now().toIso8601String(),
    );

    return updateVisitor(updatedVisitor);
  }

  Future<Visitor> checkOut(Visitor visitor) {
    if (visitor.status != 'Checked In') {
      throw const ApiException(
        'Only checked-in visitors can check out.',
      );
    }

    final updatedVisitor = visitor.copyWith(
      status: 'Checked Out',
      checkOutTime: DateTime.now().toIso8601String(),
    );

    return updateVisitor(updatedVisitor);
  }

  void dispose() {
    _api.dispose();
  }
}
