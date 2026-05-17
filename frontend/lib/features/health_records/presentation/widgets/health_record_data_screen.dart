import 'dart:async';

import 'package:flutter/material.dart';

import '../../../auth/domain/auth_session.dart';
import '../../data/health_records_api_client.dart';
import '../../data/health_records_repository.dart';
import '../mappers/health_record_entry_mapper.dart';
import '../models/health_record_models.dart';
import 'health_record_screen_template.dart';

class HealthRecordDataScreen extends StatefulWidget {
  const HealthRecordDataScreen({
    super.key,
    required this.section,
    required this.content,
    this.repository,
  });

  final HealthRecordSection section;
  final HealthRecordScreenContent content;
  final HealthRecordsRepository? repository;

  @override
  State<HealthRecordDataScreen> createState() => _HealthRecordDataScreenState();
}

class _HealthRecordDataScreenState extends State<HealthRecordDataScreen> {
  late final HealthRecordsRepository _repository;
  late HealthRecordScreenContent _content;
  bool _isLoading = true;
  String? _loadErrorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? HealthRecordsRepository();
    _content = widget.content;
    unawaited(_loadContent());
  }

  Future<void> _loadContent() async {
    final cacheKey = _healthRecordsCacheKey();
    final cachedRecords = await _repository.loadCachedRecords(
      cacheKey: cacheKey,
      section: widget.section,
    );

    if (mounted && cachedRecords != null) {
      setState(() {
        _content = _contentWithRecords(cachedRecords);
        _isLoading = false;
        _loadErrorMessage = null;
      });
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = cachedRecords == null;
      _loadErrorMessage = null;
    });

    try {
      final accessToken = AuthSession.accessToken?.trim() ?? '';
      if (accessToken.isEmpty) {
        throw const HealthRecordsApiException(
          'Your session is unavailable. Please sign in again.',
        );
      }

      final records = await _repository.loadRecords(
        section: widget.section,
        accessToken: accessToken,
        cacheKey: cacheKey,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (records.isNotEmpty || cachedRecords == null) {
          _content = _contentWithRecords(records);
        }
        _isLoading = false;
      });
    } on HealthRecordsApiException catch (error) {
      _handleLoadFailure(error.message);
    } catch (_) {
      _handleLoadFailure('Unable to load health records. Please try again.');
    }
  }

  String _healthRecordsCacheKey() {
    final userId = AuthSession.userId?.trim() ?? '';
    if (userId.isNotEmpty) {
      return userId;
    }
    return 'anonymous';
  }

  HealthRecordScreenContent _contentWithRecords(
    List<HealthRecordResponse> records,
  ) {
    return HealthRecordScreenContent(
      title: widget.content.title,
      searchHint: widget.content.searchHint,
      filterOptions: widget.content.filterOptions,
      helpTitle: widget.content.helpTitle,
      helpMessages: widget.content.helpMessages,
      emptyTitle: widget.content.emptyTitle,
      emptyMessage: widget.content.emptyMessage,
      entries: records.map(mapHealthRecordResponseToEntry).toList(growable: false),
    );
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
