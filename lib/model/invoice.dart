class Invoice {
  String _season = "";
  String _name = "";

  Invoice();

  String get name => _name;

  String get season => _season;

  set name(String value) {
    _name = value;
  }

  set season(String value) {
    _season = value;
  }
}
