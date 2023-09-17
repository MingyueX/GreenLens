class NeedManualInputException implements Exception {
  String cause;
  NeedManualInputException(this.cause);
}

class ImageProcessException implements Exception {
  String msg;
  ImageProcessException(this.msg);
}