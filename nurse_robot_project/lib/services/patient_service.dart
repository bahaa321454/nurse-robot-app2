import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/patient.dart';
import '../models/medication.dart';

class PatientService extends ChangeNotifier {
  final List<Patient> _patients = [];
  final _uuid = const Uuid();

  // المريض المحدد حالياً لعرضه على شاشة التابلت على الروبوت
  String? _selectedPatientIdForRobot;

  List<Patient> get patients => List.unmodifiable(_patients);

  Patient? get robotActivePatient {
    if (_patients.isEmpty) return null;
    if (_selectedPatientIdForRobot != null) {
      return _patients.firstWhere(
        (p) => p.id == _selectedPatientIdForRobot,
        orElse: () => _patients.first,
      );
    }
    return _patients.first;
  }

  PatientService() {
    _loadSampleData();
  }

  void selectPatientForRobot(String patientId) {
    _selectedPatientIdForRobot = patientId;
    notifyListeners();
  }

  void addPatient({
    required String name,
    required String roomNumber,
    required String diagnosis,
    required DateTime dischargeDate,
  }) {
    final newPatient = Patient(
      id: _uuid.v4(),
      name: name,
      roomNumber: roomNumber,
      diagnosis: diagnosis,
      admissionDate: DateTime.now(),
      dischargeDate: dischargeDate,
      medications: [],
    );

    _patients.add(newPatient);
    if (_selectedPatientIdForRobot == null) {
      _selectedPatientIdForRobot = newPatient.id;
    }
    notifyListeners();
  }

  void deletePatient(String patientId) {
    _patients.removeWhere((p) => p.id == patientId);
    if (_selectedPatientIdForRobot == patientId) {
      _selectedPatientIdForRobot = _patients.isNotEmpty ? _patients.first.id : null;
    }
    notifyListeners();
  }

  void addMedication({
    required String patientId,
    required String name,
    required String type,
    required String dosage,
    required String time,
    String? imagePath,
    String instructions = '',
  }) {
    final patientIndex = _patients.indexWhere((p) => p.id == patientId);
    if (patientIndex != -1) {
      final newMed = Medication(
        id: _uuid.v4(),
        name: name,
        type: type,
        dosage: dosage,
        time: time,
        imagePath: imagePath,
        instructions: instructions,
        isTaken: false,
      );

      _patients[patientIndex].medications.add(newMed);
      notifyListeners();
    }
  }

  void toggleMedicationStatus({
    required String patientId,
    required String medicationId,
  }) {
    final patientIndex = _patients.indexWhere((p) => p.id == patientId);
    if (patientIndex != -1) {
      final medIndex = _patients[patientIndex]
          .medications
          .indexWhere((m) => m.id == medicationId);
      if (medIndex != -1) {
        final current = _patients[patientIndex].medications[medIndex];
        current.isTaken = !current.isTaken;
        notifyListeners();
      }
    }
  }

  // بيانات تجريبية واقعية جاهزة للمناقشة والعرض
  void _loadSampleData() {
    final p1 = Patient(
      id: 'patient_01',
      name: 'أحمد محمود إبراهيم',
      roomNumber: 'غرفة 104 - سرير أ',
      diagnosis: 'متابعة ما بعد جراحة المرارة',
      admissionDate: DateTime.now().subtract(const Duration(days: 2)),
      dischargeDate: DateTime.now().add(const Duration(days: 2, hours: 4)),
      medications: [
        Medication(
          id: 'med_01',
          name: 'Augmentin 1g',
          type: 'أقراص مضاد حيوي',
          dosage: 'قرص واحد بعد الغداء',
          time: '02:00 PM',
          instructions: 'يجب تناوله مع كوب ماء كامل بعد وجبة الطعام مباشرة',
          isTaken: false,
        ),
        Medication(
          id: 'med_02',
          name: 'Panadol Extra',
          type: 'أقراص مسكن',
          dosage: 'قرصين عند اللزوم',
          time: '08:00 PM',
          instructions: 'مسكن للآلام والصداع',
          isTaken: true,
        ),
      ],
    );

    final p2 = Patient(
      id: 'patient_02',
      name: 'فاطمة حسن علي',
      roomNumber: 'غرفة 208 - سرير ب',
      diagnosis: 'انتظام ضغط الدم والسكر',
      admissionDate: DateTime.now().subtract(const Duration(days: 1)),
      dischargeDate: DateTime.now().add(const Duration(days: 4)),
      medications: [
        Medication(
          id: 'med_03',
          name: 'Concor 5mg',
          type: 'أقراص ضغط',
          dosage: 'قرص واحد صباحاً',
          time: '09:00 AM',
          instructions: 'يتم تناوله على الريق قبل الإفطار',
          isTaken: false,
        ),
      ],
    );

    _patients.addAll([p1, p2]);
    _selectedPatientIdForRobot = p1.id;
  }
}
