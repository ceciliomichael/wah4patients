import '../../domain/medicine_status.dart';
import '../../../data/personal_records_api_client.dart';

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

  factory MedicineIntakeEntry.fromRecord(MedicationIntakeRecordResponse record) {
    final snapshot = _MedicineSnapshot.fromNotes(record.notes);
    final dosage = snapshot.dosage ?? _formatQuantity(record.quantityValue, record.quantityUnit);
    final schedule = snapshot.schedule ?? _formatDateTime(record.scheduledAt);
    final nextDose = snapshot.nextDose ?? _buildNextDoseLabel(record);
    final notes = snapshot.notes ?? '';

    return MedicineIntakeEntry(
      id: record.id,
      name: record.medicationNameSnapshot,
      dosage: dosage,
      schedule: schedule,
      nextDose: nextDose,
      notes: notes,
      status: medicineStatusFromApi(record.status),
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

String encodeMedicineNotes(MedicineIntakeDraft draft) {
  final buffer = StringBuffer()
    ..writeln('Dosage: ${draft.dosage}')
    ..writeln('Schedule: ${draft.schedule}')
    ..writeln('Next dose: ${draft.nextDose}')
    ..writeln('Notes:')
    ..writeln(draft.notes.trim());

  return buffer.toString().trim();
}

class _MedicineSnapshot {
  const _MedicineSnapshot({
    required this.dosage,
    required this.schedule,
    required this.nextDose,
    required this.notes,
  });

  final String? dosage;
  final String? schedule;
  final String? nextDose;
  final String? notes;

  factory _MedicineSnapshot.fromNotes(String? notes) {
    if (notes == null || notes.trim().isEmpty) {
      return const _MedicineSnapshot(
        dosage: null,
        schedule: null,
        nextDose: null,
        notes: null,
      );
    }

    final lines = notes.split('\n');
    String? dosage;
    String? schedule;
    String? nextDose;
    final freeformNotes = <String>[];
    var isNotesSection = false;

    for (final rawLine in lines) {
      final line = rawLine.trimRight();
      if (line.startsWith('Dosage: ')) {
        dosage = line.substring('Dosage: '.length).trim();
        continue;
      }
      if (line.startsWith('Schedule: ')) {
        schedule = line.substring('Schedule: '.length).trim();
        continue;
      }
      if (line.startsWith('Next dose: ')) {
        nextDose = line.substring('Next dose: '.length).trim();
        continue;
      }
      if (line.trim() == 'Notes:') {
        isNotesSection = true;
        continue;
      }
      if (isNotesSection) {
        freeformNotes.add(line.trim());
      }
    }

    final freeform = freeformNotes.join('\n').trim();

    return _MedicineSnapshot(
      dosage: dosage?.isNotEmpty == true ? dosage : null,
      schedule: schedule?.isNotEmpty == true ? schedule : null,
      nextDose: nextDose?.isNotEmpty == true ? nextDose : null,
      notes: freeform.isNotEmpty ? freeform : null,
    );
  }
}

String _formatQuantity(double? value, String? unit) {
  if (value == null || unit == null || unit.trim().isEmpty) {
    return '—';
  }

  final displayValue = value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  return '$displayValue ${unit.trim()}';
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year;
  final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '$day/$month/$year, ${hour.toString().padLeft(2, '0')}:$minute $period';
}

String _buildNextDoseLabel(MedicationIntakeRecordResponse record) {
  if (record.takenAt != null) {
    return 'Taken ${_formatDateTime(record.takenAt!)}';
  }

  return 'Scheduled ${_formatDateTime(record.scheduledAt)}';
}
