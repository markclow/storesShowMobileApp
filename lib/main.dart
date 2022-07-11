import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants/ui.dart';
import 'model/supplierRename.dart';
import 'supplierInvoiceListWidget.dart';
import 'supplierListWidget.dart';
import 'utils/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Show',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Show: Suppliers'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _suppliers = [];

  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() async {
    Directory? externalStoragePicturesDirectory =
        await calculateExternalStoragePicturesDirectory();
    if (externalStoragePicturesDirectory == null){
      showExternalStorageMessage(context);
      return;
    }
    List<String> suppliers =
        calculateSuppliersFromExternalStoragePicturesDirectory(
            externalStoragePicturesDirectory);
    suppliers.sort();
    setState(() {
      _suppliers = suppliers;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        iconTheme: IconThemeData(
          color: COLOR_WHITE, //change your color here
        ),
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: _suppliers.length,
          itemBuilder: (context, int index) {
            return SupplierListWidget(_suppliers[index], _onSupplierInvoices,
                _onSupplierRename, _onSupplierDelete);
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onSupplierAdd(context),
        tooltip: 'Add Supplier',
        child: const Icon(Icons.add),
      ),
    );
  }

  _onSupplierAdd(BuildContext context) async {
    Directory? externalStoragePicturesDirectory =
        await calculateExternalStoragePicturesDirectory();
    if (externalStoragePicturesDirectory == null) {
      showExternalStorageMessage(context);
      return;
    }
    String supplierName = await _promptForName(context);
    if (supplierName.isNotEmpty) {
      try {
        if (externalStoragePicturesDirectory != null) {
          Directory newDirectory = Directory(
              externalStoragePicturesDirectory.path + "/" + supplierName);
          if (newDirectory.existsSync()) {
            showMessage(context, "Supplier '$supplierName' already exists.");
          } else {
            newDirectory.createSync();
            _refresh();
          }
        }
      } catch (e) {
        showMessage(context, "Error adding supplier: $e");
      }
    }
  }

  _promptForName(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Supplier'),
            content: TextField(
                minLines: 1,
                maxLines: 1,
                autofocus: true,
                controller: textEditingController,
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp(r'[0-9 a-zA-Z]'),
                      allow: true)
                ]),
            actions: <Widget>[
              new TextButton(
                  child: new Text('OK'),
                  onPressed: () {
                    if (textEditingController.text.isNotEmpty) {
                      Navigator.of(context).pop(textEditingController.text);
                    }
                  }),
              new TextButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop("");
                },
              )
            ],
          );
        });
  }

  _onSupplierRename(BuildContext context, dynamic supplier) async {
    Directory? externalStoragePicturesDirectory =
        await calculateExternalStoragePicturesDirectory();
    if (externalStoragePicturesDirectory == null){
      showExternalStorageMessage(context);
      return;
    }
    SupplierRename supplierRename = await _promptForRename(context, supplier);
    if (supplierRename.isValid()) {
      try {
        if (externalStoragePicturesDirectory != null) {
          Directory oldDirectory = Directory(
              externalStoragePicturesDirectory.path +
                  "/" +
                  supplierRename.oldName);
          if (oldDirectory.existsSync()) {
            String newName = externalStoragePicturesDirectory.path +
                "/" +
                supplierRename.newName;
            Directory dir = Directory(newName);
            if (dir.existsSync()) {
              showMessage(context,
                  "Cannot rename supplier: '$newName' already exists.");
            } else {
              oldDirectory.rename(newName);
              _refresh();
            }
          }
        }
      } catch (e) {
        showMessage(context, "Error renaming supplier: $e");
      }
    }
  }

  _promptForRename(BuildContext context, String supplierName) {
    TextEditingController textEditingController = TextEditingController();
    textEditingController.text = supplierName;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Rename Supplier'),
            content: TextField(
              minLines: 1,
              maxLines: 1,
              autofocus: true,
              controller: textEditingController,
            ),
            actions: <Widget>[
              new TextButton(
                  child: new Text('OK'),
                  onPressed: () {
                    if (textEditingController.text.isNotEmpty) {
                      Navigator.of(context).pop(SupplierRename(
                          supplierName, textEditingController.text));
                    }
                  }),
              new TextButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop(SupplierRename("", ""));
                },
              )
            ],
          );
        });
  }

  _onSupplierDelete(BuildContext context, dynamic supplierName) async {
    Directory? externalStoragePicturesDirectory =
        await calculateExternalStoragePicturesDirectory();
    if (externalStoragePicturesDirectory == null){
      showExternalStorageMessage(context);
      return;
    }
    Widget deleteButton = FlatButton(
        child: Text("DELETE"),
        onPressed: () {
          if (externalStoragePicturesDirectory != null) {
            Directory directory = Directory(
                externalStoragePicturesDirectory.path + "/" + supplierName);
            if (directory.existsSync()) {
              directory.deleteSync();
              _refresh();
            }
          }
          Navigator.pop(context);
        });
    Widget cancelButton = FlatButton(
      child: Text("CANCEL"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("Delete"),
      content: Text(
          "Are you sure you want to delete '$supplierName' including their invoices and pictures?"),
      actions: [
        deleteButton,
        cancelButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _onSupplierInvoices(BuildContext context, dynamic supplierName) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SupplierInvoiceListWidget(
                  supplierName: supplierName,
                ),
            fullscreenDialog: true));
  }
}
