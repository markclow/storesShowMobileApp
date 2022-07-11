import 'package:flutter/material.dart';

import 'constants/ui.dart';
import 'types/callbacks.dart';

class SupplierListWidget extends StatelessWidget {
  final dynamic _supplier;
  final CallbackWithData _invoices;
  final CallbackWithData _rename;
  final CallbackWithData _delete;

  SupplierListWidget(
    this._supplier,
    this._invoices,
    this._rename,
    this._delete,
  );

  @override
  Widget build(BuildContext context) {
    Widget titleWidget = Container(
      child: Text(
        "${_supplier}",
        textAlign: TextAlign.left,
        style: TEXT_STYLE_SUBHEADING,
      ),
      width: 300,
    );
    Widget invoicesButton = OutlinedButton(
        style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
        onPressed: () => _invoices(context, _supplier),
        child: Text(
          "Invoices",
          style: TEXT_SMALL,
        ));
    Widget renameButton = OutlinedButton(
        style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
        onPressed: () => _rename(context, _supplier),
        child: Text(
          "Rename",
          style: TEXT_SMALL,
        ));
    Widget deleteButton = OutlinedButton(
        style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
        onPressed: () => _delete(context, _supplier),
        child: Text(
          "Delete",
          style: TEXT_SMALL,
        ));
    return Container(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
            title: Row(mainAxisSize: MainAxisSize.max, children: [
          Expanded(child: titleWidget),
          invoicesButton,
          HORIZONTAL_SPACER_5,
          renameButton,
          HORIZONTAL_SPACER_5,
          deleteButton,
        ])));
  }
}
