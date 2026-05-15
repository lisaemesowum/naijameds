import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget { // Class for the result screen that extends StatelessWidget
  final bool isAuthenticated;
  final String code;
  final Map<String,dynamic>? data;  // Map to store data from firebase


  const ResultScreen({super.key, required this.isAuthenticated, required this.code, this.data});


  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text("Verification Result"),
     ),
     body: Center(
       child: Padding(padding: const EdgeInsets.all(20), // Padding for the content
       child:Column( // Column to display the content
         mainAxisAlignment: MainAxisAlignment.center, // Center the content
         children: [ // List of widgets to display
           // Icon to display if the user is authenticated or not (green for authenticated, red for not)
           Icon(isAuthenticated ? Icons.check_circle
               : Icons.cancel, size: 100,
               color: isAuthenticated ? Colors.green
                   : Colors.red
           ),// Text to display if the user is authenticated or not
           const SizedBox(height: 20), // Space between the icon and the text

           Text(
             isAuthenticated ? "Authenticated" : "Not Authenticated", // Text to display if the user is authenticated or not
             style : TextStyle( //
               fontSize: 20,
               fontWeight: FontWeight.bold,
               color: isAuthenticated ? Colors.green  // if the isAuthenticated show green :: if not RED
                   : Colors.red
             ),
           ), // ==============

           const SizedBox(height: 20), // Space between the text and the button

           Text(
             "Code: $code", // Text to display the code
             style: const TextStyle(
               fontSize: 18,
               fontWeight: FontWeight.bold,
             ),
           ),
           const SizedBox(height: 20), // Space between the text and the button
           if(isAuthenticated && data != null)...[ // If the user is authenticated and data is not null
             Text(
               "Drug: ${data!['drugName']}", // Text to display the drug name
               style: const TextStyle(fontSize: 18), // Style for the text (font size)
             ),
             const SizedBox(height: 13), // Space between the text and the button
             // Text(
             //   "MAS Code: ${data!['code']}", // Text to display the MAS code
             //   style: const TextStyle(fontSize: 18), // Style for the text (font size)
             // ),
             // const SizedBox(height: 13), // Space between the text and the button
             Text(
               "Manufacturer: ${data!['manufacturer']}", // Text to display the manufacturer name
               style: const TextStyle(fontSize: 18),
             ),
             const SizedBox(height: 13), // Space between the text and the button
             Text(
               "Description: ${data!['description']}", // Text to display the description
               style: const TextStyle(fontSize: 18),
             ),
             const SizedBox(height: 13), // Space between the text and the button
             Text(
               "Location: ${data!['location']}", // Text to display the location
               style: const TextStyle(fontSize: 18),
             ),
             const SizedBox(height: 13), // Space between the text and the button
             Text(
               "Status: ${data!['status']}", // Text to display the status
               style: const TextStyle(fontSize: 18),
             ),

           ]

         ],

       )
       ),
     )
   );
  }
}


