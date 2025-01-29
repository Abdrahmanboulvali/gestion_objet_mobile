import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'OtpVerificationPage.dart';

class CreatePagee extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePagee> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _genreController = TextEditingController();
  final _telController = TextEditingController();
  final _emailController = TextEditingController();
  final _adresseController = TextEditingController();
  final _motpasseController = TextEditingController();
  final _amotpasseController = TextEditingController();

  Future<void> createAccount() async {
    final url = Uri.parse('http://127.0.0.1:5001/api/create_account');

    final data = {
      'nom': _nomController.text,
      'prenom': _prenomController.text,
      'genre': _genreController.text,
      'num_tel': _telController.text,
      'email': _emailController.text,
      'adresse': _adresseController.text,
      'mot_passe': _motpasseController.text,
      'a_mot_passe': _amotpasseController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Compte créé avec succès.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création du compte.')),
        );
      }
    } catch (e) {
      print('Erreur : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion au serveur.')),
      );
    }
  }

  void navigateToOtpPage() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(
            phoneNumber: _telController.text,
            onOtpVerified: createAccount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un compte'),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // للعودة إلى الصفحة السابقة
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.tealAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildTextField('Nom', _nomController),
                      SizedBox(height: 16),
                      _buildTextField('Nom de la famille', _prenomController),
                      SizedBox(height: 16),
                      _buildDropdownField('Genre', _genreController, ['Homme', 'Femme']),
                      SizedBox(height: 16),
                      _buildPhoneField(),
                      SizedBox(height: 16),
                      _buildTextField('Email', _emailController, keyboardType: TextInputType.emailAddress),
                      SizedBox(height: 16),
                      _buildTextField('Adresse', _adresseController),
                      SizedBox(height: 16),
                      _buildTextField('Mot de passe', _motpasseController, obscureText: true),
                      SizedBox(height: 16),
                      _buildTextField('Confirmez votre mot de passe', _amotpasseController, obscureText: true),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: navigateToOtpPage,
                        icon: Icon(Icons.account_circle, color: Colors.white),
                        label: Text('Créer le compte', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
        prefixIcon: _getIconForField(label),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est obligatoire';
        }
        if (label == 'Confirmez votre mot de passe' && value != _motpasseController.text) {
          return 'Les mots de passe ne correspondent pas';
        }
        return null;
      },
    );
  }

  Icon _getIconForField(String label) {
    switch (label) {
      case 'Nom':
      case 'Nom de la famille':
        return Icon(Icons.person);
      case 'Genre':
        return Icon(Icons.transgender);
      case 'Numéro du téléphone':
        return Icon(Icons.phone);
      case 'Email':
        return Icon(Icons.email);
      case 'Adresse':
        return Icon(Icons.home);
      case 'Mot de passe':
      case 'Confirmez votre mot de passe':
        return Icon(Icons.lock);
      default:
        return Icon(Icons.text_fields);
    }
  }

  Widget _buildPhoneField() {
    return _buildTextField('Numéro du téléphone', _telController, keyboardType: TextInputType.phone);
  }

  Widget _buildDropdownField(String label, TextEditingController controller, List<String> items) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      onChanged: (String? newValue) {
        setState(() {
          controller.text = newValue!;
        });
      },
      items: items.map((value) {
        return DropdownMenuItem(value: value, child: Text(value));
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
        prefixIcon: Icon(Icons.person),
      ),
    );
  }
}
