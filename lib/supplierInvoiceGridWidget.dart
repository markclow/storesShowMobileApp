import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stores_show_mobile_app/utils/utils.dart';

import 'constants/ui.dart';
import 'types/callbacks.dart';

class SupplierInvoiceGridWidget extends StatelessWidget {
  List<String> _items;
  CallbackWithData<String> _onItemSelected;
  String _invoiceDirectory;

  SupplierInvoiceGridWidget(
      this._items, this._onItemSelected, this._invoiceDirectory);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (orientation == Orientation.portrait ? 3 : 4)),
          itemCount: _items.length,
          itemBuilder: (BuildContext ctx, index) {
            File imageFile = File(_invoiceDirectory + "/" + _items[index]);
            return GestureDetector(
                onTap: () => _onItemSelected(context, _items[index]),
                child: GridTile(
                  footer: Container(
                    decoration: BoxDecoration(color: COLOR_WHITE),
                    child: Text(
                      calculateGridName(_items[index]),
                      textAlign: TextAlign.center,
                      style: TEXT_STYLE_REGULAR_BOLD,
                    ),
                    padding: EdgeInsets.only(bottom: 20),
                  ),
                  child: Image.file(
                    imageFile,
                    height: 50,
                  ),
                ));
          });
    });
  }
}
