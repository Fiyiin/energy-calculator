import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:tabular/tabular.dart';

import 'decorations.dart';

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
      title: 'Energy Calculator',
      debugShowCheckedModeBanner: false,
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

  bool shouldRefresh = false;
  List<List<String>> data = [
    ['Appliance', 'Daily Consumption (KWH)', 'Daily Cost (\u20A6)']
  ];
  List<double> consumption = [];
  List<double> cost = [];

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: ReactiveFormBuilder(
          form: () => form,
          builder: (context, formGroup, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 35),
                      Text('EKEDC Electricity Tarriff: Band C @ \u20A642/KWH'),
                      SizedBox(height: 20),
                      FormRow(rating: rating, duration: duration, unit: unit),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: shouldRefresh
                                ? null
                                : () {
                                    form.markAllAsTouched();
                                    if (form.valid) {
                                      final appliance =
                                          form.control('0.appliance').value;
                                      final dailyConsumption =
                                          calcPower(Wh(rating, duration, unit))
                                              .value;
                                      final dailyCost =
                                          calcPower(Wh(rating, duration, unit))
                                                  .value *
                                              42;

                                      cost.add(dailyCost);
                                      consumption.add(dailyConsumption);

                                      setState(() {
                                        data.add([
                                          '$appliance',
                                          dailyConsumption.toStringAsFixed(2),
                                          dailyCost.toStringAsFixed(2),
                                        ]);
                                      });

                                      form
                                          .control('0.appliance')
                                          .updateValue('');
                                      form.control('0.rating').updateValue('');
                                      form
                                          .control('0.duration')
                                          .updateValue('');
                                    }
                                  },
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  side: BorderSide(color: Colors.blue),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 40.0,
                                ),
                                primary: Colors.blue),
                            child: Text(
                              'Next',
                            ),
                          ),
                          const SizedBox(width: 25),
                          TextButton(
                            onPressed: () {
                              form.markAllAsTouched();
                              if (cost.isNotEmpty && consumption.isNotEmpty) {
                                final totalCost = cost.reduce(
                                    (value, element) => value + element);
                                final totalConsumption = consumption.reduce(
                                    (value, element) => value + element);
                                setState(() {
                                  if (shouldRefresh) {
                                    cost.clear();
                                    consumption.clear();

                                    data.removeRange(1, data.length);

                                    shouldRefresh = false;
                                  } else {
                                    data.add([
                                      'Total',
                                      totalConsumption.toStringAsFixed(2),
                                      totalCost.toStringAsFixed(2),
                                    ]);
                                    shouldRefresh = true;
                                  }
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                                horizontal: 40.0,
                              ),
                              primary: Colors.white,
                              backgroundColor: Colors.blue,
                            ),
                            child: Text(
                              shouldRefresh ? 'Restart' : 'Done',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      AnimatedOpacity(
                        opacity: data.length < 2 ? 0 : 1,
                        duration: Duration(milliseconds: 200),
                        child: MarkdownBody(
                          data: tabular(data),
                        ),
                      ),
                      SizedBox(height: 50)
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
              ),
            );
          },
        ),
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
        Wrap(
          // spacing: 5,
          runSpacing: 10,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('1'),
            SizedBox(width: 10),
            ReactiveTextField(
              formControlName: '0.appliance',
              decoration: Decorations.formInputDecoration(context)
                  .copyWith(labelText: 'Appliance'),
            ),
            SizedBox(height: 20),
            ReactiveTextField(
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
            SizedBox(height: 20),
            ReactiveTextField(
              formControlName: '0.duration',
              keyboardType: TextInputType.number,
              decoration: Decorations.formInputDecoration(context).copyWith(
                labelText: 'Duration',
                suffixIcon: Tooltip(
                  message: 'how long the appliance works',
                  child: SizedBox(
                    width: 70,
                    child: ReactiveDropdownField(
                      decoration: Decorations.dropDownDecoration(context),
                      formControlName: '0.unit',
                      validationMessages: (control) =>
                          {ValidationMessage.required: 'this a required field'},
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
          ],
        ),
        SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              // mainAxisSize: MainAxisSize.min,
              children: [
                Text('Daily Power Consumption: '),
                Text(
                    '${calcPower(Wh(widget.rating, widget.duration, widget.unit)).value.toStringAsFixed(2)} KWH'),
              ],
            ),
            SizedBox(width: 30),
            Wrap(
              // mainAxisSize: MainAxisSize.min,
              children: [
                Text('Daily Cost: '),
                Text(
                    '\u20A6 ${(calcPower(Wh(widget.rating, widget.duration, widget.unit)).value * 42).toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
