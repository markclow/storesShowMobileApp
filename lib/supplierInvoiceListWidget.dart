import 'dart:io';

import 'package:flutter/material.dart';

import './supplierInvoiceWidget.dart';
import 'constants/ui.dart';
import 'invoiceFormWidget.dart';
import 'model/addInvoice.dart';
import 'utils/utils.dart';

class SupplierInvoiceListWidget extends StatefulWidget {
  const SupplierInvoiceListWidget({Key? key, required this.supplierName})
      : super(key: key);
  final String supplierName;

  @override
  State<SupplierInvoiceListWidget> createState() =>
      _SupplierInvoiceListWidgetState();
}

class _SupplierInvoiceListWidgetState extends State<SupplierInvoiceListWidget> {
  AddInvoice _addInvoice = AddInvoice();
  List<String> _invoices = [];
  final _formKey = GlobalKey<FormState>();

  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() async {
    List<String> invoices = [];
    Directory? externalStoragePicturesDirectory =
        await calculateExternalStoragePicturesDirectory();
    if (externalStoragePicturesDirectory == null) {
      showExternalStorageMessage(context);
      return;
    }
    String dirPath =
        externalStoragePicturesDirectory.path + "/" + widget.supplierName;
    Directory dir = Directory(dirPath);
    List<FileSystemEntity> fseList = dir.listSync(recursive: false);
    for (FileSystemEntity fse in fseList) {
      if (fse is Directory) {
        invoices.add(calculateNameFromPath(fse.path));
      }
    }
    invoices.sort();
    setState(() {
      _invoices = invoices;
    });
  }

  @override
  Widget build(BuildContext context) {
    String supplierName = widget.supplierName;
    Widget imageWidget = Padding(padding:EdgeInsets.all(20), child:Image.asset(
      "images/invoice.jpeg",
    ));
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(
            color: COLOR_WHITE, //change your color here
          ),
          title: Text(
            "$supplierName: Invoices",
            style: TEXT_STYLE_SUBHEADING_WHITE,
          )),
      body: OrientationBuilder(builder: (context, orientation) {
        return Padding(
            padding: EdgeInsets.all(20.0),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        (orientation == Orientation.portrait ? 3 : 4)),
                itemCount: _invoices.length,
                itemBuilder: (BuildContext ctx, index) {
                  return GestureDetector(
                      onTap: () => _onInvoiceSelect(context, _invoices[index]),
                      child: GridTile(
                        child: imageWidget,
                        footer: Text(
                          _invoices[index],
                          textAlign: TextAlign.center,
                          style: TEXT_STYLE_SUBHEADING,
                        ),
                      ));
                }));
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onInvoiceAdd(context),
        tooltip: 'Add Invoice',
        child: const Icon(Icons.add),
      ),
    );
  }

  _onInvoiceAdd(BuildContext context) async {
    Directory? externalStoragePicturesDirectory =
        await calculateExternalStoragePicturesDirectory();
    if (externalStoragePicturesDirectory == null) {
      showExternalStorageMessage(context);
      return;
    }
    AddInvoice? invoice = await promptForNewInvoice(context);
    if (invoice != null) {
      try {
        String path = externalStoragePicturesDirectory.path +
            "/" +
            widget.supplierName +
            "/" +
            invoice.season +
            "-" +
            invoice.name;
        Directory dir = Directory(path);
        if (dir.existsSync()) {
          showMessage(context,
              "Invoice '${invoice.season}:${invoice.name}' already exists.");
        } else {
          dir.createSync();
          _refresh();
        }
      } catch (e) {
        showMessage(context, "Error adding invoice: $e");
      }
    }
  }

  promptForNewInvoice(BuildContext context) {
    InvoiceFormWidget invoiceFormWidget = InvoiceFormWidget(
        onSeasonChange: _onNewInvoiceSeasonChange,
        onNameChange: _onNewInvoiceNameChange,
        formKey: _formKey);
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add Invoice"),
            content: invoiceFormWidget,
            actions: <Widget>[
              TextButton(
                  child: new Text('OK'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).pop(_addInvoice);
                    }
                  }),
              TextButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  _onNewInvoiceSeasonChange(BuildContext context, dynamic season) {
    _addInvoice.season = season;
  }

  _onNewInvoiceNameChange(BuildContext context, dynamic name) {
    _addInvoice.name = name;
  }

  _onInvoiceSelect(BuildContext context, String invoiceName) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SupplierInvoiceWidget(
                supplierName: widget.supplierName, invoiceName: invoiceName),
            fullscreenDialog: true));
  }
}
