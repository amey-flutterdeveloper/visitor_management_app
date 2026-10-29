import 'package:equatable/equatable.dart';

class Visitor extends Equatable {
  const Visitor({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
  });

  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String visitorType;
  final String project;
  final String purpose;
  final String status;
  final String createdAt;
  final String? checkInTime;
  final String? checkOutTime;

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      mobile: (json['mobile'] ?? '').toString(),
      email: json['email']?.toString(),
      visitorType:
          (json['visitor_type'] ?? json['visitorType'] ?? 'Other').toString(),
      project: (json['project'] ?? 'Project A').toString(),
      purpose: (json['purpose'] ?? '').toString(),
      status: (json['status'] ?? 'Registered').toString(),
      createdAt: (json['created_at'] ??
              json['createdAt'] ??
              DateTime.now().toIso8601String())
          .toString(),
      checkInTime: json['check_in_time']?.toString(),
      checkOutTime: json['check_out_time']?.toString(),
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    return {
      if (includeId) 'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'visitor_type': visitorType,
      'project': project,
      'purpose': purpose,
      'status': status,
      'created_at': createdAt,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
    };
  }

  Visitor copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? visitorType,
    String? project,
    String? purpose,
    String? status,
    String? createdAt,
    String? checkInTime,
    String? checkOutTime,
    bool clearEmail = false,
    bool clearCheckIn = false,
    bool clearCheckOut = false,
  }) {
    return Visitor(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: clearEmail ? null : (email ?? this.email),
      visitorType: visitorType ?? this.visitorType,
      project: project ?? this.project,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      checkInTime: clearCheckIn ? null : (checkInTime ?? this.checkInTime),
      checkOutTime: clearCheckOut ? null : (checkOutTime ?? this.checkOutTime),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        mobile,
        email,
        visitorType,
        project,
        purpose,
        status,
        createdAt,
        checkInTime,
        checkOutTime,
      ];
}
