class SearchModel {
  void onValueChanged(String s) {
    if (s == null) {
      return;
    }
    if (s.isNotEmpty) {
      // show books, search suggestions
      // show history
    } else {
      // hide history, books, matching books
      // show default
    }
  }

  void checkNavChange(String s, bool rightArrow) {}
}
