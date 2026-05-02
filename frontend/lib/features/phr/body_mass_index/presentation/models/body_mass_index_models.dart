import '../../../data/personal_records_api_client.dart';

enum BmiUnitSystem { metric, imperial }

enum BmiGender { male, female, other }

extension BmiGenderLabel on BmiGender {
  String get label => switch (this) {
    BmiGender.male => 'Male',
    BmiGender.female => 'Female',
    BmiGender.other => 'Other',
  };
}

class BodyMassIndexHistoryEntry {
  const BodyMassIndexHistoryEntry({
    required this.recordedAt,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.category,
    required this.unitSystem,
    required this.gender,
    required this.age,
  });

  final DateTime recordedAt;
  final double weight;
  final double height;
  final double bmi;
  final String category;
  final BmiUnitSystem unitSystem;
  final BmiGender gender;
  final int age;

  factory BodyMassIndexHistoryEntry.fromRecord(BmiRecordResponse record) {
    final unitSystem = record.measurementSystem == 'imperial'
        ? BmiUnitSystem.imperial
        : BmiUnitSystem.metric;
    final weight = unitSystem == BmiUnitSystem.metric
        ? record.weightKg
        : record.weightKg * 2.2046226218;
    final height = unitSystem == BmiUnitSystem.metric
        ? record.heightCm
        : record.heightCm / 2.54;

    return BodyMassIndexHistoryEntry(
      recordedAt: record.recordedAt,
      weight: weight,
      height: height,
      bmi: record.bmiValue,
      category: _bmiCategoryForValue(record.bmiValue),
      unitSystem: unitSystem,
      gender: BmiGender.other,
      age: 0,
    );
  }
}

String _bmiCategoryForValue(double bmi) {
  if (bmi < 18.5) {
    return 'Underweight';
  }
  if (bmi < 25) {
    return 'Normal';
  }
  if (bmi < 30) {
    return 'Overweight';
  }
  return 'Obesity';
}
