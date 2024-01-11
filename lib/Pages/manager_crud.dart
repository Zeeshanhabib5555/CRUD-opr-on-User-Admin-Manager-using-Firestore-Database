import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ManagerCrud extends StatefulWidget {
  const ManagerCrud({super.key});

  @override
  State<ManagerCrud> createState() => _ManagerCrudState();
}

class _ManagerCrudState extends State<ManagerCrud> {
  // This is used for Firebase Firestore.
  //product is the name of the collection in the firebase firestore
  final CollectionReference _product =
  FirebaseFirestore.instance.collection('product');
  //In this product instance we can add the fields , update and delete the fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  var firebase_auth = FirebaseAuth.instance;

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  UPDATE START  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {

      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
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
                  child: const Text( 'Update'),
                  onPressed: () async {
                    final String name = _nameController.text;
                    final double? price =
                    double.tryParse(_priceController.text);
                    if (price != null) {

                      await _product
                          .doc(documentSnapshot!.id)
                          .update({"name": name, "price": price});
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
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  UPDATE END  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Manager Crud',style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _product.snapshots(),//build connection to firestore database
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot){
                //streamSnapshot contains all the data
                if(streamSnapshot.hasData){
                  return ListView.builder(
                      itemCount: streamSnapshot.data!.docs.length,
                      //docs refer to Rows in firestore database
                      itemBuilder: (context, index){
                        final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];
                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(documentSnapshot['name']),
                            subtitle: Text(documentSnapshot['price'].toString()),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: ()=>
                              _update(documentSnapshot)),
            // This icon button is used to delete a single product
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
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
