import 'package:flutter/material.dart';

class Dimensions {
  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double heightPercentage(BuildContext context, double percentage) =>
      screenHeight(context) * percentage / 100;

  static double widthPercentage(BuildContext context, double percentage) =>
      screenWidth(context) * percentage / 100;

  static double fontSize(BuildContext context, double percentage) =>
      screenHeight(context) * percentage / 100;

  static double radius(BuildContext context, double percentage) =>
      screenHeight(context) * percentage / 100;
}

bool isYouTubeUrl(String url) {
  final youtubeRegex = RegExp(
    r'^https?:\/\/(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    caseSensitive: false,
  );
  return youtubeRegex.hasMatch(url);
}

bool isImageUrl(String url) {
  final imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  final extension = url.split('.').last;
  return imageExtensions.contains(extension.toLowerCase());
}

bool isVideoUrl(String url) {
  final videoExtensions = ['mp4', 'avi', 'mov', 'wmv', 'flv'];
  final extension = url.split('.').last;
  return videoExtensions.contains(extension.toLowerCase());
}
