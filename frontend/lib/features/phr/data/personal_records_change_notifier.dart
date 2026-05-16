import 'package:flutter/foundation.dart';

/// Broadcasts successful personal-record writes so dependent screens can refetch.
class PersonalRecordsChangeNotifier {
  PersonalRecordsChangeNotifier._();

  static final ValueNotifier<int> notifier = ValueNotifier<int>(0);

  static void notifyRecordSaved() {
    notifier.value++;
  }
}
