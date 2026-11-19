import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../services/patient_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  final _diagnosisController = TextEditingController();

  DateTime _dischargeDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _dischargeTime = const TimeOfDay(hour: 12, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  Future<void> _pickDischargeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dischargeDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dischargeDate = picked;
      });
    }
  }

  Future<void> _pickDischargeTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dischargeTime,
    );
    if (picked != null) {
      setState(() {
        _dischargeTime = picked;
      });
    }
  }

  void _savePatient() {
    if (_formKey.currentState!.validate()) {
      final fullDischargeDateTime = DateTime(
        _dischargeDate.year,
        _dischargeDate.month,
        _dischargeDate.day,
        _dischargeTime.hour,
        _dischargeTime.minute,
      );

      Provider.of<PatientService>(context, listen: false).addPatient(
        name: _nameController.text.trim(),
        roomNumber: _roomController.text.trim(),
        diagnosis: _diagnosisController.text.trim(),
        dischargeDate: fullDischargeDateTime,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تسجيل بيانات المريض بنجاح!'),
          backgroundColor: Colors.teal,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd').format(_dischargeDate);
    final timeFormat = _dischargeTime.format(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF00796B),
          foregroundColor: Colors.white,
          title: const Text('تسجيل مريض جديد'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'اسم المريض بالكامل *',
                            prefixIcon: Icon(Icons.person, color: Color(0xFF00796B)),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'يرجى إدخال اسم المريض' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _roomController,
                          decoration: const InputDecoration(
                            labelText: 'رقم الغرفة / السرير * (مثال: غرفة 204 - سرير 1)',
                            prefixIcon: Icon(Icons.meeting_room, color: Color(0xFF00796B)),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null || value.isEmpty ? 'يرجى إدخال رقم الغرفة' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _diagnosisController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'التشخيص الطبي أو ملاحظات التمريض',
                            prefixIcon: Icon(Icons.note_alt, color: Color(0xFF00796B)),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ميعاد الخروج
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_month, color: Colors.deepOrange),
                            SizedBox(width: 8),
                            Text(
                              'ميعاد الخروج المتوقع من المستشفى',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.date_range),
                                label: Text(dateFormat),
                                onPressed: _pickDischargeDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.access_time),
                                label: Text(timeFormat),
                                onPressed: _pickDischargeTime,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check_circle, size: 22),
                  label: const Text(
                    'حفظ بيانات المريض والبدء بإضافة الأدوية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _savePatient,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
