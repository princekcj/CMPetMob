import 'package:flutter/material.dart';
import 'package:cmpets/presentation/pet_info_screen/mypet_info_screen.dart' as info_screen;
import '../add_pet_service.dart';
import 'calendar_utils.dart';

List<Appointment> appointments = [];
String selectedAppointmentType = 'Vet Appointment';

class Appointment {
  String type;
  DateTime date;
  String description;

  Appointment({
    required this.type,
    required this.date,
    this.description = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      type: json['type'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }

}

PetService _petService = PetService();


void removeAppointment(int index) {
  appointments.removeAt(index);
}

Widget buildAppointmentsSection(BuildContext context, List<Appointment> existingAppointments, bool isEnabled, String? petId, void Function(List<Appointment>) onAppointmentsChanged) {
  appointments = existingAppointments; // Initialize with existing appointments
  print("apts in widget is $appointments");
  final nextAppointment = findNextAppointment(appointments);
  return Column(
    children: [
      if (nextAppointment != null)
  ListTile(
    title: Center(
      child: Text(nextAppointment.type),
    ),
    subtitle: Center(
      child: Text(
        "Next Appt : ${nextAppointment.date.day}/${nextAppointment.date.month}/${nextAppointment.date.year}",
      ),
    ),
  ),
      ElevatedButton(
        onPressed: () {
          if (petId != null) {
            showAddAppointmentDialog(context, petId ?? '', onAppointmentsChanged); // Show a dialog to add appointments
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Alert'),
                  content: Text('You can assign appointments only after pet creation'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
          child: Text('Add Appointment', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF008C8C),
          )
      ),
    ],
  );
}

void showAddAppointmentDialog(BuildContext context, String? petId, void Function(List<Appointment>) onAppointmentsChanged) {
  String selectedNewAppointmentType = selectedAppointmentType;
  DateTime selectedDate = DateTime.now();
  String description = '';


  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Add Appointment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, // Align fields to the left
              children: [
                DropdownButton<String>(
                  value: selectedNewAppointmentType,
                  items: [
                    DropdownMenuItem(
                      value: 'Vet Appointment',
                      child: Text('Vet Appointment'),
                    ),
                    DropdownMenuItem(
                      value: 'Grooming',
                      child: Text('Grooming'),
                    ),
                    // Add more appointment types as needed
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedNewAppointmentType = newValue ?? '';
                    });
                  },
                ),
                ListTile(
                  title: Text('Appointment Date'),
                  subtitle: Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  ),
                  onTap: () {
                    _selectDate(context, (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    });
                  },
                ),
                ListTile(
                  title: Text('Appointment Time'),
                  subtitle: Text(
                    "${selectedDate.hour}:${selectedDate.minute}",
                  ),
                  onTap: () {
                    _selectDate(context, (time) {
                      setState(() {
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    });
                  },
                ),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter description (optional)',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Appointment newAppointment = Appointment(
                    type: selectedNewAppointmentType,
                    date: selectedDate,
                    description: description,
                  );
                  addAppointment(context, newAppointment, petId);
                  onAppointmentsChanged(appointments);

                  // Create a calendar event for the appointment
                  CalendarUtils.createCalendarEvent(
                    selectedNewAppointmentType,
                    selectedDate,
                    description,
                  );
                  // Call the callback function with the updated appointments
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}

void addAppointment(BuildContext context, Appointment appointment, String? idOfPet) {
  print("id of pet $idOfPet");
  if (idOfPet != null) {
      appointments.add(appointment);
      _petService.updatePetAppt(context, idOfPet, appointments);
  }
}

Appointment? findNextAppointment(List<Appointment> appointments) {
  if (appointments.isEmpty) {
    return null;
  }

  final now = DateTime.now();
  appointments.sort((a, b) => a.date.compareTo(b.date));

  for (final appointment in appointments) {
    if (appointment.date.isAfter(now)) {
      return appointment;
    }
  }

  return null;
}

Future<void> _selectDate(BuildContext context, Function(DateTime) onDateTimeSelected) async {
  DateTime selectedDate = DateTime.now();

  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: selectedDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (pickedDate != null) {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );

    if (pickedTime != null) {
      // Combine the selected date and time
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      onDateTimeSelected(selectedDate);
    }
  }
}
