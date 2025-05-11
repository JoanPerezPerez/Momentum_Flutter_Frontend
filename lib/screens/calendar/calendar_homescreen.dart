import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:momentum/controllers/calendar_controller.dart';
import 'package:momentum/screens/calendar/manage_calendars_screen.dart';
import 'package:momentum/services/calendar_service.dart';
import 'package:momentum/widgets/momentum_buttom_nav_bar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as flutter_selection;
import 'package:momentum/models/calendar_model.dart';
import 'package:momentum/models/appointment_model.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarController controller = Get.find<CalendarController>();
  final RxString selectedCalendarId = ''.obs;
  final Rx<flutter_selection.CalendarView> calendarView = flutter_selection.CalendarView.month.obs;
  bool isLoading = true;
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Load calendars and appointments when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
    controller.fetchCalendars(controller.userId.toString());
    fetchAllAppointments(); // Aquí ya es seguro modificar observables
    });
    
  }

  // Method to load all appointments from all calendars
  Future<void> fetchAllAppointments() async {
    setState(() {
      isLoading = true;
    });

    try {
      await controller.fetchAllAppointments(controller.userId.toString());
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading all appointments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Manage Calendars',
            onPressed: () {
              Get.to(() => ManageCalendarsScreen(userId: controller.userId.toString()))?.then((_) {
                // Refresh data when returning from ManageCalendarsScreen
                controller.fetchCalendars(controller.userId.toString());
                fetchAllAppointments();
              });
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Calendar selection row
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: controller.calendars.isNotEmpty 
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.calendars.length,
                    itemBuilder: (context, index) {
                      final calendar = controller.calendars[index];
                      return Obx(() => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                        child: ChoiceChip(
                          label: Text(calendar.name),
                          selected: selectedCalendarId.value == calendar.id,
                          onSelected: (selected) {
                            if (selected) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.selectCalendar(calendar.id);
                              selectedCalendarId.value = calendar.id;
                            });
                            } else {
                              selectedCalendarId.value = '';
                              controller.selectCalendar('');  
                            }
                          },
                          selectedColor: Colors.blue.shade100,
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            color: selectedCalendarId.value == calendar.id 
                              ? Colors.blue.shade800 
                              : Colors.black87,
                            fontWeight: selectedCalendarId.value == calendar.id 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                          ),
                        ),
                      ));
                    },
                  )
                : Center(
                    child: Text(
                      'No calendars available. Create one!', 
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
            ),
            
            // View selector and calendar header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => SegmentedButton<flutter_selection.CalendarView>(
                    segments: const [
                      ButtonSegment(
                        value: flutter_selection.CalendarView.month,
                        label: Text('Month'),
                        icon: Icon(Icons.calendar_month),
                      ),
                      ButtonSegment(
                        value: flutter_selection.CalendarView.week,
                        label: Text('Week'),
                        icon: Icon(Icons.view_week),
                      ),
                      ButtonSegment(
                        value: flutter_selection.CalendarView.day,
                        label: Text('Day'),
                        icon: Icon(Icons.view_day),
                      ),
                    ],
                    selected: {calendarView.value},
                    onSelectionChanged: (selected) {
                      calendarView.value = selected.first;
                    },
                  )),
                ],
              ),
            ),
            
            // Calendar view
            Obx(() {
              // Convert appointments to Syncfusion format
              final meetings = _getAllCalendarAppointments();

              return Expanded(
                child: flutter_selection.SfCalendar(
                  key: Key('calendar_${controller.forceRefresh}'),
                  view: calendarView.value,
                  dataSource: _AppointmentDataSource(meetings),
                  firstDayOfWeek: 1, // Monday
                  showNavigationArrow: true,
                  allowViewNavigation: true,
                  showDatePickerButton: true,
                  todayHighlightColor: Theme.of(context).primaryColor,
                  initialSelectedDate: controller.selectedDay.value,
                  onTap: (flutter_selection.CalendarTapDetails details) {
                    if (details.targetElement == flutter_selection.CalendarElement.calendarCell) {
                      if (details.date != null) {
                        controller.selectedDay.value = details.date!;
                        controller.forceRefresh.value++;
                        
                        // If a calendar is selected, load its appointments for this day
                        if (selectedCalendarId.value.isNotEmpty) {
                          controller.loadAppointments(
                            selectedCalendarId.value,
                            DateFormat('yyyy-MM-dd').format(details.date!)
                          );
                        }
                      }
                    } else if (details.targetElement == flutter_selection.CalendarElement.appointment) {
                      // Show appointment details when clicking on it
                      if (details.appointments != null && details.appointments!.isNotEmpty) {
                        _showAppointmentDetails(context, details.appointments!.first as flutter_selection.Appointment);
                      }
                    }
                  },
                  selectionDecoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  monthViewSettings: const flutter_selection.MonthViewSettings(
                    showAgenda: false, // Removed agenda view as requested
                    appointmentDisplayMode: flutter_selection.MonthAppointmentDisplayMode.indicator,
                  ),
                  appointmentBuilder: (context, calendarAppointmentDetails) {
                    final flutter_selection.Appointment appointment = calendarAppointmentDetails.appointments.first;
                    return Container(
                      decoration: BoxDecoration(
                        color: appointment.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        appointment.subject,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        );
      }),
      floatingActionButton: Obx(() => selectedCalendarId.value.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showStepperAppointmentDialog(context),
              child: const Icon(Icons.add),
              tooltip: 'Add Appointment',
            )
          : Container()),
      bottomNavigationBar: MomentumBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Method to get all appointments from all calendars
  List<flutter_selection.Appointment> _getAllCalendarAppointments() {
    List<flutter_selection.Appointment> appointments = [];
    
    // First add all appointments from all calendars
    for (var app in controller.allAppointments) {
      final DateTime startTime = app.inTime;
      final DateTime endTime = app.outTime;
      appointments.add(
        flutter_selection.Appointment(
          id: app.id,
          subject: app.title,
          startTime: startTime,
          endTime: endTime,
          color: Colors.grey.shade400, // Color for non-selected calendar appointments
          notes: app.description,
          location: app.locationId,
          recurrenceRule: '',
          isAllDay: false,
        ),
      );
    }
    
    // If a calendar is selected, highlight its appointments with a different color
    if (selectedCalendarId.value.isNotEmpty) {
      for (var app in controller.appointments) {
        final DateTime startTime = app.inTime;
        final DateTime endTime = app.outTime;
        
        // Try to find the appointment in the general list to update it
        int index = appointments.indexWhere((appt) => appt.id == app.id);
        
        if (index >= 0) {
          // Update existing appointment with highlighted color
          appointments[index] = flutter_selection.Appointment(
            id: app.id,
            subject: app.title,
            startTime: startTime,
            endTime: endTime,
            color: Theme.of(context).primaryColor, // Color for selected calendar appointments
            notes: app.description,
            location: app.locationId,
            recurrenceRule: '',
            isAllDay: false,
          );
        }
      }
    }
    
    return appointments;
  }

  void _showAppointmentDetails(BuildContext context, flutter_selection.Appointment appointment) {
    Get.dialog(
      AlertDialog(
        title: Text('Appointment Details', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.subject,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(appointment.startTime)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.access_time_filled, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(appointment.endTime)),
              ],
            ),
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(appointment.notes!)),
                  ],
                ),
              ),
            if (appointment.location != null && appointment.location!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(appointment.location!),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Logic to delete appointment
              Get.back();
              Get.snackbar(
                'Information',
                'Delete appointment functionality not implemented',
                snackPosition: SnackPosition.BOTTOM
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStepperAppointmentDialog(BuildContext context) {
    if (selectedCalendarId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a calendar first',
        snackPosition: SnackPosition.BOTTOM
      );
      return;
    }

    final titleController = TextEditingController();
    final startDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(controller.selectedDay.value)
    );
    final startTimeController = TextEditingController(text: '09:00');
    final endDateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(controller.selectedDay.value)
    );
    final endTimeController = TextEditingController(text: '10:00');
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();

    int currentStep = 0;
    
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Stepper(
                currentStep: currentStep,
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        if (currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(currentStep < 2 ? 'Next' : 'Save'),
                        ),
                      ],
                    ),
                  );
                },
                onStepContinue: () async {
                  if (currentStep < 2) {
                    setState(() {
                      currentStep++;
                    });
                  } else {
                    // Save appointment
                    if (titleController.text.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Title is required',
                        snackPosition: SnackPosition.BOTTOM
                      );
                      return;
                    }

                    try {
                      // Format dates
                      final startDateTime = '${startDateController.text}T${startTimeController.text}:00';
                      final endDateTime = '${endDateController.text}T${endTimeController.text}:00';

                      final appointmentData = {
                        'title': titleController.text,
                        'inTime': startDateTime,
                        'outTime': endDateTime,
                        'description': descriptionController.text,
                        'location': locationController.text.isNotEmpty 
                          ? locationController.text 
                          : null,
                      };

                      await controller.addAppointment(selectedCalendarId.value, appointmentData);
                      Get.back();
                      
                      // Reload appointments
                      await controller.loadAppointments(
                        selectedCalendarId.value,
                        controller.selectedDay.value.toIso8601String().split('T').first,
                      );
                      
                      // Reload all appointments to update the view
                      fetchAllAppointments();
                    } catch (e) {
                      Get.snackbar(
                        'Error',
                        'Could not create appointment: $e',
                        snackPosition: SnackPosition.BOTTOM
                      );
                    }
                  }
                },
                onStepCancel: () {
                  if (currentStep > 0) {
                    setState(() {
                      currentStep--;
                    });
                  }
                },
                steps: [
                  Step(
                    title: const Text('Basic Information'),
                    content: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title*',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                    isActive: currentStep >= 0,
                  ),
                  Step(
                    title: const Text('Date & Time'),
                    content: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: startDateController,
                                decoration: const InputDecoration(
                                  labelText: 'Start Date',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: controller.selectedDay.value,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: startTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'Time',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.access_time),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final TimeOfDay? picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      startTimeController.text = 
                                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: endDateController,
                                decoration: const InputDecoration(
                                  labelText: 'End Date',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: controller.selectedDay.value,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: endTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'Time',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.access_time),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final TimeOfDay? picked = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(hour: 10, minute: 0),
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      endTimeController.text = 
                                          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    isActive: currentStep >= 1,
                  ),
                  Step(
                    title: const Text('Location'),
                    content: TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                        border: OutlineInputBorder(),
                        hintText: 'Enter the location of your appointment',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    isActive: currentStep >= 2,
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}

class _AppointmentDataSource extends flutter_selection.CalendarDataSource {
  _AppointmentDataSource(List<flutter_selection.Appointment> source) {
    appointments = source;
  }
}
