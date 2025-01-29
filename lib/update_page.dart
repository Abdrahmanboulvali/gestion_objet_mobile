import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class UpdatePage extends StatefulWidget {
  final Map objet;

  UpdatePage({required this.objet});

  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  late TextEditingController _typeController;
  late TextEditingController _destribitionController;
  late TextEditingController _emplacementController;
  late TextEditingController _dateController;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();
  String? _originalImageUrl;
  String? _selectedStatu;

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.objet['type']);
    _destribitionController =
        TextEditingController(text: widget.objet['destribition']);
    _emplacementController =
        TextEditingController(text: widget.objet['emplacement']);
    _dateController = TextEditingController(text: widget.objet['date']);
    _originalImageUrl = widget.objet['image'];
    _selectedStatu = widget.objet['statu'];
  }

  @override
  void dispose() {
    _typeController.dispose();
    _destribitionController.dispose();
    _emplacementController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    FocusScope.of(context).unfocus();

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _originalImageUrl = null; // Clear the original URL when a new image is picked
      });
    } else {
      _showSnackBar('Aucune image sélectionnée.');
    }
  }

  Future<void> updateObjet() async {
    FocusScope.of(context).unfocus();

    if (_selectedStatu == null || _destribitionController.text.isEmpty) {
      _showSnackBar('Elle y a une champ obligatoire manquante');
      return;
    }

    try {
      final data4 = {
        'type': _typeController.text,
        'statu': _selectedStatu,
        'destribition': _destribitionController.text,
        'emplacement': _emplacementController.text,
        'date': _dateController.text,
        if (_selectedImageBytes != null)
          'image': base64Encode(_selectedImageBytes!),
      };

      final response = await http.put(
        Uri.parse('http://127.0.0.1:5001/api/update/${widget.objet['id_o']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data4),
      );

      if (response.statusCode == 200) {
        _showSnackBar('Mis à jour avec succès');
        bool updated = true;
        Navigator.pop(context, updated);
      } else {
        print("Erreur serveur: ${response.body}");
        _showSnackBar('Erreur lors de la communication avec le serveur');
      }
    } catch (e) {
      print("Erreur: $e");
      _showSnackBar('Erreur lors de la communication avec le serveur');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Modifier l\'objet'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // العودة إلى الصفحة السابقة
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _typeController,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatu,
                    decoration: InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: [
                      DropdownMenuItem(value: 'Perdu', child: Text('Perdu')),
                      DropdownMenuItem(value: 'Trouvé', child: Text('Trouvé')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatu = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _destribitionController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _emplacementController,
                    decoration: InputDecoration(
                      labelText: 'Emplacement',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _dateController,
                    readOnly: true, // منع الكتابة اليدوية
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode()); // إخفاء لوحة المفاتيح
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000), // الحد الأدنى للتاريخ
                        lastDate: DateTime(2100), // الحد الأقصى للتاريخ
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dateController.text =
                          "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _selectedImageBytes != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _selectedImageBytes!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                          : _originalImageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          _originalImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                          : Center(
                        child: Text(
                          'Cliquez pour choisir une image',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: updateObjet,
                    child: Text('Modifier', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
