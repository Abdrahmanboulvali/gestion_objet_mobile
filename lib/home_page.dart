import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'create_page.dart';
import 'Information_objet.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List objets = [];
  List objetss = [];
  List objetsss = [];
  List filtrationObjetsPerdus = [];
  List filtrationObjetsTrouves = [];
  TextEditingController _recherchController = TextEditingController();
  int? currentUserid;

  // Map to track click counts for each item
  Map<int, int> clickCounts = {};

  bool isPerdusActive = true;

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

        for (int i = 0; i < objets.length; i++) {
          objets[i]['id'] = objets[i]['id'] ?? i;
        }

        objetss = objets.where((objet) => objet['etat'] == 'active').toList();
        objetsss = objetss.where((objet) => objet['id_p'] != currentUserid).toList();
        filtrationObjetsPerdus = objetsss.where((objet) => objet['statu'] == 'Perdu').toList();
        filtrationObjetsTrouves = objetsss.where((objet) => objet['statu'] == 'Trouvé').toList();

        // Initialize click counts for each item
        for (var objet in objetss) {
          int id = objet['id'];
          clickCounts[id] = prefs.getInt('clickCount_$id') ?? 0;
        }
      });
    } else {
      print('Erreur lors de la récupération des informations de l\'objet : ${response.statusCode}');
    }
  }

  void _resultatrecherch() {
    setState(() {
      filtrationObjetsPerdus = objetsss.where((objet) => objet['statu'] == 'Perdu').toList()
          .where((objet) => objet['type'].toLowerCase().contains(_recherchController.text.toLowerCase()) ||
          objet['destribition'].toLowerCase().contains(_recherchController.text.toLowerCase()))
          .toList();
      filtrationObjetsTrouves = objetsss.where((objet) => objet['statu'] == 'Trouvé').toList()
          .where((objet) => objet['type'].toLowerCase().contains(_recherchController.text.toLowerCase()) ||
          objet['destribition'].toLowerCase().contains(_recherchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _incrementClickCount(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      clickCounts[id] = (clickCounts[id] ?? 0) + 1;
    });
    await prefs.setInt('clickCount_$id', clickCounts[id]!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
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
              leading: Icon(Icons.person, color: Colors.indigo),
              title: Text('Profil'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                ); // Navigate to profile
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Déconnexion'),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clear user data
                Navigator.pop(context); // Close the drawer
                Navigator.pushReplacementNamed(context, '/login'); // Navigate to login
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors. indigo, Colors.tealAccent],
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isPerdusActive = true;
                      });
                    },
                    child: Text(
                      'PERDUS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isPerdusActive ? FontWeight.bold : FontWeight.normal,
                        decoration: isPerdusActive ? TextDecoration.underline : TextDecoration.none,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isPerdusActive = false;
                      });
                    },
                    child: Text(
                      'TROUVÉS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: !isPerdusActive ? FontWeight.bold : FontWeight.normal,
                        decoration: !isPerdusActive ? TextDecoration.underline : TextDecoration.none,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isPerdusActive
                  ? filtrationObjetsPerdus.isEmpty
                  ? Center(
                child: Text(
                  'Aucun objets disponible',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
                  : _buildGridView(filtrationObjetsPerdus)
                  : filtrationObjetsTrouves.isEmpty
                  ? Center(
                child: Text(
                  'Aucun objets disponible',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
                  : _buildGridView(filtrationObjetsTrouves),
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

  Widget _buildGridView(List objets) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3 / 4,
      ),
      itemCount: objets.length,
      itemBuilder: (context, index) {
        final objet = objets[index];
        final id = objet['id'];
        return GestureDetector(
          onTap: () {
            _incrementClickCount(id);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => inf_obj(objet: objets[index]),
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
                    child: objets[index]['image1'] != null
                        ? Image.network(
                      objets[index]['image1'],
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
                        objets[index]['type'],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        objets[index]['destribition'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        objets[index]['num_tel'].toString(),
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.teal),
                          SizedBox(width: 4),
                          Text(
                            '${clickCounts[id] ?? 0}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
    );
  }
}