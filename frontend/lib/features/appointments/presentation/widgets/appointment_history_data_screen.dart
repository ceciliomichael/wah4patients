import 'dart:async';

import 'package:flutter/material.dart';

import '../../../auth/domain/auth_session.dart';
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
        _content = HealthRecordScreenContent(
          title: appointmentHistoryScreenContentShell.title,
          searchHint: appointmentHistoryScreenContentShell.searchHint,
          filterOptions: appointmentHistoryScreenContentShell.filterOptions,
          helpTitle: appointmentHistoryScreenContentShell.helpTitle,
          helpMessages: appointmentHistoryScreenContentShell.helpMessages,
          emptyTitle: appointmentHistoryScreenContentShell.emptyTitle,
          emptyMessage: appointmentHistoryScreenContentShell.emptyMessage,
          entries: response.records
              .map(mapAppointmentHistoryResponseToEntry)
              .toList(growable: false),
        );
        _isLoading = false;
      });
    } on AppointmentHistoryApiException catch (error) {
      _handleLoadFailure(error.message);
    } catch (_) {
      _handleLoadFailure(
        'Unable to load consultation history. Please try again.',
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
      title: 'Consultation History',
      searchHint: 'Search consultations',
      filterOptions: <String>[
        'All',
        'Scheduled',
        'Completed',
        'Cancelled',
        'No Show',
      ],
      helpTitle: 'Consultation History Help',
      helpMessages: <String>[
        'Search by consultation type, provider, location, or note text.',
        'Use the status filter to narrow the history list.',
        'Tap any card to review the stored summary and supporting details.',
      ],
      emptyTitle: 'No matching consultations',
      emptyMessage: 'Try a different search term or status filter.',
      entries: <HealthRecordEntry>[],
    );
