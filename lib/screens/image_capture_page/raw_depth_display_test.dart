import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';

class RawDepthTest extends StatelessWidget {
  const RawDepthTest(
      {Key? key,
      required this.cameraImg,
      required this.depthImg,
      required this.rawDepthImg,
      required this.confidenceImg,
      required this.width,
      required this.height})
      : super(key: key);

  final Uint8List cameraImg;
  final Uint8List depthImg;
  final Uint8List rawDepthImg;
  final Uint8List confidenceImg;
  final int width;
  final int height;

  @override
  Widget build(BuildContext context) {
    img.Image depthImage = visualizeDepth(depthImg, width, height);
    img.Image rawDepthImage = visualizeRawDepth(rawDepthImg, width, height);
    img.Image confidenceImage = visualizeConfidence(confidenceImg, width, height);

    List<int> depthPng = img.encodePng(depthImage);
    List<int> rawDepthPng = img.encodePng(rawDepthImage);
    List<int> confidencePng = img.encodePng(confidenceImage);

    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 200,
                  child: Image.memory(cameraImg),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 200,
                  child: Image.memory(Uint8List.fromList(confidencePng)),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 200,
                  child: Image.memory(Uint8List.fromList(depthPng)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 200,
                  child: Image.memory(Uint8List.fromList(rawDepthPng)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  img.Image visualizeDepth(Uint8List depthData, int width, int height) {
    img.Image depthImage = img.Image(width, height);
    ByteData data = ByteData.sublistView(depthData);

    int minDepth = 65535;
    int maxDepth = 0;

    // Determine the range of depth values
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int depthValue = data.getUint16((y * width + x) * 2, Endian.little);
        if (depthValue < minDepth) minDepth = depthValue;
        if (depthValue > maxDepth) maxDepth = depthValue;
      }
    }

    // Map depth values to colors and set pixels
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int depthValue = data.getUint16((y * width + x) * 2, Endian.little);
        double normalized = (depthValue - minDepth) / (maxDepth - minDepth);
        int color = depthToColor(normalized);
        depthImage.setPixel(x, y, color);
      }
    }

    return depthImage;
  }

  img.Image visualizeRawDepth(Uint8List rawDepthData, int width, int height) {
    img.Image rawDepthImg = img.Image(width, height);
    ByteData depthData = ByteData.sublistView(rawDepthData);

    int minDepth = 65535;
    int maxDepth = 0;

    // Determine the actual range of raw depth values
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int depthValue = depthData.getUint16((y * width + x) * 2, Endian.little);
        if (depthValue > 0) { // Exclude 0 values which indicate no depth estimate
          if (depthValue < minDepth) minDepth = depthValue;
          if (depthValue > maxDepth) maxDepth = depthValue;
        }
      }
    }

    // Cap the maxDepth for visualization
    int visualizationMaxDepth = min(maxDepth, 5000);

    print("Min Depth: $minDepth");
    print("Max Depth: $maxDepth");

    // Map raw depth values to colors and set pixels
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int depthValue = depthData.getUint16((y * width + x) * 2, Endian.little);
        if (depthValue > 0) {
          double normalized = (depthValue - minDepth) / (visualizationMaxDepth - minDepth);
          int grayscaleValue = (normalized * 255).toInt().clamp(0, 255);
          rawDepthImg.setPixel(x, y, depthToColor(normalized));
          // rawDepthImg.setPixel(x, y, img.ColorRgb8(grayscaleValue, grayscaleValue, grayscaleValue));
        } else {
          rawDepthImg.setPixel(x, y, img.getColor(0, 0, 255)); // Set no depth estimate pixels to blue
        }
      }
    }

    return rawDepthImg;
  }

  int depthValueToColor(double normalizedValue) {
    int scaledValue = (normalizedValue * 255).toInt().clamp(0, 255);
    int r, g, b;

    if (scaledValue < 128) {
      r = 0;
      g = 2 * scaledValue;
      b = 255 - 2 * scaledValue;
    } else {
      r = 2 * (scaledValue - 128);
      g = 255 - 2 * (scaledValue - 128);
      b = 0;
    }

    return img.getColor(r, g, b);
  }

  int getColor(int r, int g, int b) {
    return (0xFF << 24) | (r << 16) | (g << 8) | b;
  }


  int depthToColor(double normalized) {
    int r = (255 * jetColormap(normalized, 0.5, 1.0)).toInt();
    int g = (255 * jetColormap(normalized, 0.25, 0.75)).toInt();
    int b = (255 * jetColormap(normalized, 0.0, 0.5)).toInt();
    int a = 255; // alpha channel

    return img.getColor(r, g, b, a);
  }

  double jetColormap(double x, double a, double b) {
    if (x < a) return 0;
    if (x < (a + b) / 2) return 2 * (x - a) / (b - a);
    if (x < b) return 1;
    if (x < (b + 1) / 2) return 1 - 2 * (x - b) / (1 - b);
    return 0;
  }


  img.Image visualizeConfidence(Uint8List confidenceData, int width, int height) {
    img.Image confidenceImage = img.Image(width, height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int confidenceValue = confidenceData[y * width + x];
        int color = confidenceToColor(confidenceValue);
        confidenceImage.setPixel(x, y, color);
      }
    }

    return confidenceImage;
  }

  int confidenceToColor(int confidenceValue) {
    return img.getColor(confidenceValue, confidenceValue, confidenceValue, 255);
  }

}
