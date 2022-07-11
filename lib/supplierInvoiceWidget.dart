import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

import 'constants/ui.dart';
import 'supplierInvoiceGridWidget.dart';
import 'utils/utils.dart';

class SupplierInvoiceWidget extends StatefulWidget {
  const SupplierInvoiceWidget(
      {Key? key, required this.supplierName, required this.invoiceName})
      : super(key: key);
  final String supplierName;
  final String invoiceName;

  @override
  State<SupplierInvoiceWidget> createState() => _SupplierInvoiceWidgetState();
}

class _SupplierInvoiceWidgetState extends State<SupplierInvoiceWidget> {
  List<String> _pictures = [];
  List<String> _invoices = [];
  ImagePicker _picker = ImagePicker();
  String _externalStoragePicturesDirectory = "";
  final String type_item_image = "item";
  final String type_invoice_page = "invoice_page";
  final String add_method_camera = "camera";
  final String add_method_pick_file = "pick file";

  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() async {
    if (_externalStoragePicturesDirectory == "") {
      Directory? externalStoragePicturesDirectory =
          await calculateExternalStoragePicturesDirectory();
      if (externalStoragePicturesDirectory == null) {
        showExternalStorageMessage(context);
        return;
      } else {
        _externalStoragePicturesDirectory =
            externalStoragePicturesDirectory.path;
      }
    }
    List<String> invoices = [];
    List<String> pictures = [];
    String dirPath = _externalStoragePicturesDirectory +
        "/" +
        widget.supplierName +
        "/" +
        widget.invoiceName;
    Directory dir = Directory(dirPath);
    List<FileSystemEntity> fseList = dir.listSync(recursive: false);
    for (FileSystemEntity fse in fseList) {
      if (fse is File) {
        String name = calculateNameFromPath(fse.path);
        if (name.startsWith(type_invoice_page)) {
          invoices.add(name);
        } else {
          pictures.add(name);
        }
      }
    }
    setState(() {
      _pictures = pictures;
      _invoices = invoices;
    });
  }

  @override
  Widget build(BuildContext context) {
    String supplierName = widget.supplierName;
    String invoiceName = widget.invoiceName;
    String dirPath = _externalStoragePicturesDirectory +
        "/" +
        widget.supplierName +
        "/" +
        widget.invoiceName;
    double height = MediaQuery.of(context).size.height;
    double picturesGridHeight = (height - 200) * 0.7;
    double invoicesGridHeight = (height - 200) * 0.3;
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(
            color: COLOR_WHITE, //change your color here
          ),
          title: Text(
            "$supplierName: $invoiceName",
            style: TEXT_STYLE_SUBHEADING_WHITE,
          )),
      body: Column(children: [
        VERTICAL_SPACER_20,
        Text("Invoice Item", style: TEXT_STYLE_SUBHEADING),
        VERTICAL_SPACER_10,
        Container(
            height: picturesGridHeight,
            child: SupplierInvoiceGridWidget(_pictures, _onView, dirPath)),
        VERTICAL_SPACER_20,
        Text("Invoice Page", style: TEXT_STYLE_SUBHEADING),
        VERTICAL_SPACER_10,
        Container(
            height: invoicesGridHeight,
            child: SupplierInvoiceGridWidget(_invoices, _onView, dirPath))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAdd(context),
        tooltip: 'Add Item or Invoice Page',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onView(BuildContext context, String picture) {
    String imageFilePath = _externalStoragePicturesDirectory +
        "/" +
        widget.supplierName +
        "/" +
        widget.invoiceName +
        "/" +
        picture;
    File imageFile = File(imageFilePath);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            child:
                PhotoView(tightMode: true, imageProvider: FileImage(imageFile)),
          ),
        );
      },
    );
  }

  void _onAdd(BuildContext context) async {
    Directory? externalStoragePicturesDirectory =
        await calculateExternalStoragePicturesDirectory();
    if (externalStoragePicturesDirectory == null) {
      showExternalStorageMessage(context);
      return;
    }
    String type = await _promptForType(context);
    if (type.isNotEmpty) {
      String name = await _promptForName(context);
      if (name.isNotEmpty) {
        String addMethod = await _promptForAddMethod(context);
        ImageSource source;
        if (addMethod == add_method_camera) {
          source = ImageSource.camera;
        } else {
          source = ImageSource.gallery;
        }
        try {
          final XFile? pickedXFile = await _picker.pickImage(
            source: source,
            maxWidth: 2048,
            maxHeight: 2048,
            imageQuality: 95,
          );
          if (pickedXFile != null) {
            File pickedFile = File(pickedXFile.path);
            if (pickedFile.existsSync()) {
              String pickedFileExtension =
                  calculateFileExtensionFromPath(pickedFile.path);
              String newPath = externalStoragePicturesDirectory.path +
                  "/" +
                  widget.supplierName +
                  "/" +
                  widget.invoiceName +
                  "/" +
                  type +
                  "_" +
                  name +
                  "." +
                  pickedFileExtension;
              pickedFile.copySync(newPath);
            }
            _refresh();
          }
        } catch (e) {
          showMessage(context, "Error adding $type: $e");
        }
      }
    }
  }

  _promptForName(BuildContext context) {
    TextEditingController textEditingController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add Image/Invoice", style: TEXT_STYLE_SUBHEADING),
            content: Container(
                height: 80,
                child: Column(children: [
                  Container(
                      width: double.infinity,
                      child: Text(
                        "Enter name using keywords.",
                        textAlign: TextAlign.left,
                        style: TEXT_STYLE_REGULAR_BOLD,
                      )),
                  TextField(
                      minLines: 1,
                      maxLines: 1,
                      autofocus: true,
                      decoration: InputDecoration(
                          hintText: "eg white pants and grey tops"),
                      controller: textEditingController,
                      inputFormatters: [
                        FilteringTextInputFormatter(RegExp(r'[0-9 a-zA-Z]'),
                            allow: true)
                      ])
                ])),
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

  _promptForType(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Image/Invoice'),
            content: Text("What are you adding?"),
            actions: <Widget>[
              new TextButton(
                  child: new Text('ITEM IMAGE'),
                  onPressed: () {
                    Navigator.of(context).pop(type_item_image);
                  }),
              new TextButton(
                child: new Text('INVOICE PAGE'),
                onPressed: () {
                  Navigator.of(context).pop(type_invoice_page);
                },
              ),
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

  _promptForAddMethod(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add Image/Invoice"),
            content: Text("How are you adding it?"),
            actions: <Widget>[
              new TextButton(
                  child: new Text('CAMERA'),
                  onPressed: () {
                    Navigator.of(context).pop(add_method_camera);
                  }),
              new TextButton(
                child: new Text('PICK FILE'),
                onPressed: () {
                  Navigator.of(context).pop(add_method_pick_file);
                },
              ),
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
}
