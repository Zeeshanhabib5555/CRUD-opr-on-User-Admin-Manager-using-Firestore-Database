import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AdminCrud extends StatefulWidget {
  const AdminCrud({super.key});

  @override
  State<AdminCrud> createState() => _AdminCrudState();
}

class _AdminCrudState extends State<AdminCrud> {
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


  /*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  DELETE START  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
  Future<void> _delete(String productId) async {
    await _product.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }
  /*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  DELETE END  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Admin Crud',style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      //This is Floating Action button Start
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>_create(),
        child: Icon(Icons.add),
      ),
      //This is Floating Action button End
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
                                  IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          _delete(documentSnapshot.id)),
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
