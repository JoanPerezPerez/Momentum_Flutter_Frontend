
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:momentum/models/appointment_model.dart';

class AppointmentPopup extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentPopup({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(appointment.title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${appointment.inTime.hour}:${appointment.inTime.minute.toString().padLeft(2, '0')}'),
            Text(appointment.description ?? ''),
          ],
        ),
      ),
    );
  }
}
