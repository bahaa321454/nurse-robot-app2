import 'package:flutter/foundation.dart';

/// كلاس لإدارة الاتصال بين تابلت الأندرويد وبوردة الأردوينو
/// يدعم وضعين: وضع الاتصال الفعلي (Bluetooth / USB) والوضع التجريبي (Simulation)
class ArduinoService extends ChangeNotifier {
  bool _isConnected = false;
  String _connectionStatus = 'غير متصل بالأردوينو';
  String _lastCommandSent = 'لا يوجد';
  String _lastReceived = '';

  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;
  String get lastCommandSent => _lastCommandSent;
  String get lastReceived => _lastReceived;

  // محاكاة الاتصال أو الربط مع HC-05
  void connectToRobot(String deviceAddress) async {
    _connectionStatus = 'جاري الاتصال بالأردوينو عبر البلوتوث...';
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));
    _isConnected = true;
    _connectionStatus = 'متصل بنجاح بروبوت التمريض (HC-05)';
    notifyListeners();
  }

  void disconnect() {
    _isConnected = false;
    _connectionStatus = 'تم قطع الاتصال بالأردوينو';
    notifyListeners();
  }

  // إرسال أمر تشغيل إنذار التنبيه بالدواء (Buzzer)
  void triggerMedicationAlarm() {
    _sendCommand('A', 'تشغيل جرس إنذار ميعاد الدواء');
  }

  // إرسال أمر فتح صندوق توزيع الدواء في الروبوت (Servo Open)
  void openMedicineDispenser() {
    _sendCommand('O', 'فتح درج/صندوق الدواء (Servo: 90°)');
  }

  // إرسال أمر إغلاق صندوق الدواء (Servo Close)
  void closeMedicineDispenser() {
    _sendCommand('C', 'إغلاق درج الدواء (Servo: 0°)');
  }

  // إرسال كود الغرفة المطلوب أن يتوجه إليها الروبوت
  void sendTargetRoom(String roomCode) {
    _sendCommand('R:$roomCode', 'أمر التحرك لغرفة: $roomCode');
  }

  void _sendCommand(String cmd, String description) {
    _lastCommandSent = '$description (كود: $cmd)';
    debugPrint('Arduino Command Sent -> $cmd');
    notifyListeners();
  }
}
