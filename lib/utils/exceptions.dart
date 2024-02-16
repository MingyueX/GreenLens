class NeedManualInputException implements Exception {
  String description;
  String cause;
  NeedManualInputException(this.description, this.cause);
}

class ImageProcessException implements Exception {
  String msg;
  ImageProcessException(this.msg);
}