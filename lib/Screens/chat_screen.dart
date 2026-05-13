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
    // String userMessage = _messageController.text;
    // String reply = await _aiService.ask(userMessage);
    // setState(() {
    //   aiReply = reply;
    // });
    // _messageController.clear();
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
      // Ask AI
      String reply = await _aiService.ask(userMessage);

      // Add AI reply
      setState(() {
        _messages.add({
          "text": reply,
          "isMe": false,
          "time": TimeOfDay.now().format(context),
        });
      });
      // SAVE AI MESSAGE TO FIRESTORE
      await _firestoreService.saveMessage({
        "type": "text",
        "text": reply,
        "isMe": false,
      });
    } catch (e) {
      setState(() {
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
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: const Color(0xFFF4F7F5),
  //     appBar: AppBar(
  //       backgroundColor: Colors.white,
  //       elevation: 0.5,
  //       leadingWidth: 40,
  //       leading: IconButton(
  //         icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
  //         onPressed: () => Navigator.pop(context),
  //       ),
  //       title: Row(
  //         children: [
  //           Stack(
  //             children: [
  //               CircleAvatar(
  //                 radius: 20,
  //                 backgroundColor: const Color(0xFF4FB062).withOpacity(0.1),
  //                 child: const Icon(Icons.person, color: Color(0xFF4FB062)),
  //               ),
  //               Positioned(
  //                 right: 0,
  //                 bottom: 0,
  //                 child: Container(
  //                   height: 12,
  //                   width: 12,
  //                   decoration: BoxDecoration(
  //                     color: Colors.green,
  //                     shape: BoxShape.circle,
  //                     border: Border.all(color: Colors.white, width: 2),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   children: const [
  //                     Text(
  //                       "NaijaMeds AI",
  //                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2A6074)),
  //                     ),
  //                     SizedBox(width: 4),
  //                     Icon(Icons.verified, size: 14, color: Colors.blue),
  //                   ],
  //                 ),
  //                 const Text(
  //                   "HealthCare Pharmacy • Online",
  //                   style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       // call area
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.call_outlined, color: Color(0xFF2A6074)),
  //           onPressed: () {},
  //         ),
  //         IconButton(
  //           icon: const Icon(Icons.more_vert, color: Color(0xFF2A6074)),
  //           onPressed: () {},
  //         ),
  //       ],
  //     ),//===================================appbar ============================
  //     // body where the chat will be
  //     body: Column(
  //       children: [
  //         Expanded(
  //           child: ListView.builder(
  //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  //             itemCount: _messages.length,
  //             itemBuilder: (context, index) {
  //               final msg = _messages[index];
  //               final bool isMe = msg['isMe'];
  //               return _buildMessageBubble(msg, isMe);
  //             },
  //           ),
  //         ),
  //         _buildMessageInput(),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 12),
  //     child: Column(
  //       crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
  //           decoration: BoxDecoration(
  //             color: isMe ? const Color(0xFF4FB062) : Colors.white,
  //             borderRadius: BorderRadius.only(
  //               topLeft: const Radius.circular(20),
  //               topRight: const Radius.circular(20),
  //               bottomLeft: Radius.circular(isMe ? 20 : 0),
  //               bottomRight: Radius.circular(isMe ? 0 : 20),
  //             ),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.04),
  //                 blurRadius: 5,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //           ),
  //           padding: const EdgeInsets.all(12),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               if (msg.containsKey('image'))
  //                 Padding(
  //                   padding: const EdgeInsets.only(bottom: 8),
  //                   child: ClipRRect(
  //                     borderRadius: BorderRadius.circular(12),
  //                     child: Image.asset(
  //                       msg['image'],
  //                       width: double.infinity,
  //                       fit: BoxFit.cover,
  //                       errorBuilder: (context, error, stackTrace) => Container(
  //                         height: 150,
  //                         width: 150,
  //                         color: Colors.grey.shade200,
  //                         child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               if (msg.containsKey('text'))
  //                 Text(
  //                   msg['text'],
  //                   style: TextStyle(
  //                     fontSize: 15,
  //                     color: isMe ? Colors.white : Colors.black87,
  //                     height: 1.4,
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               msg['time'],
  //               style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
  //             ),
  //             if (isMe) ...[
  //               const SizedBox(width: 4),
  //               const Icon(Icons.done_all, size: 14, color: Color(0xFF4FB062)),
  //             ],
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _buildMessageInput() {
  //   return Container(
  //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, -2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF0F0F0),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: IconButton(
  //             icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2A6074)),
  //             onPressed: () {},
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 16),
  //             decoration: BoxDecoration(
  //               color: const Color(0xFFF0F0F0),
  //               borderRadius: BorderRadius.circular(24),
  //             ),
  //             child: TextField(
  //               controller: _messageController,
  //               decoration: const InputDecoration(
  //                 hintText: "Type a message...",
  //                 hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
  //                 border: InputBorder.none,
  //               ),
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         GestureDetector(
  //           onTap: () {
  //             // Logic to send message
  //           },
  //           child: Container(
  //             padding: const EdgeInsets.all(12),
  //             decoration: const BoxDecoration(
  //               color: Color(0xFF4FB062),
  //               shape: BoxShape.circle,
  //             ),
  //             child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
// }
// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),

      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0.5,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: const Text(
      //     "NaijaMeds AI",
      //     style: TextStyle(color: Color(0xFF2A6074)),
      //   ),
      // ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF4FB062).withOpacity(0.1),
                  child: const Icon(Icons.psychology, color: Color(0xFF4FB062), size: 20),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2A6074)),
                ),
                Text(
                  _isTyping ? "Typing..." : "Online • Assistant",
                  style: TextStyle(fontSize: 11, color: _isTyping ? const Color(0xFF4FB062) : Colors.grey),
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
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg["isMe"] ?? false;

                return Align(
                  alignment:
                  isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color:
                      isMe ? const Color(0xFF4FB062) : Colors.white,
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
                              child: Image.file(File(msg["image"]), width: double.infinity, fit: BoxFit.cover),
                            ),
                          ),

                        if (msg.containsKey("text"))
                          Text(
                            msg["text"],
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15, height: 1.3),
                          ),
                        const SizedBox(height: 5),

                        Text(
                          msg["time"],
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
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                // IMAGE PICK
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: Color(0xFF2A6074)),
                  onPressed: pickImage,
                ),

                Expanded(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    // child: TextField(
                    //   controller: _messageController,
                    //   decoration: const InputDecoration(
                    //     hintText: "Type a message...",
                    //     border: InputBorder.none,
                    //   ),
                    // ),
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (_) => SendMessage(),
                      decoration: const InputDecoration(hintText: "Ask about a drug...", border: InputBorder.none, hintStyle: TextStyle(fontSize: 14)),
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