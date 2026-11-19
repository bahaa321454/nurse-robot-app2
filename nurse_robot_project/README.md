# مشروع روبوت التمريض الذكي | Smart Nurse Robot Project

مشروع تخرج / سنوي متكامل يربط بين:
1. **تطبيق موبايل لطاقم التمريض (Nurse Mobile App)**: لإضافة المرضى ومواعيد وجرعات الأدوية وصورها وتاريخ الخروج.
2. **واجهة تابلت الروبوت (Robot Kiosk Screen)**: شاشة أفقية كاملة تثبت على الروبوت، تعرض للمريض اسمه، شكل وصورة علاجه بوضوح، جرعته، وزر تأكيد أخذ الدواء.
3. **متحكم الأردوينو (Arduino Controller)**: للتحكم في هاردوير الروبوت (سيرفو درج الأدوية، جرس الإنذار Buzzer، ليدات الحالة، وموديول البلوتوث HC-05).

---

## هيكل الملفات (Project Structure)

```
nurse_robot_project/
├── lib/
│   ├── main.dart                      # نقطة انطلاق التطبيق وإعداد الثيم والمزودات
│   ├── models/
│   │   ├── patient.dart               # موديل بيانات المريض وموعد الخروج
│   │   └── medication.dart            # موديل بيانات الدواء (الاسم، الجرعة، الصورة، الوقت)
│   ├── services/
│   │   ├── patient_service.dart       # إدارة المرضى والمزامنة اللحظية
│   │   └── arduino_service.dart       # إرسال واستقبال أوامر الأردوينو عبر البلوتوث
│   └── screens/
│       ├── nurse_home_screen.dart     # الصفحة الرئيسية للتمريض (قائمة المرضى وحالة النظام)
│       ├── add_patient_screen.dart    # شاشة تسجيل مريض جديد وتحديد وقت الخروج
│       ├── patient_details_screen.dart# شاشة تفاصيل المريض وإضافة الأدوية وتصويرها
│       └── robot_kiosk_screen.dart    # شاشة تابلت الروبوت (عرض الدواء وتأكيد الجرعة)
├── arduino/
│   └── nurse_robot_controller.ino     # كود الأردوينو للتحكم في السيرفو والبازر والبلوتوث
└── pubspec.yaml                       # مكتبات Flutter
```

---

## 1. تشغيل وتثبيت تطبيق الموبايل (Flutter APK)

### الخطوات:
1. قم بتثبيت [Flutter SDK](https://docs.flutter.dev/get-started/install) و [Android Studio](https://developer.android.com/studio) أو [VS Code].
2. افتح مجلد المشروع في VS Code أو Terminal:
   ```bash
   cd C:\Users\bahaa\.gemini\antigravity\scratch\nurse_robot_project
   ```
3. تنزيل الحزم:
   ```bash
   flutter pub get
   ```
4. لتشغيل التطبيق للتجربة على هاتفك المتصل بالكمبيوتر:
   ```bash
   flutter run
   ```
5. **لتوليد ملف الـ APK وتثبيته على هاتفك وعلى التابلت:**
   ```bash
   flutter build apk --release
   ```
   ستجد ملف الـ APK جاهزاً في المسار:
   `build/app/outputs/flutter-apk/app-release.apk`
   ارسله لهاتفك وللتابلت عبر الواتساب أو كابل الـ USB وثبته مباشرة!

---

## 2. برمجة وتوصيل الأردوينو (Arduino Setup)

### التوصيلات:
| المكون | بن الأردوينو | ملاحظات |
| :--- | :--- | :--- |
| **موديول HC-05 (TX)** | **Pin 10** | SoftwareSerial RX |
| **موديول HC-05 (RX)** | **Pin 11** | SoftwareSerial TX |
| **سيرفو درج الدواء (Servo Signal)** | **Pin 9** | يفتح بزاوية 90 درجة ويقفل بزاوية 0 |
| **جرس الإنذار (Buzzer +)** | **Pin 8** | للتنبيه بميعاد الجرعة |
| **ليد الحالة الأخضر** | **Pin 7** | تم أخذ الجرعة / الروبوت جاهز |
| **ليد التنبيه الأحمر** | **Pin 6** | تنبيه ميعاد الدواء |

### رفع الكود:
1. افتح برنامج **Arduino IDE**.
2. افتح الملف: `arduino/nurse_robot_controller.ino`.
3. اختر نوع البوردة (Arduino Uno أو Nano) والـ Port، ثم اضغط **Upload**.

---

## 3. الأوامر المتبادلة بين التابلت والأردوينو (Protocol)
* `'A'` : تشغيل نغمة إنذار ميعاد الدواء.
* `'O'` : فتح درج الدواء (Servo 90°).
* `'C'` : إغلاق درج الدواء (Servo 0°).
* `'T'` : فحص الاتصال واختبار الاستجابة (Ping/Pong).
