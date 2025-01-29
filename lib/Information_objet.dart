import 'package:flutter/material.dart';

class inf_obj extends StatelessWidget {
  final Map<String, dynamic> objet;

  inf_obj({required this.objet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(objet['type'] ?? 'Détails'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (objet['image1'] != null ||
                  objet['image2'] != null ||
                  objet['image3'] != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (objet['image1'] != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () => _showFullImage(context, objet['image1']),
                            child: Image.network(
                              objet['image1'],
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (objet['image2'] != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () => _showFullImage(context, objet['image2']),
                            child: Image.network(
                              objet['image2'],
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (objet['image3'] != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () => _showFullImage(context, objet['image3']),
                            child: Image.network(
                              objet['image3'],
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              else
                Center(
                  child: Icon(Icons.image_not_supported,
                      size: 100, color: Colors.grey),
                ),
              SizedBox(height: 16),
              Text(
                "Type: ${objet['type']}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Description: ${objet['destribition'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                "La date de publication: ${objet['date'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 8),
              Text(
                "Numéro de téléphone du propriétaire: ${objet['num_tel'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.black,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
