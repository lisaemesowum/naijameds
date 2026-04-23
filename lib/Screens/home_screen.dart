import 'package:flutter/material.dart';
import 'package:naijameds/Screens/scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
     body: SafeArea(
       child: Padding(
         padding: const EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
           //   greeting
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 const Column(
                   crossAxisAlignment:  CrossAxisAlignment.start,
                   children: [
                     Text("Hello,",
                         style: TextStyle(fontSize: 16, color: Colors.grey)
                     ),
                     Text("Good morning!",
                         style: TextStyle(
                             fontSize: 20, fontWeight: FontWeight.bold)),
                   ],
                 ),

                 const CircleAvatar(
                   backgroundColor: Colors.grey,
                   child: Icon(Icons.person, color: Colors.white),
                 )
               ],
             ),
             const SizedBox(height: 20),

             //  SCAN CARD (MAIN FEATURE)
             GestureDetector(
               onTap: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => const ScanScreen(),
                   ),
                 );
               },
               child: Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: Colors.green,
                   borderRadius: BorderRadius.circular(16),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: const [
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text("Scan Drug",
                             style: TextStyle(
                                 color: Colors.white,
                                 fontSize: 18,
                                 fontWeight: FontWeight.bold)),
                         SizedBox(height: 5),
                         Text("Scan code to verify",
                             style:
                             TextStyle(color: Colors.white70, fontSize: 14)),
                       ],
                     ),
                     Icon(Icons.qr_code_scanner,
                         color: Colors.white, size: 40),
                   ],
                 ),
               ),
             ),

             const SizedBox(height: 20),

             // ⚡ QUICK ACTIONS
             _buildActionCard(Icons.search, "Find Drug", Colors.green),
             _buildActionCard(Icons.warning, "Report Fake Drug", Colors.red),
             _buildActionCard(Icons.chat, "Chat with Pharmacist", Colors.blue),
             const SizedBox(height: 20),

           //  NEARBY PHARMACIES
           const Text("Nearby Pharmacies",
             style:TextStyle(fontSize: 18, fontWeight: FontWeight.bold)) ,
         const SizedBox(height: 10),
             Expanded(
                 child: ListView(
                   children: const [
                     _PharmacyCard(
                       name: "HealthPlus Pharmacy",
                       distance: "2.1 km",
                       status: "Open",
                     ),
                     _PharmacyCard(
                       name: "CarePoint Pharmacy",
                       distance: "3.5 km",
                       status: "Open",
                     ),
                   ],
                 ),
             ),
            ]
         )
         ),
       ),
     );
  }
  // 🔹 ACTION CARD WIDGET
  Widget _buildActionCard(IconData icon, String title, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }


}

// 🏥 PHARMACY CARD
class _PharmacyCard extends StatelessWidget {
  final String name;
  final String distance;
  final String status;

  const _PharmacyCard({
    required this.name,
    required this.distance,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.green),
        title: Text(name),
        subtitle: Text("$distance • $status"),
        trailing: const Icon(Icons.call, color: Colors.green),
      ),
    );
  }
}
