import 'package:equatable/equatable.dart';
import 'package:visitor_management_app/models/visitor.dart';
import 'package:visitor_management_app/util/visitor_enum.dart';

class VisitorState extends Equatable {
  const VisitorState({
    this.status = VisitorStatus.initial,
    this.visitors = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.selectedVisitor,
    this.notice,
  });

  final VisitorStatus status;
  final List<Visitor> visitors;
  final String searchQuery;
  final String? errorMessage;
  final Visitor? selectedVisitor;
  final String? notice;

  List<Visitor> get filteredVisitors {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return visitors;
    }

    return visitors.where((visitor) {
      return visitor.name.toLowerCase().contains(query) ||
          visitor.mobile.contains(query) ||
          visitor.project.toLowerCase().contains(query) ||
          visitor.status.toLowerCase().contains(query) ||
          visitor.visitorType.toLowerCase().contains(query);
    }).toList();
  }

  int get registeredToday {
    final now = DateTime.now();

    return visitors.where((visitor) {
      final createdAt = DateTime.tryParse(visitor.createdAt)?.toLocal();

      return createdAt != null &&
          createdAt.year == now.year &&
          createdAt.month == now.month &&
          createdAt.day == now.day;
    }).length;
  }

  int get checkedInNow {
    return visitors.where((visitor) {
      return visitor.status == 'Checked In';
    }).length;
  }

  int get checkedOutToday {
    final now = DateTime.now();

    return visitors.where((visitor) {
      final checkOutTime =
          DateTime.tryParse(visitor.checkOutTime ?? '')?.toLocal();

      return checkOutTime != null &&
          checkOutTime.year == now.year &&
          checkOutTime.month == now.month &&
          checkOutTime.day == now.day;
    }).length;
  }

  VisitorState copyWith({
    VisitorStatus? status,
    List<Visitor>? visitors,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    Visitor? selectedVisitor,
    bool clearSelected = false,
    String? notice,
    bool clearNotice = false,
  }) {
    return VisitorState(
      status: status ?? this.status,
      visitors: visitors ?? this.visitors,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedVisitor:
          clearSelected ? null : (selectedVisitor ?? this.selectedVisitor),
      notice: clearNotice ? null : (notice ?? this.notice),
    );
  }

  @override
  List<Object?> get props => [
        status,
        visitors,
        searchQuery,
        errorMessage,
        selectedVisitor,
        notice,
      ];
}
