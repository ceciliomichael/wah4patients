import '../models/medication_resupply_models.dart';
import '../../data/medication_resupply_api_client.dart';

List<ResupplyHistoryEntry> mapMedicationResupplyHistoryRecords(
  MedicationResupplyHistoryResponse response,
) {
  return response.records
      .map(_mapMedicationResupplyHistoryRecord)
      .toList(growable: false);
}

ResupplyHistoryEntry _mapMedicationResupplyHistoryRecord(
  MedicationResupplyHistoryRecordResponse response,
) {
  return ResupplyHistoryEntry(
    id: response.id,
    medicationName: response.medicationName,
    dosage: response.dosage,
    requestDate: _formatRequestDate(response.requestedAt),
    status: ResupplyRequestStatusX.fromApiValue(response.status),
    note: response.note,
  );
}

String _formatRequestDate(String value) {
  final parsed = DateTime.tryParse(value)?.toLocal();
  if (parsed == null) {
    return value;
  }

  const months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
}
