import 'package:eziline_job_task_email_auth/Pages/user_crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key}) : super(key: key);

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  var firebase_auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String? _name;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("User"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Enter your email",
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
                controller: emailController,
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Enter your password",
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value;
                },
                controller: passwordController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // If the form is valid, save the form data
                        _formKey.currentState!.save();
                        // Now you can use the validated data, for example, submit it
                        print('Name: $_name');
                        String email = emailController.text.toString();
                        String password = passwordController.text.toString();

                        try {
                          await firebase_auth
                              .createUserWithEmailAndPassword(
                                  email: email, password: password)
                              .then((UserCredential user_credential) {
                            print("object ${user_credential.user.toString()}");
                            print(
                                "object ${user_credential.credential!.signInMethod}");
                            print(
                                "object ${user_credential.credential!.token}");
                          }).onError((FirebaseAuthException error, stackTrace) {
                            if (error.code == "email-already-in-use") {
                              print(
                                  "This email is already in use you can use another email");
                            }
                          });
                        } catch (e) {
                          print("object error ${e.toString()}");
                          return;
                        }
                      }
                    },
                    child: const Text(
                      "SignUp",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () async {
                  //Navigator.push(context, MaterialPageRoute(builder: (context)=>UserCrud()));
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, save the form data
                    _formKey.currentState!.save();
                    // Now you can use the validated data, for example, submit it
                    print('Name: $_name');
                    String email = emailController.text.toString();
                    String password = passwordController.text.toString();
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>UserCrud()));


                    try {
                      await firebase_auth
                          .signInWithEmailAndPassword(
                              email: email, password: password)
                          .then((UserCredential user_credential) {
                        if (email == user_credential.user?.email) {
                          _showAlertDialog('Status',
                              'Login Through  ${user_credential.user?.email}');
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginHomePhEm()));

                        }
                        print("object ${user_credential.user.toString()}");
                        print(
                            "object ${user_credential.credential!.signInMethod}");
                        print("object ${user_credential.credential!.token}");
                      }).onError((FirebaseAuthException error, stackTrace) {
                        if (error.code == "email-already-in-use") {
                          print(
                              "This email is already in use you can use another email");
                        }
                      });
                    } catch (e) {
                      print("object error ${e.toString()}");
                      return;
                    }

                  }
                },
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
      backgroundColor: const Color(0xFFB2DFDB),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
