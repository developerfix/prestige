import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:intl/intl.dart';
import 'package:prestige/createpdf.dart';
import 'dart:ui' as ui;

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  // Controllers for text fields
  final TextEditingController consumerNameController = TextEditingController();
  final TextEditingController employeeNameController = TextEditingController();

  DateTime consumerSignatureDate = DateTime.now();
  DateTime employeeSignatureDate = DateTime.now();

  // Variables to store the time for each day
  Map<String, TimeOfDay> startTime = {};
  Map<String, TimeOfDay> endTime = {};
  Map<String, String> tasks = {};
  Map<String, String> taskCodes = {};

  // Variables to store the time for each day of both weeks
  Map<String, TimeOfDay> startTimeWeek1 = {};
  Map<String, TimeOfDay> endTimeWeek1 = {};
  Map<String, int> tasksWeek1 = {};
  Map<String, String> tasksCompletedWeek1 = {};

  Map<String, TimeOfDay> startTimeWeek2 = {};
  Map<String, TimeOfDay> endTimeWeek2 = {};
  Map<String, int> tasksWeek2 = {};
  Map<String, String> tasksCompletedWeek2 = {};

  ByteData _consumerSignimg = ByteData(0);
  ByteData _employeeSignimg = ByteData(0);

  var color = Colors.black;
  var strokeWidth = 5.0;
  final _consumersign = GlobalKey<SignatureState>();
  final _employeesign = GlobalKey<SignatureState>();
  bool allFieldsFilled = false;

  bool areAllFieldsFilled() {
    final controllers = [
      consumerNameController,
      employeeNameController,
      // Add other text form field controllers here
    ];

    for (final controller in controllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }

    // Check if signatures are saved
    if (_consumerSignimg.buffer.lengthInBytes == 0 ||
        _employeeSignimg.buffer.lengthInBytes == 0) {
      return false;
    }

    // Check if all the start and end times are filled for both weeks
    if (startTimeWeek1.values.contains(null) ||
        endTimeWeek1.values.contains(null) ||
        startTimeWeek2.values.contains(null) ||
        endTimeWeek2.values.contains(null)) {
      return false;
    }

    // Check if all the tasks are filled for both weeks
    if (tasksWeek1.values.contains(null) || tasksWeek2.values.contains(null)) {
      return false;
    }

    // Check if all the tasks completed are filled for both weeks
    if (tasksCompletedWeek1.values.contains(null) ||
        tasksCompletedWeek2.values.contains(null)) {
      return false;
    }

    return true;
  }

  Future<void> _consumerSignatureDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != consumerSignatureDate) {
      setState(() {
        consumerSignatureDate = pickedDate;
      });
    }
  }

  Future<void> _employeeSignatureDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != employeeSignatureDate) {
      setState(() {
        employeeSignatureDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, String day, bool isStartTime, bool isWeek1) async {
    TimeOfDay? selectedTime = TimeOfDay.now();

    if (isWeek1) {
      startTime = startTimeWeek1;
      endTime = endTimeWeek1;
    } else {
      startTime = startTimeWeek2;
      endTime = endTimeWeek2;
    }

    if (isStartTime) {
      selectedTime = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
          hour: DateTime.now().hour,
          minute: DateTime.now().minute,
        ),
      );
    } else {
      selectedTime = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
          hour: DateTime.now().hour,
          minute: DateTime.now().minute,
        ),
      );
    }

    if (selectedTime != null) {
      setState(() {
        if (isWeek1) {
          if (isStartTime) {
            startTimeWeek1[day] = selectedTime ?? TimeOfDay.now();
          } else {
            endTimeWeek1[day] = selectedTime ?? TimeOfDay.now();
          }
        } else {
          if (isStartTime) {
            startTimeWeek2[day] = selectedTime ?? TimeOfDay.now();
          } else {
            endTimeWeek2[day] = selectedTime ?? TimeOfDay.now();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Home Care Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: consumerNameController,
                decoration: const InputDecoration(
                  labelText: 'Consumer Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: employeeNameController,
                decoration: const InputDecoration(
                  labelText: 'Employee Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[200],
                child: const Text(
                  'NOTE: While filling out the form, use task codes when entering completed tasks. (Task codes are at the bottom of the form)',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 16),
              for (int week = 1; week <= 2; week++)
                Column(
                  children: [
                    Text('Week $week',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    for (String day in [
                      'Monday',
                      'Tuesday',
                      'Wednesday',
                      'Thursday',
                      'Friday',
                      'Saturday',
                      'Sunday'
                    ])
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(day,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _selectTime(context, day, true, week == 1),
                                child: const Text('Start Time'),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                week == 1
                                    ? (startTimeWeek1[day]?.format(context) ??
                                        'Select Time')
                                    : (startTimeWeek2[day]?.format(context) ??
                                        'Select Time'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _selectTime(context, day, false, week == 1),
                                child: const Text('End Time'),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                week == 1
                                    ? (endTimeWeek1[day]?.format(context) ??
                                        'Select Time')
                                    : (endTimeWeek2[day]?.format(context) ??
                                        'Select Time'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            onChanged: (value) {
                              setState(() {
                                if (week == 1) {
                                  tasksWeek1[day] = int.parse(value);
                                } else {
                                  tasksWeek2[day] = int.parse(value);
                                }
                              });
                            },
                            keyboardType: const TextInputType.numberWithOptions(
                                signed: false, decimal: false),
                            decoration: InputDecoration(
                              labelText: 'Total Hours for $day',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            onChanged: (value) {
                              setState(() {
                                if (week == 1) {
                                  tasksCompletedWeek1[day] = value;
                                } else {
                                  tasksCompletedWeek2[day] = value;
                                }
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Tasks Completed On $day',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                  ],
                ),
              // Consumer Signature
              const Row(
                children: [
                  Text('Consumer Signature:'),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 150,
                width: MediaQuery.of(context).size.width * 0.8,
                color: Colors.grey[200],
                child: Signature(
                  color: color,
                  key: _consumersign,
                  onSign: () {
                    final sign = _consumersign.currentState;
                    debugPrint(
                        '${sign!.points.length} points in the signature');
                  },
                  // backgroundPainter: _WatermarkPaint("2.0", "2.0"),
                  strokeWidth: strokeWidth,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          final sign = _consumersign.currentState;
                          sign!.clear();
                          setState(() {
                            _consumerSignimg = ByteData(0);
                          });
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          final sign = _consumersign.currentState;
                          //retrieve image data, do whatever you want with it (send to server, save locally...)
                          final image = await sign!.getData();
                          var data = await image.toByteData(
                              format: ui.ImageByteFormat.png);
                          sign.clear();

                          setState(() {
                            _consumerSignimg = data!;
                          });
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ),
                ],
              ),
              _consumerSignimg.buffer.lengthInBytes == 0
                  ? Container()
                  : Column(
                      children: [
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Text('Consumer Saved Signature:'),
                          ],
                        ),
                        LimitedBox(
                            maxHeight: 200.0,
                            child: Image.memory(
                                _consumerSignimg.buffer.asUint8List())),
                      ],
                    ),

              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _consumerSignatureDate,
                    child: const Text('Date'),
                  ),
                  const SizedBox(width: 8),
                  Text(DateFormat('y-MM-dd').format(consumerSignatureDate)),
                ],
              ),

              const SizedBox(height: 16),

              const Row(
                children: [
                  Text('Employee Signature:'),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 150,
                width: MediaQuery.of(context).size.width * 0.8,
                color: Colors.grey[200],
                child: Signature(
                  color: color,
                  key: _employeesign,
                  onSign: () {
                    final sign = _employeesign.currentState;
                    debugPrint(
                        '${sign!.points.length} points in the signature');
                  },
                  // backgroundPainter: _WatermarkPaint("2.0", "2.0"),
                  strokeWidth: strokeWidth,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          final sign = _employeesign.currentState;
                          sign!.clear();
                          setState(() {
                            _employeeSignimg = ByteData(0);
                          });
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          final sign = _employeesign.currentState;
                          //retrieve image data, do whatever you want with it (send to server, save locally...)
                          final image = await sign!.getData();
                          var data = await image.toByteData(
                              format: ui.ImageByteFormat.png);
                          sign.clear();

                          setState(() {
                            _employeeSignimg = data!;
                          });
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ),
                ],
              ),
              _employeeSignimg.buffer.lengthInBytes == 0
                  ? Container()
                  : Column(
                      children: [
                        const SizedBox(height: 8),
                        const Row(
                          children: [
                            Text('Employee Saved Signature:'),
                          ],
                        ),
                        LimitedBox(
                            maxHeight: 200.0,
                            child: Image.memory(
                                _employeeSignimg.buffer.asUint8List())),
                      ],
                    ),

              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => _employeeSignatureDate(context),
                    child: const Text('Date'),
                  ),
                  const SizedBox(width: 8),
                  Text(DateFormat('y-MM-dd').format(employeeSignatureDate)),
                ],
              ),
              const SizedBox(height: 50),
              SizedBox(
                height: 50, // Set the height of the button
                width: 200, // Set the width of the button
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (areAllFieldsFilled()) {
                        generatePDF(
                            consumerName: consumerNameController.text,
                            employeeName: employeeNameController.text,
                            consumerSignimg: _consumerSignimg,
                            employeeSignimg: _employeeSignimg,
                            consumerSignatureDate: consumerSignatureDate,
                            employeeSignatureDate: employeeSignatureDate,
                            tasksWeek1: tasksWeek1,
                            tasksWeek2: tasksWeek2,
                            tasksCompletedWeek1: tasksCompletedWeek1,
                            tasksCompletedWeek2: tasksCompletedWeek2,
                            startTimeWeek1: startTimeWeek1,
                            startTimeWeek2: startTimeWeek2,
                            endTimeWeek1: endTimeWeek1,
                            endTimeWeek2: endTimeWeek2);
                      } else {
                        // Show an error message or handle the case when not all fields are filled
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Incomplete Form'),
                            content: const Text(
                                'Please fill all the required fields and signatures before generating the PDF.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    });
                  },
                  child: const Text(
                    'Generate PDF',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Image.asset('assets/codes.png'),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
