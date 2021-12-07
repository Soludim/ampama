import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/meatype.dart';

//dress 0 //shirt 1 //trousers 2

class MeasurementTextFields {
  List<MeaType> _meaTypes = <MeaType>[
    MeaType(name: 'Bust', type: 0, value: 0),
    MeaType(name: 'Waist', type: 0, value: 0),
    MeaType(name: 'Hip', type: 0, value: 0),
    MeaType(name: 'Shoulder to Waist', type: 0, value: 0),
    MeaType(name: 'Full length', type: 0, value: 0),
    MeaType(name: 'Short length', type: 0, value: 0),
    MeaType(name: 'Slit length', type: 0, value: 0),
    MeaType(name: 'Skirt length', type: 0, value: 0),
    MeaType(name: 'Sleeve length', type: 0, value: 0),
    MeaType(name: 'Around Arm', type: 0, value: 0),
    MeaType(name: 'Arm length', type: 0, value: 0),
    MeaType(name: 'Length', type: 1, value: 0),
    MeaType(name: 'Shoulder', type: 1, value: 0),
    MeaType(name: 'Body(Stomach)', type: 1, value: 0),
    MeaType(name: 'Chest', type: 1, value: 0),
    MeaType(name: 'Sleeve length', type: 1, value: 0),
    MeaType(name: 'Around sleeve', type: 1, value: 0),
    MeaType(name: 'Cuff', type: 1, value: 0),
    MeaType(name: 'Collar', type: 1, value: 0),
    MeaType(name: 'Length', type: 2, value: 0),
    MeaType(name: 'Tigh', type: 2, value: 0),
    MeaType(name: 'Waist', type: 2, value: 0),
    MeaType(name: 'Hip', type: 2, value: 0),
    MeaType(name: 'Bass', type: 2, value: 0),
  ];

  List<Map<String, dynamic>> get measurements {
    List<Map<String, dynamic>> usedFields = [];

    for (int i = 0; i < _meaTypes.length; i++) {
      if (_meaTypes[i].value != 0) {
        Map<String, dynamic> usedField = {
          'name': null,
          'type': null,
          'value': null
        };
        usedField['name'] = _meaTypes[i].name;
        usedField['type'] = _meaTypes[i].type;
        usedField['value'] = _meaTypes[i].value;
        usedFields.add(usedField);
      }
    }

    return usedFields;
  }

  Widget allfields(int type, BuildContext context,
      [List<Map<String, dynamic>> measurements, bool textValue = false]) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          alignment: Alignment.center,
          child: Text(
            getTypeName(type),
            style: TextStyle(
                fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        !textValue
            ? Column(
                children: _meaTypes
                    .map((meaType) => meaType.type == type
                        ? field(meaType, context, measurements)
                        : Container())
                    .toList())
            : Column(
                children: _meaTypes
                    .map((meaType) => meaType.type == type
                        ? displayedValue(meaType, context, measurements)
                        : Container())
                    .toList())
      ],
    );
  }
}

Widget field(MeaType meaType, BuildContext context,
    List<Map<String, dynamic>> measurements) {
  final double deviceWidth = MediaQuery.of(context).size.width;
  final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
  String initValue = '';
  if (measurements != null) {
    for (int i = 0; i < measurements.length; i++) {
      if (measurements[i]['name'] == meaType.name &&
          measurements[i]['type'] == meaType.type) {
        initValue = measurements[i]['value'].toString();
      }
    }
  }

  return SizedBox(
    width: targetWidth,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            meaType.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 85,
          height: 60,
          child: Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: TextFormField(
              initialValue: initValue,
              keyboardType: TextInputType.number,
              maxLines: 1,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                ),
              ),
              validator: (String value) {
                if (value == '') {
                  return '';
                }
              },
              onSaved: (String value) {
                try {
                  meaType.value = int.parse(value);
                } catch (e) {
                  return;
                }
              },
            ),
          ),
        ),
      ],
    ),
  );
}

String getTypeName(int type) {
  String name;
  switch (type) {
    case 0:
      name = 'Dress';
      break;
    case 1:
      name = 'Shirt(Top)';
      break;
    case 2:
      name = 'Trousers';
  }
  return name;
}

Widget displayedValue(MeaType meaType, BuildContext context,
    List<Map<String, dynamic>> measurements) {
  for (int i = 0; i < measurements.length; i++) {
    if (measurements[i]['name'] == meaType.name &&
        measurements[i]['type'] == meaType.type) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(10.0),
              child: Text(measurements[i]['name'])),
          Container(
              alignment: Alignment.centerRight,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              child: Text(measurements[i]['value'].toString()))
        ],
      );
    }
  }
  return Container();
}
