/*
 ==============================================================================
   مشروع روبوت التمريض الذكي | Smart Nurse Robot Controller
   التحكم في بوردة الأردوينو عبر تابلت الأندرويد (Bluetooth HC-05 / USB Serial)
 ==============================================================================
   توصيلات الهاردوير (Pinout Wiring):
   1. موديول البلوتوث HC-05:
      - VCC -> 5V في الأردوينو
      - GND -> GND
      - TXD -> Pin 10 في الأردوينو (SoftwareSerial RX)
      - RXD -> Pin 11 في الأردوينو (SoftwareSerial TX عبر مقسم جهد بسيط)
   
   2. محرك السيرفو لفتح درج الدواء (Medicine Dispenser Servo):
      - سلك الإشارة البرتقالي/الأصفر -> Pin 9
      - الأحمر -> 5V
      - البني/الأسود -> GND

   3. جرس الإنذار (Buzzer) للتنبيه بميعاد الدواء:
      - القطب الموجب (+) -> Pin 8
      - القطب السالب (-) -> GND

   4. ليدات الحالة (Status LEDs):
      - ليد أخضر (تم أخذ الدواء / جاهز) -> Pin 7
      - ليد أحمر/أصفر (تنبيه ميعاد الدواء) -> Pin 6
 ==============================================================================
*/

#include <SoftwareSerial.h>
#include <Servo.h>

// إعداد بنز البلوتوث (RX, TX)
SoftwareSerial bluetooth(10, 11); 

// إعداد السيرفو لدرج الدواء
Servo dispenserServo;

// تعريف البنز
const int SERVO_PIN  = 9;
const int BUZZER_PIN = 8;
const int LED_GREEN  = 7;
const int LED_ALERT  = 6;

// زوايا فتح وإغلاق درج الدواء
const int SERVO_CLOSED = 0;   // الدرج مغلق
const int SERVO_OPENED = 90;  // الدرج مفتوح للمريض

void setup() {
  // تهيئة الاتصال التسلسلي مع الكمبيوتر ومع البلوتوث
  Serial.begin(9600);
  bluetooth.begin(9600);

  // تهيئة البنز كمخرجات
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_ALERT, OUTPUT);

  // توصيل السيرفو وضبطه على الوضع المغلق
  dispenserServo.attach(SERVO_PIN);
  dispenserServo.write(SERVO_CLOSED);

  // إشارة بدء التشغيل (صوت قصير وليد أخضر)
  digitalWrite(LED_GREEN, HIGH);
  tone(BUZZER_PIN, 1000, 150);
  delay(200);

  Serial.println("=========================================");
  Serial.println("Smart Nurse Robot Controller Ready!");
  Serial.println("Waiting for commands from Android Tablet...");
  Serial.println("=========================================");
}

void loop() {
  // استقبال الأوامر إما من البلوتوث أو عبر كابل الـ USB (Serial Monitor)
  char command = 0;

  if (bluetooth.available()) {
    command = bluetooth.read();
  } else if (Serial.available()) {
    command = Serial.read();
  }

  if (command != 0) {
    executeCommand(command);
  }
}

// تنفيذ الأوامر القادمة من تطبيق التابلت
void executeCommand(char cmd) {
  Serial.print("Received Command: ");
  Serial.println(cmd);

  switch (cmd) {
    // ----------------------------------------------------
    // أمر 'A': تشغيل إنذار التنبيه بميعاد الدواء (Alarm / Buzzer)
    // ----------------------------------------------------
    case 'A':
    case 'a':
      Serial.println("Action: Triggering Medication Alarm...");
      digitalWrite(LED_ALERT, HIGH);
      digitalWrite(LED_GREEN, LOW);
      playMedicationAlarm();
      bluetooth.println("ACK:ALARM_PLAYED");
      break;

    // ----------------------------------------------------
    // أمر 'O': فتح درج / صندوق الدواء (Open Dispenser)
    // ----------------------------------------------------
    case 'O':
    case 'o':
      Serial.println("Action: Opening Medicine Dispenser...");
      dispenserServo.write(SERVO_OPENED);
      digitalWrite(LED_ALERT, HIGH);
      // نغمة قصيرة لتأكيد الفتح
      tone(BUZZER_PIN, 1500, 100);
      bluetooth.println("ACK:DISPENSER_OPENED");
      break;

    // ----------------------------------------------------
    // أمر 'C': إغلاق درج الدواء بعد تناول المريض له (Close Dispenser)
    // ----------------------------------------------------
    case 'C':
    case 'c':
      Serial.println("Action: Closing Medicine Dispenser...");
      dispenserServo.write(SERVO_CLOSED);
      digitalWrite(LED_ALERT, LOW);
      digitalWrite(LED_GREEN, HIGH);
      // نغمة تأكيد النجاح
      tone(BUZZER_PIN, 2000, 150);
      bluetooth.println("ACK:DISPENSER_CLOSED");
      break;

    // ----------------------------------------------------
    // أمر اختبار أو فحص الاتصال
    // ----------------------------------------------------
    case 'T':
    case 't':
      Serial.println("Action: Ping / Test Connection");
      tone(BUZZER_PIN, 800, 80);
      bluetooth.println("ACK:PONG_OK");
      break;

    default:
      Serial.print("Unknown Command: ");
      Serial.println(cmd);
      break;
  }
}

// نغمة جرس إنذار ميعاد الدواء
void playMedicationAlarm() {
  for (int i = 0; i < 3; i++) {
    tone(BUZZER_PIN, 1200, 200);
    delay(250);
    tone(BUZZER_PIN, 1600, 200);
    delay(250);
  }
}
