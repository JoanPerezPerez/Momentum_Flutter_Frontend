// screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:momentum/controllers/req_appointmentscreen_controller.dart';

class ReqAppointmentscreen extends StatelessWidget {
  final ReqAppointmentscreenController controller = Get.put(ReqAppointmentscreenController());
  

   ReqAppointmentscreen({super.key}) {
    final args = Get.arguments as Map<String, dynamic>;
    controller.setParams(
      business: args['businessId'].toString() ?? '',
      service: args['serviceType'].toString() ?? '',
    );
    controller.fetchSlots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar cita')),
      body: Column(
        children: [
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Desde: ${controller.date1.value.toLocal().toString().split(' ')[0]}"),
                  Text("Hasta: ${controller.date2.value.toLocal().toString().split(' ')[0]}"),
                ],
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                child: const Text("Seleccionar desde"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.date1.value,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    controller.date1.value = picked;
                  }
                },
              ),
              ElevatedButton(
                child: const Text("Seleccionar hasta"),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.date2.value,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    controller.date2.value = picked;
                  }
                },
              ),
              ElevatedButton(
                child: const Text("Buscar"),
                onPressed: controller.fetchSlots,
              ),
            ],
          ),
          Expanded(
            child: Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : SfCalendar(
                    view: CalendarView.week,
                    dataSource: _getDataSource(controller.slots),
                    onTap: (details) {
                      if (details.appointments != null &&
                          details.appointments!.isNotEmpty) {
                        final selected = details.appointments!.first;
                        controller.createAppointment(selected);
                      }
                    },
                  )),
          ),
        ],
      ),
    );
  }

  _CalendarDataSource _getDataSource(List<Appointment> appointments) {
    return _CalendarDataSource(appointments);
  }
}

class _CalendarDataSource extends CalendarDataSource {
  _CalendarDataSource(List<Appointment> source) {
    appointments = source;
  }
}
