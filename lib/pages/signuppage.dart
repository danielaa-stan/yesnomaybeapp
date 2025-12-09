import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'interestspage.dart';
import 'package:yesnomaybeapp/auth.dart';
import 'emailverificationpage.dart';
import '../l10n/app_localizations.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // form key for validation
  final _formKey = GlobalKey<FormState>();

  String errorMessage = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // registration and email sending
  Future<void> _handleSignUp() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      errorMessage = '';
    });

    try {
      // creating user with Firebase Auth
      await Auth().createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // get the current user
      final user = FirebaseAuth.instance.currentUser;

      // sending email for confirmation
      if (user != null) {
        await user.sendEmailVerification();
      }

      // success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.accountCreated),
            backgroundColor: Color(0xFF4EE06D),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const EmailVerificationPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = l10n.passwordMustHaveAtLeast;
      } else if (e.code == 'email-already-in-use') {
        message = l10n.theEmailIsAlreadyInUse;
      } else {
        message = e.message ?? 'Registration failed. Try again.';
      }

      if (mounted) {
        setState(() {
          errorMessage = message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'An unexpected error occurred: $e';
        });
      }
    }
  }

  // errors displaying
  Widget _errorMessageWidget() {
    final l10n = AppLocalizations.of(context)!;
    if (errorMessage.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        '${l10n.hummm} $errorMessage',
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
                  // "Create account" title
                  Center(
                    child: Text(
                      l10n.createAccount,
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
                    ),
                    validator: (value) {
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
                    validator: (value) { // password validation
                      if (value == null || value.isEmpty) {
                        return l10n.passwordCannotBeEmpty;
                      }
                      if (value.length < 6) {
                        return l10n.passwordMustHaveAtLeast;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  _errorMessageWidget(),

                  // Terms and conditions checkbox row
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return const Color(0xFF4EE06D); // Green when checked
                            }
                            return Colors.white; // White when unchecked
                          },
                        ),
                      ),
                      // Terms and conditions text
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: l10n.agreeWith,
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                            children: [
                              TextSpan(
                                text: l10n.termsAndCond,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4EE06D),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // Sign Up button
                  ElevatedButton(
                    onPressed: () {
                      //validation form
                      if (_formKey.currentState!.validate()) {
                        // validation is successfull -> check checkbox
                        if (_agreedToTerms) {
                          _handleSignUp();
                        } else {
                          setState(() {
                            errorMessage = l10n.termsAndCondMessage;
                          });
                        }
                      } else {
                        // validation failed, display errors
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
                      l10n.signUpButton,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // "Already have an account? Sign in" clickable text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAnAccount,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      // "Sign in" text that navigates to login page
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: Text(
                          l10n.signIn,
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