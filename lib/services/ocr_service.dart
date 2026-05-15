import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static Future<String> scanText(File imageFile) async{
    final inputImage = InputImage.fromFile(imageFile); // Convert file to image
    final textRecognizer = TextRecognizer(); // Initialize text recognizer
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage); // Recognize text in image and store in variable
    await textRecognizer.close(); // Close text recognizer
    String text = recognizedText.text; // Store text in variable

  //    REMOVE NEW LINES AND SPACES FROM TEXT (IF ANY)

    text = text.replaceAll("\n", " "); // Replace new lines with spaces

    // FIND ONLY NUMBERS

    RegExp regExp = RegExp(r'\d{6,20}'); // Regular expression to find numbers
    Match? match = regExp.firstMatch(text); // Find first match in text using regular expression and store in variable

    if (match != null) { // If match is not null (i.e. if a number is found) then return the first match

      return match.group(0)!; // Return first match as string (i.e. the number)
    }
    return text; // If no number is found, return the text as a string

  }
}
//================THIS HANDLES OCR AND TEXT RECOGNITION ================================================================================