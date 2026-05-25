import 'dart:async';

import 'package:flutter/material.dart';

import '../../../auth/domain/auth_session.dart';
import '../../data/appointment_history_local_cache.dart';
import '../../../health_records/presentation/models/health_record_models.dart';
import '../../../health_records/presentation/widgets/health_record_screen_template.dart';
import '../../data/appointment_history_api_client.dart';
import '../mappers/appointment_history_entry_mapper.dart';

class AppointmentHistoryDataScreen extends StatefulWidget {
  const AppointmentHistoryDataScreen({super.key});

  @override
  State<AppointmentHistoryDataScreen> createState() =>
      _AppointmentHistoryDataScreenState();
}

class _AppointmentHistoryDataScreenState extends State<AppointmentHistoryDataScreen> {
  late HealthRecordScreenContent _content;
  bool _isLoading = true;
  String? _loadErrorMessage;

  @override
  void initState() {
    super.initState();
    _content = appointmentHistoryScreenContentShell;
    unawaited(_loadContent());
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _loadErrorMessage = null;
    });

    try {
      final accessToken = AuthSession.accessToken?.trim() ?? '';
      if (accessToken.isEmpty) {
        throw const AppointmentHistoryApiException(
          'Your session is unavailable. Please sign in again.',
        );
      }

      final response = await AppointmentHistoryApiClient.instance
          .getHistoryRecords(accessToken: accessToken);

      if (!mounted) {
        return;
      }

      setState(() {
        final localPendingRecords = AppointmentHistoryLocalCache
            .snapshotForProfile(AuthSession.userId ?? '');
        final recordsByCorrelationId = <String, AppointmentHistoryRecordResponse>{};

        for (final record in localPendingRecords) {
          final lookupKey = record.correlationId.isNotEmpty
              ? record.correlationId
              : (record.gatewayTransactionId.isNotEmpty
                  ? record.gatewayTransactionId
                  : record.id);
          recordsByCorrelationId[lookupKey] = record;
        }
        for (final record in response.records) {
          final lookupKey = record.correlationId.isNotEmpty
              ? record.correlationId
              : (record.gatewayTransactionId.isNotEmpty
                  ? record.gatewayTransactionId
                  : record.id);
          recordsByCorrelationId[lookupKey] = record;
        }

        final entries = recordsByCorrelationId.values.toList(growable: false)
          ..sort((left, right) => right.recordedAt.compareTo(left.recordedAt));

        _content = HealthRecordScreenContent(
          title: appointmentHistoryScreenContentShell.title,
          searchHint: appointmentHistoryScreenContentShell.searchHint,
          filterOptions: appointmentHistoryScreenContentShell.filterOptions,
          helpTitle: appointmentHistoryScreenContentShell.helpTitle,
          helpMessages: appointmentHistoryScreenContentShell.helpMessages,
          emptyTitle: appointmentHistoryScreenContentShell.emptyTitle,
          emptyMessage: appointmentHistoryScreenContentShell.emptyMessage,
          entries: entries.map(mapAppointmentHistoryResponseToEntry).toList(growable: false),
        );
        _isLoading = false;
      });
    } on AppointmentHistoryApiException catch (error) {
      _handleLoadFailure(error.message);
    } catch (_) {
      _handleLoadFailure(
        'Unable to load appointment history. Please try again.',
      );
    }
  }

  void _retry() {
    unawaited(_loadContent());
  }

  void _handleLoadFailure(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
      _loadErrorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HealthRecordScreenTemplate(
      content: _content,
      isLoading: _isLoading,
      loadErrorMessage: _loadErrorMessage,
      onRetry: _retry,
    );
  }
}

const HealthRecordScreenContent appointmentHistoryScreenContentShell =
    HealthRecordScreenContent(
      title: 'Appointment History',
      searchHint: 'Search appointments',
      filterOptions: <String>[
        'All',
        'Pending',
        'Approved',
        'Scheduled',
        'Cancelled',
        'No Show',
      ],
      helpTitle: 'Appointment History Help',
      helpMessages: <String>[
        'Search by appointment type, provider, location, or note text.',
        'Pending appointments appear first until the provider approves them.',
        'Tap any card to review the stored summary and supporting details.',
      ],
      emptyTitle: 'No appointments yet',
      emptyMessage:
          'Send an appointment request and it will appear here as pending.',
      entries: <HealthRecordEntry>[],
    );
