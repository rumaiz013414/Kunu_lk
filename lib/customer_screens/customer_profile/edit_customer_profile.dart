import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCustomerProfilePage extends StatefulWidget {
  @override
  _EditCustomerProfilePageState createState() =>
      _EditCustomerProfilePageState();
}

class _EditCustomerProfilePageState extends State<EditCustomerProfilePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _postalCodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> updateUserProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'name': _nameController.text.trim(),
        'phone_number': _phoneNumberController.text.trim(),
        'address': _addressController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')));
      Navigator.pop(context); // Navigate back to profile page
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Color(0xFFFFE54F), // Banana yellow for AppBar
      ),
      body: Container(
        color: Color(0xFFFFF9C4), // Subtle banana yellow background
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('User data not found'));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            _nameController.text = userData['name'] ?? '';
            _phoneNumberController.text = userData['phone_number'] ?? '';
            _addressController.text = userData['address'] ?? '';
            _postalCodeController.text = userData['postal_code'] ?? '';

            return ListView(
              children: [
                _buildTextField('Name', _nameController),
                _buildTextField('Phone Number', _phoneNumberController),
                _buildTextField('Address', _addressController),
                _buildTextField('Postal Code', _postalCodeController),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: updateUserProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFE54F), // Banana yellow
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('Save'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
