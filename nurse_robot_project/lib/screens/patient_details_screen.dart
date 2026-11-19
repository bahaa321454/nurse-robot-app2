import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../services/patient_service.dart';
import '../services/arduino_service.dart';
import '../models/patient.dart';

class PatientDetailsScreen extends StatelessWidget {
  final String patientId;

  const PatientDetailsScreen({super.key, required this.patientId});

  void _showAddMedicationDialog(BuildContext context, Patient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddMedicationSheet(patientId: patient.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientService = Provider.watch<PatientService>(context);
    final arduinoService = Provider.watch<ArduinoService>(context);

    Patient? patient;
    try {
      patient = patientService.patients.firstWhere((p) => p.id == patientId);
    } catch (_) {
      patient = null;
    }

    if (patient == null) {
      return const Scaffold(
        body: Center(child: Text('المريض غير موجود')),
      );
    }

    final dischargeStr = DateFormat('yyyy/MM/dd - hh:mm a').format(patient.dischargeDate);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFF00796B),
          foregroundColor: Colors.white,
          title: Text(patient.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.cast_connected),
              tooltip: 'تحديد هذا المريض لشاشة الروبوت',
              onPressed: () {
                patientService.selectPatientForRobot(patient!.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم تعيين ${patient.name} على شاشة الروبوت')),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // بطاقة بيانات المريض الرئيسية
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.teal.shade100,
                        child: const Icon(Icons.person, color: Color(0xFF00796B), size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              patient.roomNumber,
                              style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      // زر إرسال الروبوت لغرفة المريض
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB300),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        icon: const Icon(Icons.directions_run, size: 18),
                        label: const Text('إرسال الروبوت', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          arduinoService.sendTargetRoom(patient!.roomNumber);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تم إرسال أمر التوجه إلى ${patient.roomNumber} للأردوينو')),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.exit_to_app, color: Colors.deepOrange, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'ميعاد الخروج: $dischargeStr',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (patient.diagnosis.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.medical_information, color: Colors.blueGrey, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'التشخيص: ${patient.diagnosis}',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // عنوان قائمة الأدوية
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'جدول ومواعيد الأدوية',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('إضافة دواء'),
                    onPressed: () => _showAddMedicationDialog(context, patient!),
                  ),
                ],
              ),
            ),

            // قائمة الأدوية
            Expanded(
              child: patient.medications.isEmpty
                  ? const Center(
                      child: Text(
                        'لم يتم إضافة أدوية لهذا المريض بعد.\nاضغط "إضافة دواء" لتحديد الجدول وصورة الدواء.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: patient.medications.length,
                      itemBuilder: (context, index) {
                        final med = patient.medications[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: med.isTaken ? Colors.green.shade300 : Colors.orange.shade200,
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                // صورة الدواء
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: med.imagePath != null && File(med.imagePath!).existsSync()
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(File(med.imagePath!), fit: BoxFit.cover),
                                        )
                                      : const Icon(Icons.medication, size: 36, color: Color(0xFF00796B)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            med.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              med.type,
                                              style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'الجرعة: ${med.dosage}',
                                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            'الميعاد: ${med.time}',
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                          ),
                                        ],
                                      ),
                                      if (med.instructions.isNotEmpty)
                                        Text(
                                          'ملاحظة: ${med.instructions}',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                ),
                                // زر تبديل حالة الأخذ
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        med.isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
                                        color: med.isTaken ? Colors.green : Colors.grey,
                                        size: 32,
                                      ),
                                      onPressed: () {
                                        patientService.toggleMedicationStatus(
                                          patientId: patient!.id,
                                          medicationId: med.id,
                                        );
                                      },
                                    ),
                                    Text(
                                      med.isTaken ? 'تم التناول' : 'قيد الانتظار',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: med.isTaken ? Colors.green : Colors.orange.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// شيت إضافة دواء وصورة الدواء
class AddMedicationSheet extends StatefulWidget {
  final String patientId;

  const AddMedicationSheet({super.key, required this.patientId});

  @override
  State<AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<AddMedicationSheet> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();

  String _selectedType = 'أقراص';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  String? _pickedImagePath;

  final List<String> _types = ['أقراص', 'كبسولات', 'شراب', 'حقن', 'نقط / قطرة'];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _pickedImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveMedication() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة اسم الدواء')),
      );
      return;
    }

    final formattedTime = _selectedTime.format(context);

    Provider.of<PatientService>(context, listen: false).addMedication(
      patientId: widget.patientId,
      name: _nameCtrl.text.trim(),
      type: _selectedType,
      dosage: _dosageCtrl.text.trim().isEmpty ? 'جرعة واحدة' : _dosageCtrl.text.trim(),
      time: formattedTime,
      imagePath: _pickedImagePath,
      instructions: _instructionsCtrl.text.trim(),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'إضافة دواء جديد لجدول المريض',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم الدواء (مثل Panadol أو Augmentin)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'نوع الدواء',
                        border: OutlineInputBorder(),
                      ),
                      items: _types
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      icon: const Icon(Icons.access_time),
                      label: Text(_selectedTime.format(context)),
                      onPressed: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dosageCtrl,
                decoration: const InputDecoration(
                  labelText: 'الجرعة (مثال: قرص واحد بعد الإفطار)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _instructionsCtrl,
                decoration: const InputDecoration(
                  labelText: 'تعليمات إضافية (مثال: مع كوب ماء دافئ)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 16),

              // اختيار / تصوير شكل الدواء
              const Text(
                'صورة الدواء (لتوضيح شكله للمريض على شاشة الروبوت):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('الكاميرا'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('المعرض'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  const Spacer(),
                  if (_pickedImagePath != null)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.file(File(_pickedImagePath!), fit: BoxFit.cover),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saveMedication,
                child: const Text('حفظ الدواء في جدول المريض', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
