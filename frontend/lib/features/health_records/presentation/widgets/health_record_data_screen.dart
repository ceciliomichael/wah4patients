import 'dart:async';

import 'package:flutter/material.dart';

import '../../../auth/domain/auth_session.dart';
import '../../data/health_records_api_client.dart';
import '../mappers/health_record_entry_mapper.dart';
import '../models/health_record_models.dart';
import 'health_record_screen_template.dart';

class HealthRecordDataScreen extends StatefulWidget {
  const HealthRecordDataScreen({
    super.key,
    required this.section,
    required this.content,
  });

  final HealthRecordSection section;
  final HealthRecordScreenContent content;

  @override
  State<HealthRecordDataScreen> createState() => _HealthRecordDataScreenState();
}

class _HealthRecordDataScreenState extends State<HealthRecordDataScreen> {
  late HealthRecordScreenContent _content;
  bool _isLoading = true;
  String? _loadErrorMessage;

  @override
  void initState() {
    super.initState();
    _content = widget.content;
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
        throw const HealthRecordsApiException(
          'Your session is unavailable. Please sign in again.',
        );
      }

      final response = await HealthRecordsApiClient.instance.getRecords(
        section: widget.section,
        accessToken: accessToken,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _content = HealthRecordScreenContent(
          title: widget.content.title,
          searchHint: widget.content.searchHint,
          filterOptions: widget.content.filterOptions,
          helpTitle: widget.content.helpTitle,
          helpMessages: widget.content.helpMessages,
          emptyTitle: widget.content.emptyTitle,
          emptyMessage: widget.content.emptyMessage,
          entries: response.records
              .map(mapHealthRecordResponseToEntry)
              .toList(growable: false),
        );
        _isLoading = false;
      });
    } on HealthRecordsApiException catch (error) {
      _handleLoadFailure(error.message);
    } catch (_) {
      _handleLoadFailure('Unable to load health records. Please try again.');
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
