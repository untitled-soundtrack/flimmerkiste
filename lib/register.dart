import 'package:flimmerkiste/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'login.dart';

class Register extends StatefulWidget {
  static String tag = 'register-page';

  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();
  final emailTextEditController = TextEditingController();
  final firstNameTextEditController = TextEditingController();
  final lastNameTextEditController = TextEditingController();
  final passwordTextEditController = TextEditingController();
  final confirmPasswordTextEditController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String _errorMessage = '';

  void processError(final PlatformException error) {
    setState(() {
      _errorMessage = error.message!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      Container(
          decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/backgrounds/black_background.jpg"),
          fit: BoxFit.cover,
        ),
      )),
      Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(
                        top: 36.0, left: 50.0, right: 50.0),
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Registrieren',
                          style: TextStyle(fontSize: 36.0, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Bitte eine gültige E-Mail eingeben.';
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.white),
                          controller: emailTextEditController,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                          focusNode: _emailFocus,
                          onFieldSubmitted: (term) {
                            FocusScope.of(context)
                                .requestFocus(_firstNameFocus);
                          },
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Colors.white38),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.white)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Bitte geben Sie Ihren Vornamen ein.';
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.white),
                          controller: firstNameTextEditController,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          textInputAction: TextInputAction.next,
                          focusNode: _firstNameFocus,
                          onFieldSubmitted: (term) {
                            FocusScope.of(context).requestFocus(_lastNameFocus);
                          },
                          decoration: InputDecoration(
                            hintText: 'Vorname',
                            hintStyle: const TextStyle(color: Colors.white38),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.white)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Bitte geben Sie Ihren Nachnamen ein.';
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.white),
                          controller: lastNameTextEditController,
                          keyboardType: TextInputType.text,
                          autofocus: false,
                          textInputAction: TextInputAction.next,
                          focusNode: _lastNameFocus,
                          onFieldSubmitted: (term) {
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                          decoration: InputDecoration(
                            hintText: 'Nachname',
                            hintStyle: const TextStyle(color: Colors.white38),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.white)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.length < 8) {
                              return 'Passwort muss länger als 8 Zeichen sein.';
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.white),
                          autofocus: false,
                          obscureText: true,
                          controller: passwordTextEditController,
                          textInputAction: TextInputAction.next,
                          focusNode: _passwordFocus,
                          onFieldSubmitted: (term) {
                            FocusScope.of(context)
                                .requestFocus(_confirmPasswordFocus);
                          },
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.white38),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.white)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          autofocus: false,
                          obscureText: true,
                          controller: confirmPasswordTextEditController,
                          focusNode: _confirmPasswordFocus,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (passwordTextEditController.text.length > 8 &&
                                passwordTextEditController.text != value) {
                              return 'Passwörter stimmen nicht überein!';
                            }
                            return null;
                          },
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Password bestätigen',
                            hintStyle: const TextStyle(color: Colors.white38),
                            contentPadding: const EdgeInsets.fromLTRB(
                                20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                                borderSide: const BorderSide(
                                    width: 1, color: Colors.white)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: const BorderSide(
                                    color: Colors.lightGreen,
                                  ))),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _firebaseAuth
                                  .createUserWithEmailAndPassword(
                                      email: emailTextEditController.text,
                                      password: passwordTextEditController.text)
                                  .then((uid) {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(_firebaseAuth.currentUser?.uid)
                                    .set({
                                  'firstName': firstNameTextEditController.text,
                                  'lastName': lastNameTextEditController.text,
                                  'email': emailTextEditController.text,
                                }).then((userInfoValue) {
                                  Navigator.of(context).pushNamed(Login.tag);
                                  Fluttertoast.showToast(
                                      msg: 'User erfolgreich registriert!',
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 3,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0);

                                });
                              }).catchError((onError) {
                                processError(onError);
                              });
                            }
                          },
                          child: Text('Sign Up'.toUpperCase(),
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.zero,
                          child: TextButton(
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ))
                    ],
                  )))),
    ]));
  }
}
