import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/patient_service.dart';
import '../services/arduino_service.dart';
import 'add_patient_screen.dart';
import 'patient_details_screen.dart';
import 'robot_kiosk_screen.dart';

class NurseHomeScreen extends StatelessWidget {
  const NurseHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientService = Provider.watch<PatientService>(context);
    final arduinoService = Provider.watch<ArduinoService>(context);
    final patients = patientService.patients;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6F9),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF00796B),
          title: Row(
            children: [
              const Icon(Icons.local_hospital, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'روبوت التمريض الذكي',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'لوحة تحكم طاقم التمريض',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // زر التبديل إلى وضع شاشة الروبوت (التابلت)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB300),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.smart_toy, size: 20),
                label: const Text('شاشة الروبوت', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RobotKioskScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // شريط حالة الربط بالأردوينو
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: arduinoService.isConnected
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              child: Row(
                children: [
                  Icon(
                    arduinoService.isConnected ? Icons.check_circle : Icons.bluetooth_searching,
                    color: arduinoService.isConnected ? Colors.green[700] : Colors.orange[800],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      arduinoService.connectionStatus,
                      style: TextStyle(
                        fontSize: 13,
                        color: arduinoService.isConnected ? Colors.green[900] : Colors.orange[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!arduinoService.isConnected)
                    TextButton(
                      onPressed: () => arduinoService.connectToRobot('00:21:13:01:4F:92'),
                      child: const Text('اتصال بـ HC-05'),
                    )
                  else
                    TextButton(
                      onPressed: () => arduinoService.disconnect(),
                      child: const Text('قطع الاتصال', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),

            // عنوان قائمة المرضى
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'قائمة المرضى المقيمين (${patients.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  const Chip(
                    label: Text('محدث لحظياً', style: TextStyle(fontSize: 11, color: Colors.white)),
                    backgroundColor: Color(0xFF00796B),
                  ),
                ],
              ),
            ),

            // بطاقات المرضى
            Expanded(
              child: patients.isEmpty
                  ? const Center(
                      child: Text(
                        'لا يوجد مرضى مسجلين حالياً.\nاضغط على زر (+) لإضافة مريض.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        final dischargeFormat =
                            DateFormat('yyyy/MM/dd - hh:mm a').format(patient.dischargeDate);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PatientDetailsScreen(patientId: patient.id),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: const Color(0xFF00796B).withOpacity(0.15),
                                        child: const Icon(Icons.person, color: Color(0xFF00796B), size: 28),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              patient.name,
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.teal.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                patient.roomNumber,
                                                style: TextStyle(
                                                  color: Colors.teal.shade800,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (val) {
                                          if (val == 'select_robot') {
                                            patientService.selectPatientForRobot(patient.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('تم اختيار ${patient.name} للعرض على شاشة الروبوت')),
                                            );
                                          } else if (val == 'delete') {
                                            patientService.deletePatient(patient.id);
                                          }
                                        },
                                        itemBuilder: (_) => [
                                          const PopupMenuItem(
                                            value: 'select_robot',
                                            child: Text('عرض على شاشة الروبوت'),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('حذف المريض', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    children: [
                                      const Icon(Icons.exit_to_app, size: 16, color: Colors.deepOrange),
                                      const SizedBox(width: 6),
                                      Text(
                                        'ميعاد الخروج المتوقع: $dischargeFormat',
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.medication, size: 16, color: Colors.indigo),
                                      const SizedBox(width: 6),
                                      Text(
                                        'عدد الأدوية المسجلة: ${patient.medications.length}',
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'تفاصيل وجدول الأدوية ←',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF00796B),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add),
          label: const Text('إضافة مريض جديد', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddPatientScreen()),
            );
          },
        ),
      ),
    );
  }
}
