import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'profil.dart';
import 'create_page.dart';
import 'home_page.dart';
import 'Information_objet.dart';

class HomePageP extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageP> {
  List objets = [];
  List objetss = [];
  List filtrationObjetsPerdus = [];
  List filtrationObjetsTrouves = [];
  TextEditingController _recherchController = TextEditingController();
  Map<int, int> clickCounts = {};

  @override
  void initState() {
    super.initState();
    fetchobjets();
    _recherchController.addListener(_resultatrecherch);
  }

  Future<void> fetchobjets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.get(Uri.parse('http://127.0.0.1:5001/api/objet_p_t'));

    if (response.statusCode == 200) {
      setState(() {
        objets = json.decode(response.body);
        objetss = objets.where((objet) => objet['etat'] == 'active').toList();
        filtrationObjetsPerdus = objetss.where((objet) => objet['statu'] == 'Perdu').toList();
        filtrationObjetsTrouves = objetss.where((objet) => objet['statu'] == 'Trouvé').toList();

        // تحميل عدد النقرات من SharedPreferences
        for (int i = 0; i < objetss.length; i++) {
          clickCounts[i] = prefs.getInt('clickCount_$i') ?? 0;
        }
      });
    } else {
      print('Erreur lors de la récupération des informations : ${response.statusCode}');
    }
  }

  void _resultatrecherch() {
    setState(() {
      filtrationObjetsPerdus = objetss
          .where((objet) =>
      objet['statu'] == 'Perdu' &&
          (objet['type'].toLowerCase().contains(_recherchController.text.toLowerCase()) ||
              objet['destribition'].toLowerCase().contains(_recherchController.text.toLowerCase())))
          .toList();
      filtrationObjetsTrouves = objetss
          .where((objet) =>
      objet['statu'] == 'Trouvé' &&
          (objet['type'].toLowerCase().contains(_recherchController.text.toLowerCase()) ||
              objet['destribition'].toLowerCase().contains(_recherchController.text.toLowerCase())))
          .toList();
    });
  }

  Future<void> _incrementClickCount(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      clickCounts[index] = (clickCounts[index] ?? 0) + 1;
    });
    await prefs.setInt('clickCount_$index', clickCounts[index]!); // حفظ القيمة في SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Text(
          'Liste des objets',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.tealAccent],
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
              leading: Icon(Icons.shop_2, color: Colors.teal),
              title: Text('Mes objets'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => profil()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Déconnexion'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
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
                  hintText: 'Rechercher des objets...',
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
            ListTile(
              leading: Icon(Icons.block, color: Colors.teal),
              title: Text('Les objets perdus'),
              onTap: () {
                Navigator.pop(context); // غلق القائمة الجانبية
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()), // التأكد من وجود الصفحة
                );
              },
            ),
            Expanded(
              child: filtrationObjetsTrouves.isEmpty
                  ? Center(
                child: Text(
                  'Aucun objets disponible',
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
                itemCount: filtrationObjetsTrouves.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _incrementClickCount(index); // زيادة عدد النقرات
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              inf_obj(objet: filtrationObjetsTrouves[index]),
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
                              child: filtrationObjetsTrouves[index]['image'] != null
                                  ? Image.network(
                                filtrationObjetsTrouves[index]['image'],
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(Icons.image_not_supported,
                                      size: 40, color: Colors.grey),
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
                                  filtrationObjetsTrouves[index]['type'],
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  filtrationObjetsTrouves[index]['destribition'],
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[600]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.visibility, color: Colors.teal),
                                    SizedBox(width: 4),
                                    Text(
                                      '${clickCounts[index] ?? 0}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool inserted = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePage()),
          );
          if (inserted == true) {
            fetchobjets();
          }
        },
        backgroundColor: Colors.teal,
        child: Icon(Icons.add),
      ),
    );
  }
}
