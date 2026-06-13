import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naijameds/services/ai_service.dart';
import 'package:naijameds/services/firestore_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _imagePicker = ImagePicker();
  final AIService _aiService = AIService();
  final ScrollController _scrollController = ScrollController(); // scroll controller
  bool _isTyping = false;
  // =========================AI CHAT BOT=======================================================

  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Hello! I am NaijaMeds AI. Ask me about medicines.Am here to help you😊",
      "isMe": false,
      "time": "Now"
    },

  ];


  // linked from ai_service.dart

  Future<void> SendMessage() async{
    //  Get user message from text field
    String userMessage = _messageController.text.trim();

    if(userMessage.isEmpty) return;
    //   Add user message
    setState(() {
      _messages.add({
        "text": userMessage,
        "isMe": true,
        "time": TimeOfDay.now().format(context),
      });
    });
    _messageController.clear();
    //  SAVE USER MESSAGE TO FIRESTORE
    await _firestoreService.saveMessage({
      "type": "text",
      "text": userMessage,
      "isMe": true,
    });


    try {
      setState(() {
        _isTyping = true;
      });
      _scrollToBottom();
      //
      final time = Stopwatch()..start();
      // Ask AI
      String reply = await _aiService.ask(userMessage);
      time.stop(); // stop the stopwatch


      // Add AI reply
      setState(() {
        _isTyping = false;
        _messages.add({
          "text": reply,
          "isMe": false,
          "time": "${TimeOfDay.now().format(context)}s",
        });
      });
      _scrollToBottom();
      // SAVE AI MESSAGE TO FIRESTORE
      await _firestoreService.saveMessage({
        "type": "text",
        "text": reply,
        "isMe": false,
      });
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add({
          "text": "Sorry, I'm having trouble connecting right now. Please try again.",          "isMe": false,
          "time": TimeOfDay.now().format(context),
        });
      });
    }
    _scrollToBottom();
  }
  // ===========================================================================================
  @override
  void dispose() {
    // to dispose the controller
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  // ---------------------------------------FOR IMAGES ---------------------------------------------------------
  Future<void> pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if(image == null) return;
    File file = File(image.path);

    setState(() { // update the state
      _messages.add({
        "image": image.path,
        "isMe": true,
        "time": TimeOfDay.now().format(context),
      });
    });
    // SAVE TO FIRESTORE
    await _firestoreService.saveMessage({
      "type": "image",
      "image": image.path,
      "isMe": true,
    });
    //  AI ANALYSIS
    String reply = await _aiService.analyzeImage(file, "");

    setState(() {
      _messages.add({
        "text": reply,
        "isMe": false,
        "time": TimeOfDay.now().format(context),
      });
    });

    await _firestoreService.saveMessage({
      "type": "text",
      "text": reply,
      "isMe": false,
    });
  }
  // -------------------------------------------------------------------------------------------------------

  // ================= SCROLL =================
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  // ===============================================

// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.green, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF4FB062).withOpacity(0.4),
                  child: const Icon(Icons.medical_services, color: Color(0xFF4FB062), size: 24),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 10, width: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "NaijaMeds AI",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                // for online or offline
                Text(
                  _isTyping ? "Typing..." : "Online • Assistant",
                  style: TextStyle(fontSize: 12, color: _isTyping ? const Color(0xFF4FB062) : Colors.lightGreen),
                ),
              ],
            ),
          ],
        ),
      ),


      body: Column(
        children: [
          // ================= CHAT LIST =================
          Expanded(
            child: ListView.builder( // list view builder
              controller: _scrollController, // scroll controller for the list
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0), // number of messages + typing indicator if typing is true
              itemBuilder: (context, index) {
                // 
                if (_isTyping && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // ai indicator
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text("NaijaMeds AI is typing..." , style: TextStyle(color: Colors.green, fontSize: 12, height: 1.3)),
                        ],
                      ),
                    ),
                  );
                }

                final msg = _messages[index];
                final isMe = msg["isMe"] ?? false; // is the message sent by the user
                //  ================= MESSAGE BUBBLE =================
                return Align(
                  alignment:
                  isMe ? Alignment.centerRight : Alignment.centerLeft, // align the message to the right if the user sent it
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    // user message bubble with rounded corners and black background
                    decoration: BoxDecoration(
                      color:
                      isMe ? Colors.black54 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.containsKey("image"))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(msg["image"]), width: double.infinity, fit: BoxFit.cover), // image
                            ),
                          ),
                        // user text message
                        if (msg.containsKey("text")) // if the message is text
                          Text(
                            msg["text"],
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15, height: 1.3),
                          ),
                        const SizedBox(height: 5),

                        Text(
                          msg["time"], //
                          style: TextStyle(
                            fontSize: 10,
                            color:
                            isMe ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ================= INPUT =================
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            // color: Colors.white,
            decoration: BoxDecoration(
              color: Colors.black54,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                // IMAGE PICK
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: Colors.lightGreen , size: 25),
                  onPressed: pickImage,
                ),

                Expanded(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _messageController, // controller for the text field
                      onSubmitted: (_) => SendMessage(),
                      decoration: const InputDecoration(hintText: "Ask about any drug...", border: InputBorder.none, hintStyle: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: SendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4FB062),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}