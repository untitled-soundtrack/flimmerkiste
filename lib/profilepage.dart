import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flimmerkiste/home.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'editprofile.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static String tag = 'profile-page';

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final imgPicker = ImagePicker();

  List<String> documentIds = [];
  Map<String, List<String>> idToArray = {};

  void getDocumentIdsInCollection() {
    FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) => {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          documentIds.add(doc.id);
          List<dynamic> array = doc['title'];
          List<String> stringArray =
          array.map((element) => element.toString()).toList();
          idToArray[doc.id] = stringArray;
        });
      })
    });
  }

  String imageUrl = 'https://logodix.com/logo/360469.png';
  File? imgFile;
  final Stream _usersStream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .snapshots();
  final Stream _favoritesStream = FirebaseFirestore.instance
      .collection('favorites')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .snapshots();
  Future<void> showOptionsDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Upload Picture"),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  GestureDetector(
                    child: const Text("CAMERA"),
                    onTap: () {
                      saveByCamera();
                      Navigator.pop(context);
                    },
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                  GestureDetector(
                    child: const Text("GALLERY"),
                    onTap: () {
                      saveByGallery();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    List<String> ids = [];
    for (int i = 0 ; i < documentIds.length; i++) {
      ids.add(documentIds[i]);
    }
     return StreamBuilder(
        stream: _usersStream,
        builder: (context, snapshot1) {
          return StreamBuilder(
              stream: _favoritesStream,
              builder: (context, snapshot2) {
                if (snapshot1.hasError) {
                  return const Text('Something went wrong');
                } else if (!snapshot1.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot1.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
          var userDocument = snapshot1.data;
          var favDocument = snapshot2.data;
          var channel = favDocument['channel'];
          var channelName;

          if (channel.toString().contains('ARD')){
            channelName = "SR";
          }else if(
          channel.toString().contains('SR')){
            channelName = "SR";
          }
          return Scaffold(
              appBar: AppBar(
                title: const Text('Profil'),
                backgroundColor: Colors.black,
                titleTextStyle: const TextStyle(color: Colors.white),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Stack(children: <Widget>[
                Container(
                    decoration: const BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage("assets/backgrounds/black_background.jpg"),
                    fit: BoxFit.fill,
                  ),
                )),
                Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                              height: 350.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.deepPurple.withOpacity(0.0),
                                        Colors.black,
                                      ],
                                      stops: const [
                                        0.0,
                                        1.0
                                      ]))),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              width: 200,
                              height: 260,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircleAvatar(
                                          radius: 30.0,
                                          backgroundImage: NetworkImage(
                                            imageUrl,
                                          ))),
                                  Positioned(
                                    bottom: 50,
                                    right: 20,
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      child: Container(
                                        margin: const EdgeInsets.all(1.0),
                                        decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 10, top: 0, right: 10, bottom: 0),
                        child: Column(
                          children: [
                            Text(
                              "${userDocument['firstName']} ${userDocument['lastName']}",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontFamily: "Times New Roman"),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${userDocument['email']}",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Courier New'),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FloatingActionButton.extended(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfile()));
                                  },
                                  heroTag: 'infos',
                                  elevation: 0,
                                  label: const Text("Daten andern"),
                                  icon: const Icon(Icons.person_add_alt_1),
                                ),
                                const SizedBox(width: 16.0),
                                FloatingActionButton.extended(
                                  onPressed: () {
                                    showOptionsDialog(context);
                                  },
                                  heroTag: 'picture',
                                  elevation: 0,
                                  backgroundColor: Colors.red,
                                  label: const Text("Bild ändern"),
                                  icon: const Icon(Icons.image),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const _ProfileInfoRow(),
                            const SizedBox(height: 16),
                            Text(
                              "Deine Favoriten:",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            IntrinsicHeight(
                              child: Container(
                                width: double.infinity,
                                height: MediaQuery.of(context).size.height * 0.15,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: ids.length,
                                  itemBuilder: (BuildContext context, int i) {
                                    String imagePath = "assets/channels/${ids[i]}.png";
                                    String id = documentIds[i];
                                    List<String>? array = idToArray[id];
                                    String element = array![0]; // change this to get the first element of the array
                                    return Container(
                                      height: 0,
                                      width: MediaQuery.of(context).size.height * 0.17,
                                      child: Card(
                                        child: Column(
                                          children: [
                                            Image.asset(imagePath, height: 80),
                                            Text(element, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.018, fontWeight: FontWeight.w600),), // add the text here
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ]));
        });
  }
  );
  }

  void saveByCamera() async {
    var imgCamera = await imgPicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 75,
    );
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${FirebaseAuth.instance.currentUser!.uid}.jpg");
    await ref.putFile(File(imgCamera!.path));
    Fluttertoast.showToast(
        msg: "Neues Bild hochgeladen!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    loadImage();
    if (!mounted) return;
  }

  void saveByGallery() async {
    var imgGallery = await imgPicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 75,
    );
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${FirebaseAuth.instance.currentUser!.uid}.jpg");
    await ref.putFile(File(imgGallery!.path));
    Fluttertoast.showToast(
        msg: "Neues Bild hochgeladen!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
    loadImage();
    if (!mounted) return;
  }

  void loadImage() async {
    imageUrl = await FirebaseStorage.instance
        .ref()
        .child("${FirebaseAuth.instance.currentUser!.uid}.jpg")
        .getDownloadURL();
    setState(() {
      imgFile = File(imageUrl);
    });
    if (!mounted) return;
  }

  @override
  void initState() {
    super.initState();
    loadImage();
    getDocumentIdsInCollection();
  }
}

class _ProfileInfoRow extends StatelessWidget {
 const _ProfileInfoRow({Key? key}) : super(key: key);

  final List<ProfileInfoItem> _items = const [
    ProfileInfoItem("Favoriten", "10"),
    ProfileInfoItem("Gesamtdauer", "120 min"),
    ProfileInfoItem("Gesamtzahl der Abspiele", "200"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _items
            .map((item) => Expanded(
                    child: Row(
                  children: [
                    if (_items.indexOf(item) != 0) const VerticalDivider(),
                    Expanded(child: _singleItem(context, item)),
                  ],
                )))
            .toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.value.toString(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
          Text(item.title, style: const TextStyle(color: Colors.white))
        ],
      );
}

class ProfileInfoItem {
  final String title;
  final String value;

  const ProfileInfoItem(this.title, this.value);
}
