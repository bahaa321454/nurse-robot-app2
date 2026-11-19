import 'medication.dart';

class Patient {
  final String id;
  final String name;
  final String roomNumber;
  final String diagnosis;
  final DateTime admissionDate;
  final DateTime dischargeDate;
  final List<Medication> medications;

  Patient({
    required this.id,
    required this.name,
    required this.roomNumber,
    required this.diagnosis,
    required this.admissionDate,
    required this.dischargeDate,
    List<Medication>? medications,
  }) : medications = medications ?? [];

  // فحص هل جميع أدوية اليوم تم أخذها
  bool get allMedsTaken =>
      medications.isNotEmpty && medications.every((m) => m.isTaken);

  // إيجاد الدواء القادم المطلوب تناوله
  Medication? get nextPendingMedication {
    try {
      return medications.firstWhere((m) => !m.isTaken);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'roomNumber': roomNumber,
      'diagnosis': diagnosis,
      'admissionDate': admissionDate.toIso8601String(),
      'dischargeDate': dischargeDate.toIso8601String(),
      'medications': medications.map((m) => m.toMap()).toList(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      roomNumber: map['roomNumber'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      admissionDate: DateTime.tryParse(map['admissionDate'] ?? '') ?? DateTime.now(),
      dischargeDate: DateTime.tryParse(map['dischargeDate'] ?? '') ??
          DateTime.now().add(const Duration(days: 3)),
      medications: (map['medications'] as List<dynamic>? ?? [])
          .map((m) => Medication.fromMap(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
