import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'profil.dart';
import 'home_page.dart';
import 'update_profil.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? nom;
  String? prenom;
  String? email;
  String? numTel;
  String? adresse;
  int? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('identifiant');

    if (userId != null) {
      try {
        final response = await http.get(Uri.parse('http://127.0.0.1:5001/api/user/$userId'));
        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data is List) {
            data = data.first;
          }

          if (data.isNotEmpty) {
            setState(() {
              nom = data['nom']?.toString() ?? 'Non spécifié';
              prenom = data['prenom']?.toString() ?? 'Non spécifié';
              email = data['email']?.toString() ?? 'Non spécifié';
              numTel = data['num_tel']?.toString() ?? 'Non spécifié';
              adresse = data['adress']?.toString() ?? 'Non spécifié';
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Aucune donnée trouvée pour cet utilisateur')),
            );
          }
        } else {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de la récupération des données: ${response.statusCode}')),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion: $e')),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur non connecté')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon profil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.indigoAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.indigo),
              title: Text('Page général'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                ); // Navigate to profile
              },
            ),
            ListTile(
              leading: Icon(Icons.shop_2, color: Colors.indigo),
              title: Text('Mes objets'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => profil()),
                ); // Navigate to profile
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.indigo),
              title: Text('Modifier le profil'),
              onTap: () async {
                Navigator.pop(context);
                final updatedData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(
                      nom: nom,
                      prenom: prenom,
                      email: email,
                      numTel: numTel,
                      adresse: adresse,
                    ),
                  ),
                );

                if (updatedData != null) {
                  setState(() {
                    nom = updatedData['nom'];
                    prenom = updatedData['prenom'];
                    email = updatedData['email'];
                    numTel = updatedData['num_tel'];
                    adresse = updatedData['adress'];
                  });
                }
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.tealAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : nom == null || prenom == null
            ? Center(
          child: Text(
            'Aucune donnée disponible',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        )
            : Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.2),
              margin: EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Champ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                    DataColumn(label: Text('Valeur', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
                  ],
                  rows: [
                    DataRow(cells: [
                      DataCell(Text('Nom complet', style: TextStyle(color: Colors.black))),
                      DataCell(Text('$nom $prenom', style: TextStyle(color: Colors.black87))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Numéro de téléphone', style: TextStyle(color: Colors.black))),
                      DataCell(Text(numTel!, style: TextStyle(color: Colors.black87))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Email', style: TextStyle(color: Colors.black))),
                      DataCell(Text(email!, style: TextStyle(color: Colors.black87))),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Adresse', style: TextStyle(color: Colors.black))),
                      DataCell(Text(adresse!, style: TextStyle(color: Colors.black87))),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
