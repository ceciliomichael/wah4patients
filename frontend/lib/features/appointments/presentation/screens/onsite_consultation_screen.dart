import 'package:flutter/material.dart';

import '../models/appointment_booking_models.dart';
import 'appointment_booking_screen.dart';

class OnsiteConsultationScreen extends StatelessWidget {
  const OnsiteConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppointmentBookingScreen(content: onsiteAppointmentContent);
  }
}
