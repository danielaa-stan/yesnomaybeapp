import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yesnomaybeapp/auth.dart';
import 'signuppage.dart';
import 'homepage.dart';
import '../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // GlobalKey for form validation
  final _formKey = GlobalKey<FormState>();

  String errorMessage = '';
  bool isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInUser() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      errorMessage = ''; //clean previous errors
    });

    try {
      await Auth().signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // successful login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.loggedInSuccessfully),
            backgroundColor: Color(0xFF4EE06D),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = l10n.invalidEmailOrPassword;
      } else {
        message = e.message ?? 'An unknown error occurred.';
      }

      if (mounted) {
        setState(() {
          errorMessage = message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'An error occurred: $e';
        });
      }
    }
  }

  // for displaying error
  Widget _errorMessageWidget() {
    if (errorMessage.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        errorMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF1A4D4D),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 120),

                  // "Sign in" title at the top
                  Center(
                    child: Text(
                      l10n.signIn,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email input field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) { // email validation
                      if (value == null || value.trim().isEmpty) {
                        return l10n.emailCannotBeEmpty;
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return l10n.enterValidEmailFormat;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password input field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: l10n.passwordHint,
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) { // Password validation
                      if (value == null || value.isEmpty) {
                        return l10n.passwordCannotBeEmpty;
                      }
                      //min password length
                      if (value.length < 6) {
                        return l10n.passwordMustHaveAtLeast;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  _errorMessageWidget(),

                  const SizedBox(height: 80),

                  // SIGN IN button
                  ElevatedButton(
                    onPressed: () {
                      //form validation
                      if (_formKey.currentState!.validate()) {
                        _signInUser(); //firebase called only after successful validation
                      } else {
                        //the errors are displayed under the fields
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4EE06D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      l10n.signInButton,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // "Don't have an account? Sign up" clickable text at bottom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.dontHaveAccount,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: Text(
                          l10n.signUp,
                          style: TextStyle(
                            color: Color(0xFF4EE06D),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}