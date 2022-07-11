class SupplierRename {
  final String _oldName;
  final String _newName;

  SupplierRename(this._oldName, this._newName);

  String get newName => _newName.trim();

  String get oldName => _oldName.trim();

  bool isValid() {
    return _oldName.isNotEmpty && _newName.isNotEmpty && _oldName != _newName;
  }
}
