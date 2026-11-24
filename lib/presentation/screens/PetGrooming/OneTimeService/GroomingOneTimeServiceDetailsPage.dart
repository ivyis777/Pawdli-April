import 'package:flutter/material.dart';

class GroomingServiceDetailsPage
    extends StatelessWidget {
  final String title;
  final String price;
  final String description;

  const GroomingServiceDetailsPage({
    super.key,
    required this.title,
    required this.price,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            Image.network(
              "https://images.unsplash.com/photo-1517849845537-4d257902454a",
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [

                  Text(
                    title,
                    style:
                        const TextStyle(
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    price,
                    style:
                        const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    description,
                    style:
                        const TextStyle(
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  const Text(
                    "Included Services",
                    style:
                        TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const ListTile(
                    leading:
                        Icon(Icons.check),
                    title:
                        Text("Pet Care"),
                  ),

                  const ListTile(
                    leading:
                        Icon(Icons.check),
                    title:
                        Text("Premium Products"),
                  ),

                  const ListTile(
                    leading:
                        Icon(Icons.check),
                    title:
                        Text("Professional Service"),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 50,
                    child:
                        ElevatedButton(
                      onPressed: () {},
                      child:
                          const Text(
                        "Add To Cart",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}