import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfile extends StatefulWidget {
  EditProfile({Key? key});

  TextEditingController emailTextEditController = TextEditingController();
  TextEditingController firstNameTextEditController = TextEditingController();
  TextEditingController lastNameTextEditController = TextEditingController();
  TextEditingController passwordTextEditController = TextEditingController();
  TextEditingController confirmPasswordTextEditController =
      TextEditingController();

  @override
  _EditProfileState2 createState() => _EditProfileState2();
}

class _EditProfileState2 extends State<EditProfile> {
  final emailTextEditController = TextEditingController();
  final firstNameTextEditController = TextEditingController();
  final lastNameTextEditController = TextEditingController();
  final passwordTextEditController = TextEditingController();
  final confirmPasswordTextEditController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final String _errorMessage = '';

  final _reference = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid);

  final Stream _usersStream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .snapshots();
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          var userDocument = snapshot.data;
          Future.delayed(const Duration(milliseconds: 100), () {
            if (firstNameTextEditController.text == '' &&
                emailTextEditController.text == '' &&
                lastNameTextEditController.text == '') {
              firstNameTextEditController.text = userDocument['firstName'];
              lastNameTextEditController.text = userDocument['lastName'];
              emailTextEditController.text = userDocument['email'];
            }
          });

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
                                'Profildaten Ändern',
                                style: TextStyle(
                                    fontSize: 36.0, color: Colors.white),
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
                                  hintStyle:
                                      const TextStyle(color: Colors.white38),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.white)),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Bitte geben Sie ihren Vornamen ein.';
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
                                  FocusScope.of(context)
                                      .requestFocus(_lastNameFocus);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Vorname',
                                  hintStyle:
                                      const TextStyle(color: Colors.white38),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.white)),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                style: const TextStyle(color: Colors.white),
                                controller: lastNameTextEditController,
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                textInputAction: TextInputAction.next,
                                focusNode: _lastNameFocus,
                                onFieldSubmitted: (term) {
                                  FocusScope.of(context)
                                      .requestFocus(_passwordFocus);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Nachname',
                                  hintStyle:
                                      const TextStyle(color: Colors.white38),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.white)),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                style: const TextStyle(color: Colors.white),
                                autofocus: false,
                                obscureText: true,
                                controller: passwordTextEditController,
                                textInputAction: TextInputAction.next,
                                focusNode: _passwordFocus,
                                validator: (value) {
                                  if(
                                  passwordTextEditController.text.isNotEmpty && passwordTextEditController.text.length < 8){
                                  return 'Passwort muss länger als 8 Zeichen sein.';
                                  }
                                  else {
                                  return null;
                                  }
                                },
                                onFieldSubmitted: (term) {
                                  FocusScope.of(context)
                                      .requestFocus(_confirmPasswordFocus);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Passwort',
                                  hintStyle:
                                      const TextStyle(color: Colors.white38),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32),
                                      borderSide: const BorderSide(
                                          width: 1, color: Colors.white)),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                autofocus: false,
                                obscureText: true,
                                controller: confirmPasswordTextEditController,
                                focusNode: _confirmPasswordFocus,
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (passwordTextEditController.text.length >
                                          8 &&
                                      passwordTextEditController.text !=
                                          value) {
                                    return 'Passwörter stimmen nicht überein.';
                                  }
                                  else if(
                                  confirmPasswordTextEditController.text.isNotEmpty && passwordTextEditController.text.isEmpty){
                                    return 'Bitte geben Sie ein neues Passwort ein.';
                                  }
                                  else {
                                    return null;
                                  }
                                },
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Passwort bestätigen',
                                  hintStyle:
                                      const TextStyle(color: Colors.white38),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      20.0, 10.0, 20.0, 10.0),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(32.0)),
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
                                          borderRadius:
                                              BorderRadius.circular(24),
                                          side: const BorderSide(
                                            color: Colors.lightGreen,
                                          ))),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      String name =
                                          firstNameTextEditController.text;
                                      String lastname =
                                          lastNameTextEditController.text;
                                      String email =
                                          emailTextEditController.text;
                                      String password =
                                          passwordTextEditController.text;

                                      //Create the Map of data
                                      Map<String, String> dataToUpdate = {
                                        'firstName': name,
                                        'lastName': lastname,
                                        'email': email,
                                      };
                                      //Call update()
                                      _reference
                                          .update(dataToUpdate)
                                          .then((value) =>
                                              user?.updateEmail(email))
                                          .then((value) => user
                                              ?.updatePassword(password)
                                              .whenComplete(() =>
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Profil erfolgreich aktualisiert!",
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 1,
                                                      backgroundColor: Colors.green,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0))
                                              .catchError((error) =>
                                                  Fluttertoast.showToast(
                                                      msg: error,
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity:
                                                          ToastGravity.BOTTOM,
                                                      timeInSecForIosWeb: 1,
                                                      textColor: Colors.white,
                                                      fontSize: 16.0)));

                                      Navigator.pop(context);
                                    }
                                  },
                                  child: const Text('Speichern')),
                            ),
                            Padding(
                                padding: EdgeInsets.zero,
                                child: TextButton(
                                  child: const Text(
                                    'Abbrechen',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                )),
                          ],
                        )))),
          ]));
        });
  }
}
