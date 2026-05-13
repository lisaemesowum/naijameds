import 'package:flutter/material.dart';
import 'package:naijameds/Screens/cart_service.dart';
import 'package:naijameds/models/cart_item.dart';
import 'package:naijameds/models/medication.dart';


class MedicationDetailsScreen extends StatelessWidget {

  final Medication medication;

  const MedicationDetailsScreen({
    super.key,
    required this.medication,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF8F9FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          medication.name,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // Medicine Image/Icon
            Center(
              child: Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF4FB062).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.medication,
                  size: 70,
                  color: Color(0xFF4FB062),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Name
            Text(
              medication.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Price
            Text(
              medication.price,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4FB062),
              ),
            ),

            const SizedBox(height: 25),

            // Description Title
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              medication.desc ?? "No description available",
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 40),

            // Buttons
            Row(
              children: [

                Expanded(
                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FB062),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    onPressed: () {

                      final added = CartService.addToCart(

                        CartItem(
                          name: medication.name,
                          desc: medication.desc ?? "",
                          price: medication.price,
                        ),

                      );

                      ScaffoldMessenger.of(context).showSnackBar(

                        SnackBar(

                          backgroundColor:
                          added ? Colors.green : Colors.orange,

                          content: Text(

                            added
                                ? "${medication.name} added to cart"
                                : "${medication.name} already added",

                          ),

                        ),

                      );

                    },

                    child: const Text(
                      "Add to Cart",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {

                    },
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }
}