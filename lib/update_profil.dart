import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String? nom;
  final String? prenom;
  final String? email;
  final String? numTel;
  final String? adresse;

  EditProfilePage({this.nom, this.prenom, this.email, this.numTel, this.adresse});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _numTelController;
  late TextEditingController _adresseController;
  late TextEditingController _motPasseController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.nom);
    _prenomController = TextEditingController(text: widget.prenom);
    _emailController = TextEditingController(text: widget.email);
    _numTelController = TextEditingController(text: widget.numTel);
    _adresseController = TextEditingController(text: widget.adresse);
    _motPasseController = TextEditingController();  // حقل كلمة المرور
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _numTelController.dispose();
    _adresseController.dispose();
    _motPasseController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // قم بإرسال البيانات المعدلة إلى الخادم
      final updatedData = {
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'email': _emailController.text,
        'num_tel': _numTelController.text,
        'adress': _adresseController.text,
        'mot_passe': _motPasseController.text,  // إضافة كلمة المرور هنا
      };

      // استبدل هذا الجزء بطلب HTTP لإرسال البيانات إلى الخادم
      print('تم حفظ البيانات: $updatedData');

      // عد إلى الصفحة السابقة بعد الحفظ
      Navigator.pop(context, updatedData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le profil'),
        backgroundColor: Colors.indigo,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 5,
              shadowColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Champ')),
                    DataColumn(label: Text('Valeur')),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Nom')),
                      DataCell(TextFormField(
                        controller: _nomController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez remplir ce champ';
                          }
                          return null;
                        },
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Prénom')),
                      DataCell(TextFormField(
                        controller: _prenomController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez remplir ce champ';
                          }
                          return null;
                        },
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Email')),
                      DataCell(TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez remplir ce champ';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Numéro de téléphone')),
                      DataCell(TextFormField(
                        controller: _numTelController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez remplir ce champ';
                          }
                          if (!RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Veuillez entrer un numéro valide';
                          }
                          return null;
                        },
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Adresse')),
                      DataCell(TextFormField(
                        controller: _adresseController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez remplir ce champ';
                          }
                          return null;
                        },
                      )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Mot de passe')), // حقل كلمة المرور
                      DataCell(TextFormField(
                        controller: _motPasseController,
                        obscureText: true,  // إخفاء النص في الحقل
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Entrez votre mot de passe',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          return null;
                        },
                      )),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveProfile,
        child: Icon(Icons.save),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
