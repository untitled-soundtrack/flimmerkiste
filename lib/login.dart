import 'package:flimmerkiste/home.dart';
import 'package:flimmerkiste/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flimmerkiste/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Login extends StatefulWidget {
  static String tag = 'login-page';

  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  //
  // Note: This is a GlobalKey<FormState>, not a GlobalKey<MyCustomFormState>!
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String _errorMessage = '';

  void onChange() {
    setState(() {
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    emailController.addListener(onChange);
    passwordController.addListener(onChange);

    final logo = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/logos/logo-flimmerkiste.png',
        alignment: Alignment.topCenter,
        fit: BoxFit.fitWidth,
      ),
    );

    final errorMessage = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _errorMessage,
        style: const TextStyle(fontSize: 14.0, color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );

    final email = TextFormField(
      validator: (value) {
        if (value!.isEmpty || !value.contains('@')) {
          return 'Bitte geben Sie ihre Email ein.';
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      controller: emailController,
      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: const TextStyle(color: Colors.white38),
        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: const BorderSide(width: 1, color: Colors.white)),
      ),
      textInputAction: TextInputAction.next,
      onEditingComplete: () => node.nextFocus(),
    );

    final password = TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return 'Bitte geben Sie ihr Passwort ein.';
        }
        return null;
      },
      style: const TextStyle(color: Colors.white),
      autofocus: false,
      obscureText: true,
      controller: passwordController,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (v) {
        FocusScope.of(context).requestFocus(node);
      },
      decoration: InputDecoration(
        hintText: 'Passwort',
        hintStyle: const TextStyle(color: Colors.white38),
        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(32),
            borderSide: const BorderSide(width: 1, color: Colors.white)),
      ),
    );

    final loginButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(
                  color: Colors.grey,
                ))),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            signIn(emailController.text, passwordController.text)
                .then<void>((value) => {
                      if (value != null)
                        {
                          Navigator.of(context).pushNamed(HomePage.tag),
                          Fluttertoast.showToast(
                              msg: "Erfolgreich eingeloggt.",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.SNACKBAR,
                              timeInSecForIosWeb: 3,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0)
                        }
                    })
                .catchError((error) => {processError(error)});
          }
        },
        child: const Text('LOG IN', style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = TextButton(
      child: const Text(
        'Passwort vergessen?',
        style: TextStyle(color: Colors.redAccent),
      ),
      onPressed: () {},
    );

    final notRegisteredLabel = TextButton(
      child: const Text(
        "Sie haben noch kein Konto? Registrieren",
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: () {
        Navigator.of(context).pushNamed(Register.tag);
      },
    );

    return Scaffold(
        backgroundColor: Colors.black,
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
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(50),
                children: <Widget>[
                  logo,
                  errorMessage,
                  const SizedBox(height: 12.0),
                  email,
                  const SizedBox(height: 10.0),
                  password,
                  const SizedBox(height: 10.0),
                  loginButton,
                  notRegisteredLabel,
                  forgotLabel
                ],
              ),
            ),
          ))
        ]));
  }

  Future<String> signIn(final String email, final String password) async {
    UserCredential user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.user!.uid;
  }

  void processError(final FirebaseAuthException error) {
    if (error.code == "user-not-found") {
      setState(() {
        _errorMessage = "Unable to find user. Please register.";
      });
    } else if (error.code == "wrong-password") {
      setState(() {
        _errorMessage = "Incorrect password.";
      });
    } else {
      setState(() {
        _errorMessage =
            "There was an error logging in. Please try again later.";
      });
    }
  }
}
