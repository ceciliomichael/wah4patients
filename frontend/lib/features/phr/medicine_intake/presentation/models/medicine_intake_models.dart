import '../../domain/medicine_status.dart';

class MedicineIntakeEntry {
  const MedicineIntakeEntry({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.nextDose,
    required this.notes,
    required this.status,
  });

  final String id;
  final String name;
  final String dosage;
  final String schedule;
  final String nextDose;
  final String notes;
  final MedicineStatus status;

  MedicineIntakeEntry copyWith({
    String? id,
    String? name,
    String? dosage,
    String? schedule,
    String? nextDose,
    String? notes,
    MedicineStatus? status,
  }) {
    return MedicineIntakeEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      schedule: schedule ?? this.schedule,
      nextDose: nextDose ?? this.nextDose,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}

class MedicineIntakeDraft {
  const MedicineIntakeDraft({
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.nextDose,
    required this.notes,
    required this.status,
  });

  final String name;
  final String dosage;
  final String schedule;
  final String nextDose;
  final String notes;
  final MedicineStatus status;
}
