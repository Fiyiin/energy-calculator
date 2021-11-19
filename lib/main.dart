import 'package:energy/decorations.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Energy Cost Calculator'),
    );
  }
}

// Watts-hour
class Wh {
  double watts;
  double duration;
  String unit;
  Wh(this.watts, this.duration, this.unit) {
    if (unit == 'min') {
      this.duration = duration / 60;
    }
  }
}

// KiloWatts-hour
class KWh {
  Wh wh;
  late double _kwh;
  KWh(this.wh) : _kwh = (wh.watts / 1000) * wh.duration;

  double get value => _kwh;
}

KWh calcPower(Wh value) {
  return KWh(value);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final form = fb.group({
    '0': fb.group({
      'appliance': ['', Validators.required],
      'rating': ['', Validators.required, Validators.number],
      'duration': ['', Validators.required, Validators.number],
      'unit': ['min', Validators.required],
    })
  });
  double rating = 0;
  double duration = 0;
  String unit = 'min';

  List<FormRow> rows = [];

  @override
  void initState() {
    super.initState();
    final i0rating = form.control('0.rating') as FormControl<String>;
    final i0duration = form.control('0.duration') as FormControl<String>;
    final i0unit = form.control('0.unit') as FormControl<String>;

    form.controls.values;

    i0rating.valueChanges.listen((String? value) {
      setState(() {
        if (value != null) {
          rating = double.tryParse(value) ?? 0;
        }
      });
    });
    i0duration.valueChanges.listen((String? value) {
      setState(() {
        if (value != null) {
          duration = double.tryParse(value) ?? 0;
        }
      });
    });
    i0unit.valueChanges.listen((String? value) {
      setState(() {
        if (value != null) {
          unit = value;
        }
      });
    });

    // rows = [
    //   FormRow(
    //     key: UniqueKey(),
    //     rating: rating,
    //     duration: duration,
    //     unit: unit,
    //   ),
    // ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ReactiveFormBuilder(
        form: () => form,
        builder: (context, formGroup, child) {
          return Column(
            children: [
              Column(
                children: [
                  FormRow(rating: rating, duration: duration, unit: unit)
                ],
              ),
              // TextButton.icon(
              //   onPressed: () {
              //     setState(() {
              //       rows.add(
              //         FormRow(
              //           key: UniqueKey(),
              //           rating: rating,
              //           duration: duration,
              //           unit: unit,
              //         ),
              //       );
              //     });
              //   },
              //   icon: Icon(Icons.add),
              //   label: Text('Add'),
              // ),
            ],
          );
        },
      ),
    );
  }
}

class FormRow extends StatefulWidget {
  final double rating;
  final double duration;
  final String unit;

  const FormRow({
    Key? key,
    required this.rating,
    required this.duration,
    required this.unit,
  }) : super(key: key);

  @override
  _FormRowState createState() => _FormRowState();
}

class _FormRowState extends State<FormRow> {
  final data = ['min', 'hr'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('1'),
            SizedBox(width: 10),
            Expanded(
              child: ReactiveTextField(
                formControlName: '0.appliance',
                decoration: Decorations.formInputDecoration(context)
                    .copyWith(labelText: 'Appliance'),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: ReactiveTextField(
                formControlName: '0.rating',
                keyboardType: TextInputType.number,
                decoration: Decorations.formInputDecoration(context).copyWith(
                  labelText: 'Power Rating',
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Tooltip(
                      message: 'Power rating in Watts',
                      child: Text(
                        'W',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: ReactiveTextField(
                formControlName: '0.duration',
                keyboardType: TextInputType.number,
                decoration: Decorations.formInputDecoration(context).copyWith(
                  labelText: 'Duration',
                  suffixIcon: Tooltip(
                    message: 'how long the appliance works',
                    child: SizedBox(
                      width: 60,
                      child: ReactiveDropdownField(
                        decoration: Decorations.dropDownDecoration(context),
                        formControlName: '0.unit',
                        validationMessages: (control) => {
                          ValidationMessage.required: 'this a required field'
                        },
                        items: data.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem(
                            child: Center(
                              child: Text(value),
                            ),
                            value: value,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text('Daily Power Consumption: '),
                Text(
                    '${calcPower(Wh(widget.rating, widget.duration, widget.unit)).value.toStringAsFixed(2)} KWH'),
              ],
            ),
            SizedBox(width: 30),
            Row(
              children: [
                Text('Daily Cost: '),
                Text(
                    '\u20A6 ${(calcPower(Wh(widget.rating, widget.duration, widget.unit)).value * 49).toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
