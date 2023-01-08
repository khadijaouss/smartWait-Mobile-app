import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:interval_time_picker/interval_time_picker.dart';

class BookOnline extends StatefulWidget {
  final String uid;
  final String place_name;
  const BookOnline({
    Key? key,
    required this.uid,
    required this.place_name,
  }) : super(key: key);
  @override
  _BookOnlineState createState() => _BookOnlineState();
}

class _BookOnlineState extends State<BookOnline> {
  final ref = FirebaseDatabase.instance.ref('places');
  String textToShow = "";
  String textToShow2 = "";
  String _selectedService = "Customer service";
  TimeOfDay _selectedTime = TimeOfDay.fromDateTime(DateTime.now());
  final _timePickerTheme = TimePickerThemeData(
    hourMinuteShape: const RoundedRectangleBorder(
      side: BorderSide(color: Colors.orange, width: 4),
    ),
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateByDay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 209, 209, 209),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 209, 209, 209),
        elevation: 0.0,
      ),
      body: Column(children: [
        SizedBox(height: 50.0),
        // Sélection du service
        DropdownButtonFormField(
          value: _selectedService,
          onChanged: (newValue) {
            setState(() {
              _selectedService = newValue.toString();
            });
          },
          items: [
            'Customer service',
            'Loan service',
            'Wire transfer',
            'Currency exchange',
          ].map((service) {
            return DropdownMenuItem(
              value: service,
              child: Text(service),
            );
          }).toList(),
        ),
        SizedBox(height: 20.0),
        // Sélection de l'heure
        SizedBox(
          height: 35.0,
        ),
        SizedBox(
          width: 150,
          child: ElevatedButton(
            child: Text(
                _selectedTime != null
                    ? '${_selectedTime.hour}:${_selectedTime.minute}'
                    : 'Pick time',
                style: TextStyle(fontSize: 17.0, color: Colors.black)),
            onPressed: () async {
              final TimeOfDay? picked = await showIntervalTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                interval: 30,
                visibleStep: VisibleStep.Thirtieths,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      // This uses the _timePickerTheme defined above
                      timePickerTheme: _timePickerTheme,
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedTime = picked;
                });
              }
            },
          ),
        ),
        SizedBox(height: 70.0),
        SizedBox(
          height: 40.0,
          width: 200,
          child:
              // Bouton de réservation
              ElevatedButton(
            child: Text('Book now',
                style: TextStyle(fontSize: 17.0, color: Colors.black)),
            onPressed: _selectedService != null && _selectedTime != null
                ? () async {
                    var check = ref
                        .child(widget.place_name)
                        .child('service')
                        .child(_selectedService)
                        .child('user');

                    insertData(widget.uid, _selectedService, _selectedTime);
                    updateData(_selectedService);
                    var data = ref
                        .child(widget.place_name)
                        .child('service')
                        .child(_selectedService);

                    DatabaseEvent event = await data.once();
                    int num_queue =
                        event.snapshot.child('people_nbr').value as int;
                    double time_wait = ((num_queue - 1) * 30) / 60;
                    Container(
                      height: 240,
                      width: 195,
                      decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: SizedBox(
                        child: Column(children: [
                          SizedBox(height: 11),
                          Text("Ticket N°",
                              style: TextStyle(fontSize: 20),
                              textAlign: TextAlign.center),
                          Text(textToShow,
                              style: TextStyle(fontSize: 80),
                              textAlign: TextAlign.center),
                          SizedBox(height: 11),
                          Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("Estimated waiting time:\n",
                                    style: TextStyle(fontSize: 15)),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        iconSize: 40,
                                        icon: const Icon(Icons.hourglass_bottom,
                                            color: Colors.blue),
                                        onPressed: () {},
                                      ),
                                      Text(textToShow2,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17.0)),
                                    ])
                              ])
                        ]),
                      ),
                    );
                    setState(() {
                      textToShow = "$num_queue";
                      textToShow2 = "$time_wait H";
                    });
                  }
                : null,
          ),
        ),
        SizedBox(height: 80.0),
        Container(
          height: 240,
          width: 195,
          decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: SizedBox(
            child: Column(children: [
              SizedBox(height: 11),
              Text("Ticket N°",
                  style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
              Text(textToShow,
                  style: TextStyle(fontSize: 80), textAlign: TextAlign.center),
              SizedBox(height: 11),
              Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Text("Estimated waiting time:\n",
                    style: TextStyle(fontSize: 15)),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton(
                    iconSize: 40,
                    icon:
                        const Icon(Icons.hourglass_bottom, color: Colors.blue),
                    onPressed: () {},
                  ),
                  Text(textToShow2,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0)),
                ])
              ])
            ]),
          ),
        )
      ]),
    );
  }

  void insertData(
      String uid, String _selectedService, TimeOfDay _selectedTime) {
    ref
        .child(widget.place_name.toString())
        .child('service')
        .child(_selectedService.toString())
        .child('user')
        .child(uid)
        .set({
      'Date_booking': _selectedTime.toString(),
      'user_id': uid,
    });
  }

  void updateData(String _selectedService) {
    var newref = ref
        .child(widget.place_name.toString())
        .child('service')
        .child(_selectedService.toString());
    newref.update({'people_nbr': ServerValue.increment(1)});
  }

  Future<void> updateByDay() async {
    if ((DateTime.now()).hour == 19) {
      // ref.update({'people_nbr': 0});
    }
  }
}
