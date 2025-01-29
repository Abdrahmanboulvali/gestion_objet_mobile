import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _typeController = TextEditingController();
  final _statuController = TextEditingController();
  final _destribitionController = TextEditingController();
  final _emplacementController = TextEditingController();
  final _dateController = TextEditingController();
  Uint8List? _selectedImageBytes;
  String? _originalFileName;
  DateTime? _selectedDate;
  int? currentUserid;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _selectedDate!.toLocal().toString().split(' ')[0];
      });
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final imageBytes = await pickedImage.readAsBytes();
      setState(() {
        _selectedImageBytes = imageBytes;
        _originalFileName = pickedImage.name;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucune image sélectionnée.')),
      );
    }
  }

  Future<void> createItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserid = prefs.getInt('identifiant');
    final url = Uri.parse('http://127.0.0.1:5001/api/create');

    final imageBase64 = _selectedImageBytes != null ? base64Encode(_selectedImageBytes!) : null;

    final data = {
      'type': _typeController.text,
      'statu': _statuController.text,
      'emplacement': _emplacementController.text,
      'date': _dateController.text,
      'etat': 'inactive',
      'identifiant': currentUserid,
      'destribition': _destribitionController.text,
      'image': imageBase64,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Article créé avec succès.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la création de l\'article.')),
        );
      }
    } catch (e) {
      print('Erreur : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un objet', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.indigo,
        elevation: 4,
        automaticallyImplyLeading: true, // Ensures the back arrow is displayed
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ajouter un objet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTextField('Type de l\'objet', _typeController),
                    SizedBox(height: 16),
                    _buildTextField('Description', _destribitionController, maxLines: 4),
                    SizedBox(height: 16),
                    _buildTextField('Emplacement', _emplacementController, maxLines: 4),
                    SizedBox(height: 16),
                    _buildDropdownField('Statut', _statuController, ['Trouvé', 'Perdu']),
                    SizedBox(height: 16),
                    _buildDateField('Date', _dateController, context),
                    SizedBox(height: 16),
                    _buildImagePicker(),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: createItem,
                      icon: Icon(Icons.save, color: Colors.white,),
                      label: Text('Publier l\'objet', style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        textStyle: TextStyle(fontSize: 16),
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
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Entrez $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          onChanged: (String? newValue) {
            setState(() {
              controller.text = newValue!;
            });
          },
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          decoration: InputDecoration(
            hintText: 'Choisissez $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Choisissez $label',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image de l\'objet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey),
              image: _selectedImageBytes != null
                  ? DecorationImage(
                image: MemoryImage(_selectedImageBytes!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: _selectedImageBytes == null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
                  SizedBox(height: 8),
                  Text(
                    'Parcourir',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
                : null,
          ),
        ),
        if (_originalFileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Image sélectionnée : $_originalFileName',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
      ],
    );
  }
}