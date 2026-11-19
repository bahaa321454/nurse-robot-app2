import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/patient_service.dart';
import '../services/arduino_service.dart';

/// شاشة تابلت الروبوت (Robot Kiosk Display)
/// مصممة خصيصاً للشاشات الأفقية/التابلت لتعمل على الروبوت
class RobotKioskScreen extends StatelessWidget {
  const RobotKioskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientService = Provider.watch<PatientService>(context);
    final arduinoService = Provider.watch<ArduinoService>(context);
    final currentPatient = patientService.robotActivePatient;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1E293B), // خلفية طبية داكنة فخمة
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              const Icon(Icons.smart_toy, color: Color(0xFF38BDF8), size: 30),
              const SizedBox(width: 12),
              const Text(
                'روبوت التمريض الذكي | Smart Nurse Robot',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Spacer(),
              // اختيار المريض اللي الروبوت واقف عنده حالياً
              if (patientService.patients.isNotEmpty)
                DropdownButton<String>(
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  value: currentPatient?.id,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.tealAccent),
                  underline: const SizedBox(),
                  items: patientService.patients.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text('زيارة: ${p.name} (${p.roomNumber})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      patientService.selectPatientForRobot(val);
                    }
                  },
                ),
            ],
          ),
        ),
        body: currentPatient == null
            ? const Center(
                child: Text(
                  'لا يوجد مريض محدد لعرضه على شاشة الروبوت',
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
              )
            : Column(
                children: [
                  // شريط التحكم بهاردوير الروبوت (الأردوينو)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    color: const Color(0xFF0F172A),
                    child: Row(
                      children: [
                        Icon(
                          arduinoService.isConnected ? Icons.link : Icons.link_off,
                          color: arduinoService.isConnected ? Colors.greenAccent : Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Arduino: ${arduinoService.isConnected ? "متصل (HC-05)" : "غير متصل"}',
                          style: TextStyle(
                            color: arduinoService.isConnected ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'آخر أمر للأردوينو: ${arduinoService.lastCommandSent}',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        const Spacer(),
                        // أزرار التحكم السريع بالأردوينو
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE11D48),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          icon: const Icon(Icons.volume_up, size: 18),
                          label: const Text('جرس إنذار (Buzzer)'),
                          onPressed: () => arduinoService.triggerMedicationAlarm(),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          icon: const Icon(Icons.meeting_room, size: 18),
                          label: const Text('فتح درج الدواء (Servo)'),
                          onPressed: () => arduinoService.openMedicineDispenser(),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('إغلاق الدرج'),
                          onPressed: () => arduinoService.closeMedicineDispenser(),
                        ),
                      ],
                    ),
                  ),

                  // المحتوى الرئيسي لشاشة المريض
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // الجانب الأيمن: بطاقة المريض وموعد الخروج
                          Expanded(
                            flex: 4,
                            child: Card(
                              color: const Color(0xFF334155),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 36,
                                          backgroundColor: Color(0xFF38BDF8),
                                          child: Icon(Icons.person, size: 44, color: Colors.white),
                                        ),
                                        SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'أهلاً بك، شفاك الله وعافاك',
                                              style: TextStyle(color: Colors.white70, fontSize: 14),
                                            ),
                                            Text(
                                              'بطاقة المريض',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      currentPatient.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0284C7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        currentPatient.roomNumber,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Divider(color: Colors.white24),
                                    const SizedBox(height: 12),
                                    // ميعاد الخروج
                                    const Row(
                                      children: [
                                        Icon(Icons.event_available, color: Color(0xFFF59E0B), size: 22),
                                        SizedBox(width: 8),
                                        Text(
                                          'تاريخ الخروج المتوقع من المستشفى:',
                                          style: TextStyle(color: Color(0xFFF59E0B), fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      DateFormat('yyyy/MM/dd - hh:mm a').format(currentPatient.dischargeDate),
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                    if (currentPatient.diagnosis.isNotEmpty)
                                      Text(
                                        'ملاحظات طبية: ${currentPatient.diagnosis}',
                                        style: const TextStyle(color: Colors.white60, fontSize: 13),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          // الجانب الأيسر: الدواء الحالي وشكله وجرعته
                          Expanded(
                            flex: 6,
                            child: _buildMedicationFocusCard(context, currentPatient, patientService, arduinoService),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMedicationFocusCard(
    BuildContext context,
    dynamic currentPatient,
    PatientService patientService,
    ArduinoService arduinoService,
  ) {
    final nextMed = currentPatient.nextPendingMedication;

    if (nextMed == null) {
      return Card(
        color: const Color(0xFF334155),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 80),
              SizedBox(height: 16),
              Text(
                'ممتاز! تم تناول جميع الأدوية المجدولة لهذا اليوم.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'نتمنى لك الشفاء العاجل ودوام الصحة والعافية.',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF38BDF8), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.alarm, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'ميعاد الجرعة: ${nextMed.time}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.tealAccent),
                  ),
                  child: Text(
                    nextMed.type,
                    style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // اسم الدواء وصورته
            Expanded(
              child: Row(
                children: [
                  // صورة الدواء بالحجم الكبير ليتعرف عليه المريض
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: nextMed.imagePath != null && File(nextMed.imagePath!).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(File(nextMed.imagePath!), fit: BoxFit.contain),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.medication, size: 70, color: Color(0xFF38BDF8)),
                                SizedBox(height: 8),
                                Text(
                                  'صورة شكل الدواء',
                                  style: TextStyle(color: Colors.white54, fontSize: 14),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // تفاصيل الجرعة والتعليمات
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nextMed.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.straighten, color: Color(0xFF38BDF8), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'الجرعة المطلوبة: ${nextMed.dosage}',
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              if (nextMed.instructions.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.info_outline, color: Color(0xFFFBBF24), size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'إرشادات: ${nextMed.instructions}',
                                        style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // زر تأكيد أخذ الدواء
            SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.check_circle, size: 28),
                label: const Text(
                  'أخذت الدواء الآن (تم تناول الجرعة)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  patientService.toggleMedicationStatus(
                    patientId: currentPatient.id,
                    medicationId: nextMed.id,
                  );
                  // إغلاق درج الدواء تلقائياً عبر الأردوينو
                  arduinoService.closeMedicineDispenser();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تسجيل أخذ الدواء وتحديث النظام فوراً!'),
                      backgroundColor: Colors.teal,
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
