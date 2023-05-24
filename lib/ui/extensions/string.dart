extension BoolParsing on String? {
  bool? toBool() {
    if (this?.toLowerCase() == 'true') {
      return true;
    }
    if (this?.toLowerCase() == 'false') {
      return false;
    }
    return null;
  }
}