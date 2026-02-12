import 'dart:ui';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor, double opacity) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      // Add a default full opacity if only RGB is provided
      hexColor = "FF" + hexColor;
    }
    // Convert decimal opacity (0.0-1.0) to hex integer (0-255)
    int alpha = (opacity * 255).round();
    String alphaHex = alpha.toRadixString(16).padLeft(2, '0').toUpperCase();
    hexColor =
        alphaHex + hexColor.substring(2); // Replace 'FF' with custom alpha

    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor, {double opacity = 1.0})
    : super(_getColorFromHex(hexColor, opacity));
}
