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
}
