import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled3/Information_objet.dart';
import 'dart:convert';
import 'update_page.dart';
import 'Preferences.dart';
import 'create_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class profil extends StatefulWidget {
  @override
  _profilState createState() => _profilState();
}

class _profilState extends State<profil> {
  final PreferenceService _prefs = PreferenceService();
  List objets = [];
  List filtrationObjets = [];
  TextEditingController _recherchController = TextEditingController();
  int? currentUserid;

  @override
  void initState() {
    super.initState();
    fetchobjets();
    _recherchController.addListener(_resultatrecherch);
  }

  Future<void> fetchobjets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentUserid = prefs.getInt('identifiant');
    final response = await http.get(Uri.parse('http://127.0.0.1:5001/api/objet_p_t'));
    if (response.statusCode == 200) {
      setState(() {
        objets = json.decode(response.body);
        filtrationObjets = objets.where((objet) => objet['id_p'] == currentUserid).toList();
      });
    } else {
      print('Erreur lors de la récupération des informations de l\'objet : ${response.statusCode}');
    }
  }

  void _resultatrecherch() {
    setState(() {
      filtrationObjets = objets
          .where((objet) =>
      objet['id_p'] == currentUserid &&
          (objet['type'].toLowerCase().contains(_recherchController.text.toLowerCase()) ||
              objet['destribition'].toLowerCase().contains(_recherchController.text.toLowerCase())))
          .toList();
    });
  }

  Future<void> deleteobjet(int id_o) async {
    final response = await http.delete(Uri.parse('http://127.0.0.1:5001/api/delete/$id_o'));
    if (response.statusCode == 200) {
      fetchobjets();
    } else {
      print('Erreur lors de la suppression de l\'objet : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        title: Text(
          'Mes objets',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.tealAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _recherchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher vos objets...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: filtrationObjets.isEmpty
                  ? Center(
                child: Text(
                  'Aucun objet ajouté.',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
                  : GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: filtrationObjets.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => inf_obj(objet: filtrationObjets[index]),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              child: filtrationObjets[index]['image1'] != null
                                  ? Image.network(
                                filtrationObjets[index]['image1'],
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  filtrationObjets[index]['type'],
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  filtrationObjets[index]['destribition'],
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  filtrationObjets[index]['num_tel'].toString(),
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),SizedBox(height: 4),
                                Text(
                                  filtrationObjets[index]['etat'].toString(),
                                  style: TextStyle(fontSize: 14, color: Colors.red[600]),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () async {
                                  bool updated = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdatePage(objet: filtrationObjets[index]),
                                    ),
                                  );
                                  if (updated == true) {
                                    fetchobjets();
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final bool? confirm = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Confirmation'),
                                        content: Text('Êtes-vous sûr de vouloir supprimer cet élément ?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: Text('Supprimer'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (confirm == true) {
                                    deleteobjet(filtrationObjets[index]['id_o']);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.tealAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () async {
            bool inserted = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreatePage()),
            );
            if (inserted == true) {
              fetchobjets();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}