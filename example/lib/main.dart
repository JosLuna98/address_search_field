import 'package:flutter/material.dart';
import 'package:address_search_text_field/address_search_text_field.dart';
import 'package:toast/toast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final SearchAddressTextField searchAddress = SearchAddressTextField();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          width: size.width * 0.80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SearchAddressTextField.widget(
                context: context,
                country: "Ecuador",
                exceptions: [
                  "Esmeraldas, Ecuador",
                  "Esmeraldas Province, Ecuador",
                  "Ecuador"
                ],
              ),
              SizedBox(
                height: 15.0,
              ),
              FlatButton(
                child: Text("get data"),
                color: Colors.blue,
                onPressed: () {
                  // I use toast dependency to better show the result
                  AddressPoint point = searchAddress.result;
                  Toast.show(
                    point.toString(),
                    context,
                    duration: Toast.LENGTH_LONG,
                    gravity: Toast.BOTTOM,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
