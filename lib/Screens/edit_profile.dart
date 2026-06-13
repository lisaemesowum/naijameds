import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance; // Initialize Firebase Authentication
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final Color primaryColor = const Color(0xFF2A6074);

  bool isLoading = false;

  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() { // Initialize the state of the widget
    super.initState();

    nameController.text = currentUser?.displayName ?? ""; // Set the name controller to the current user's display name or empty string if null is returned
    emailController.text = currentUser?.email ?? ""; // Set the email controller to the current user's email or empty string if null is returned
  }

  Future<void> updateProfile() async {
    // Basic validation current password is required for any sensitive operation
    if (oldPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your current password to save changes")),
      );
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      User? user = auth.currentUser; // Get the current user from Firebase Authentication

      //
      if (user == null) { // If the user is null then throw an error and return from the function
        throw FirebaseAuthException(
          code: "user-not-found",
          message: "No user is signed in",
        );
      }
      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential( // Create a credential for the user with the email and password from the old password controller
        email: user.email!, // Get the email from the user
        password: oldPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential); // Re-authenticate the user with the credential
      String message = "";
      // \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
      // Update Name
      if (nameController.text.trim().isNotEmpty &&
          nameController.text.trim() != user.displayName) {
        await user.updateDisplayName(nameController.text.trim());
        message += "Username updated successfully\n";
      } // Update the display name of the user with the name from the name controller

      // Update Email
      if (emailController.text.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(emailController.text.trim());
        message += "Verification email sent for new email\n";
      }

      // Update Password
      if (newPasswordController.text.trim().isNotEmpty) {
        await user.updatePassword(newPasswordController.text.trim());
        message += "Password updated successfully";
      }

      await user.reload();
      user = FirebaseAuth.instance.currentUser;
      setState(() {
        currentUser = user;
        nameController.text = user?.displayName ?? "";
        emailController.text = user?.email ?? "";
        oldPasswordController.clear();
        newPasswordController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text(
            message.isEmpty
                ? "No changes made"
                : message,
          ),        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? " OOOPS Something went wrong"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.green.shade100,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.green),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Profile Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xffDFF7E8),
              child: const Icon(
                Icons.person,
                size: 55,
                color: Color(0xff17B169),
              ),
            ),

            const SizedBox(height: 30),

            // Name
            buildTextField(
              controller: nameController,
              hint: "Full Name",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 20),

            // Email
            buildTextField(
              controller: emailController,
              hint: "Email Address",
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 20),

            // Old Password
            buildTextField(
              controller: oldPasswordController,
              hint: "Current Password",
              icon: Icons.lock_outline,
              obscureText: true,
            ),

            const SizedBox(height: 40),
            // New Password
            buildTextField(
              controller: newPasswordController,
              hint: "New Password",
              icon: Icons.lock_reset_outlined,
              obscureText: true,
            ),

            const SizedBox(height: 40),


            // Update Button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff17B169),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  "Update Profile",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({ // Function to build text field with optional parameters for controller, hint, icon, and obscure text option
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xff17B169),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
