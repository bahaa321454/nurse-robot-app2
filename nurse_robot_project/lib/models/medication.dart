class Medication {
  final String id;
  final String name;
  final String type; // أقراص، كبسولات، شراب، حقن، قطرة
  final String dosage; // مثلا: قرص واحد بعد الأكل
  final String time; // مثلا: 08:00 AM
  final String? imagePath; // مسار الصورة المحفوظة في الجهاز
  final String instructions; // تعليمات إضافية للمريض
  bool isTaken; // هل المريض أخذ الدواء؟

  Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.dosage,
    required this.time,
    this.imagePath,
    this.instructions = '',
    this.isTaken = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'dosage': dosage,
      'time': time,
      'imagePath': imagePath,
      'instructions': instructions,
      'isTaken': isTaken,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? 'أقراص',
      dosage: map['dosage'] ?? '',
      time: map['time'] ?? '',
      imagePath: map['imagePath'],
      instructions: map['instructions'] ?? '',
      isTaken: map['isTaken'] ?? false,
    );
  }
}
