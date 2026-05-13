import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';

class AIService {

  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-3-flash-preview',
  );

  Future<String> ask(String message) async {
    // prompt for the ai about the pharmacy and the drug
    final prompt = [
      Content.text(
        ''' 
        You are NaijaMeds AI Pharmacy Assistant.
        
        Rules:
        - Only answer pharmacy and medicine questions.
        - Be short and clear.
        - Do not give dangerous medical advice.
        - Recommend users speak to a pharmacist for emergencies.
        - Answer questions about medicines, drugs, pharmacies, dosage information, and health tips in a simple way.
        
        User Question:
        $message
 
        ''',
      ),
    ];

    final response = await model.generateContent(prompt);

    return response.text ?? "";
  }

//    for images to
Future<String> analyzeImage(File image, String message) async{
    final bytes = await image.readAsBytes();
    final response = await model.generateContent([
      Content.multi([
        TextPart(message.isEmpty
        ? "What you showed in the image is it a medical drug?"
            : message),
        InlineDataPart('image/jpeg', bytes),
      ])
    ]);
    return response.text ?? "";
}

}