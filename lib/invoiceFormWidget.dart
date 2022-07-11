import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'types/callbacks.dart';

class InvoiceFormWidget extends StatefulWidget {
  late GlobalKey<FormState> _formKey;
  late CallbackWithData<String> _onSeasonChange;
  late CallbackWithData<String> _onNameChange;

  InvoiceFormWidget(
      {Key? key,
      required GlobalKey<FormState> formKey,
      required CallbackWithData<String> onSeasonChange,
      required CallbackWithData<String> onNameChange})
      : super(key: key) {
    this._formKey = formKey;
    this._onSeasonChange = onSeasonChange;
    this._onNameChange = onNameChange;
  }

  @override
  _InvoiceFormWidgetState createState() => new _InvoiceFormWidgetState();
}

class _InvoiceFormWidgetState extends State<InvoiceFormWidget> {
  TextEditingController _nameController = TextEditingController();
  List<DropdownMenuItem<String>>? _seasonsList = [];
  String _season = "";

  void initState() {
    super.initState();
    int year = DateTime.now().year;
    for (var i = 0; i < 3; i++) {
      _seasonsList!.add(DropdownMenuItem(
          value: "Spring ${year + i}", child: Text("Spring ${year + i}")));
      _seasonsList!.add(DropdownMenuItem(
          value: "Summer ${year + i}", child: Text("Summer ${year + i}")));
      _seasonsList!.add(DropdownMenuItem(
          value: "Fall ${year + i}", child: Text("Fall ${year + i}")));
      _seasonsList!.add(DropdownMenuItem(
          value: "Winter ${year + i}", child: Text("Winter ${year + i}")));
    }
    _season = _seasonsList![0].value!;
    widget._onSeasonChange(context, _season);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formWidgetList = [];
    formWidgetList.add(createSeasonsWidget());
    formWidgetList.add(createNameWidget());
    return Container(
        height: 150,
        child: Form(
            key: widget._formKey, child: Column(children: formWidgetList)));
  }

  InputDecorator createSeasonsWidget() {
    DropdownButton<String> stateDropdownButton = DropdownButton<String>(
        items: _seasonsList,
        value: _season,
        isDense: true,
        onChanged: (String? value) {
          setState(() {
            if (value == null) {
              this._season = "";
            } else {
              this._season = value;
            }
            widget._onSeasonChange(context, this._season);
          });
        });
    return InputDecorator(
        decoration: const InputDecoration(
          icon: const Icon(Icons.location_city),
          hintText: 'Select the Season',
          labelText: 'Select the Season',
        ),
        child: new DropdownButtonHideUnderline(child: stateDropdownButton));
  }

  TextFormField createNameWidget() {
    return new TextFormField(
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter the invoice name.';
          }
        },
        onChanged: (value) => widget._onNameChange(context, value),
        decoration: InputDecoration(
            icon: const Icon(Icons.person),
            hintText: 'Invoice name',
            labelText: 'Enter the invoice name.'),
        controller: _nameController,
        autofocus: true,
        inputFormatters: [
          FilteringTextInputFormatter(RegExp(r'[0-9 a-zA-Z]'), allow: true)
        ]);
  }
}
