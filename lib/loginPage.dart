import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard.dart';
import 'signUp.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Rail Mitra')),
        backgroundColor: Color(0xFF004080),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0268B2), Color(0xFF004080)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              margin: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/chat.png',
                      height: 100,
                      width: 100,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(_usernameController, 'Username'),
                    SizedBox(height: 20),
                    _buildPasswordField(_passwordController, 'Password'),
                    SizedBox(height: 20),
                    _buildLoginButton(),
                    SizedBox(height: 10),
                    _buildSignUpButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: controller,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: controller,
          obscureText: !_isPasswordVisible,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF004080),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: _isLoading
          ? Padding(
        padding: const EdgeInsets.all(12.0),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : TextButton(
        onPressed: () async {
          await _login();
        },
        child: Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage(),
          ),
        );
      },
      child: Text(
        "Don't have an account? Sign up",
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text,
        password: _passwordController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(),
        ),
      );
    } catch (e) {
      String errorMessage = e.toString();

      if (errorMessage.contains('user-not-found')) {
        errorMessage = "Looks like you have not registered! Please sign up.";
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Authentication Failed'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpPage(),
                      ),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Authentication Failed'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Rail Mitra',
    home: LoginPage(),
    theme: ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF004080),
        foregroundColor: Colors.white,
      ),
    ),
  ));
}
