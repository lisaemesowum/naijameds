

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:naijameds/Screens/cart_service.dart';

class CartScreen extends StatelessWidget {

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final cartItems = CartService.cartItems;

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Cart"),
      ),

      body: cartItems.isEmpty

          ? const Center(
        child: Text("Cart is empty"),
      )

          : Column(

        children: [

          Expanded(
            child: ListView.builder(

              itemCount: cartItems.length,

              itemBuilder: (context, index) {

                final item = cartItems[index];

                return ListTile(

                  leading: const Icon(Icons.medication),

                  title: Text(item.name),

                  subtitle: Text(
                    "Qty: ${item.quantity}",
                  ),

                  trailing: Text(item.price),

                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),

            child: Column(

              children: [

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    const Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "₦${CartService.getTotalPrice()}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(

                    onPressed: () {

                    },

                    child: const Text(
                      "Checkout",
                    ),
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