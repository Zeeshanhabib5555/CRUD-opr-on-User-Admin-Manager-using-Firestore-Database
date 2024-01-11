import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class UserCrud extends StatefulWidget {
  const UserCrud({super.key});

  @override
  State<UserCrud> createState() => _UserCrudState();
}

class _UserCrudState extends State<UserCrud> {
  // This is used for Firebase Firestore.
  final CollectionReference _product =
  FirebaseFirestore.instance.collection('product');

  //In this product instance we can add the fields , update and delete the fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  var firebase_auth = FirebaseAuth.instance;

  /*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  CREATE START  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery
                    .of(ctx)
                    .viewInsets
                    .bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Create'),
                  onPressed: () async {
                    final String name = _nameController.text;
                    final double? price =
                    double.tryParse(_priceController.text);
                    if (price != null) {
                      await _product.add({"name": name, "price": price});

                      _nameController.text = '';
                      _priceController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  /*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  CREATE END  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('User Crud', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      // This is Floating Action button Start
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        child: Icon(Icons.add),
      ),
      // This is Floating Action button End

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _product.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(documentSnapshot['name']),
                          subtitle: Text(documentSnapshot['price'].toString()),
                        ),
                      );
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
          // Signout Button
          ElevatedButton(
            onPressed: () async {
              await firebase_auth.signOut();
              Navigator.of(context).pop(); // Close the current screen
            },
            child: Text('Sign Out',style: TextStyle(color: Colors.white),),
            style: TextButton.styleFrom(
              backgroundColor: Colors.teal,
              padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
          ),
          SizedBox(height: 20,),
        ],
      ),
    );
  }
}