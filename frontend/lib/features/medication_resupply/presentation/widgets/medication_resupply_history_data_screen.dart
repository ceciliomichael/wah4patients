import 'dart:async';

import 'package:flutter/material.dart';

import '../../../auth/domain/auth_session.dart';
import '../../data/medication_resupply_api_client.dart';
import '../mappers/medication_resupply_history_mapper.dart';
import '../models/medication_resupply_models.dart';
import 'medication_resupply_history_screen_template.dart';

class MedicationResupplyHistoryDataScreen extends StatefulWidget {
  const MedicationResupplyHistoryDataScreen({super.key});

  @override
  State<MedicationResupplyHistoryDataScreen> createState() =>
      _MedicationResupplyHistoryDataScreenState();
}

class _MedicationResupplyHistoryDataScreenState
    extends State<MedicationResupplyHistoryDataScreen> {
  late ResupplyHistoryScreenContent _content;
  bool _isLoading = true;
  String? _loadErrorMessage;

  @override
  void initState() {
    super.initState();
    _content = resupplyHistoryScreenContentShell;
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
        throw const MedicationResupplyApiException(
          'Your session is unavailable. Please sign in again.',
        );
      }

      final response = await MedicationResupplyApiClient.instance
          .getHistoryRecords(accessToken: accessToken);

      if (!mounted) {
        return;
      }

      setState(() {
        _content = _content.copyWith(
          entries: mapMedicationResupplyHistoryRecords(response),
        );
        _isLoading = false;
      });
    } on MedicationResupplyApiException catch (error) {
      _handleLoadFailure(error.message);
    } catch (_) {
      _handleLoadFailure(
        'Unable to load prescription history. Please try again.',
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
    return MedicationResupplyHistoryScreenTemplate(
      content: _content,
      isLoading: _isLoading,
      loadErrorMessage: _loadErrorMessage,
      onRetry: _retry,
    );
  }
}
