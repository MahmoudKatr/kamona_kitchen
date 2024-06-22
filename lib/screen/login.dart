import 'package:flutter/material.dart';
import 'package:kamona_kitchen/screen/get_sectionList.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  String _passwordStrength = "";

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      if (password.length < 6) {
        _passwordStrength = "Weak";
      } else if (password.length < 10) {
        _passwordStrength = "Medium";
      } else {
        _passwordStrength = "Strong";
      }
    });
  }

  void _login() {
    if (_emailController.text == "test@example.com" &&
        _passwordController.text == "password123") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AllSectionList()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                onChanged: _checkPasswordStrength,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Password Strength: $_passwordStrength',
                style: TextStyle(
                  color: _passwordStrength == "Weak"
                      ? Colors.red
                      : _passwordStrength == "Medium"
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
