import 'package:flutter/material.dart';

import '../models/appointment_booking_models.dart';
import 'appointment_booking_screen.dart';

class TeleconsultationScreen extends StatelessWidget {
  const TeleconsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppointmentBookingScreen(
      content: teleconsultationAppointmentContent,
    );
  }
}
