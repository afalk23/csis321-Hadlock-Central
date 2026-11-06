import 'package:flutter/material.dart';
import 'package:hadlock_central_flutter/pages/register_page.dart';
import 'package:hadlock_central_flutter/widgets/form_text_field.dart';
import 'package:hadlock_central_flutter/main.dart';
import 'package:hadlock_central_flutter/models/student_account.dart';
import 'package:hadlock_central_flutter/functions/post_data_function.dart';

/// SignInPage is a StatefulWidget that allows users to sign in to their account.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// Prevent multiple sign-in requests.
  bool _isSubmitting = false;

  /// Submits sign-in information to the server.
  Future<void> _submitSignIn() async {
    /// Prevent repeated submissions.
    if (_isSubmitting) {
      return;
    }

    /// Check that email and password are not empty.
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      await _showMessage('Please enter your email and password.');
      return;
    }

    /// Disable the Login button during the request.
    setState(() {
      _isSubmitting = true;
    });

    try {
      final value = await postData('/login', {
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });

      if (!mounted) return;

      if (value['success'] == true) {
        final user = value['user'];
        if (user is! Map<String, dynamic>) {
          await _showMessage('Your account details could not be loaded.');
          return;
        }
        final account = StudentAccount.fromJson(user);

        /// Sign-in successful.
        await _showMessage(value['message']?.toString() ?? 'Login successful!');

        if (!mounted) return;

        /// Navigate to the main application.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AppShell(account: account)),
        );
      } else {
        /// Sign-in failed. Stay on the sign-in page.
        await _showMessage(
          value['message']?.toString() ??
              'Login failed. Please check your credentials.',
        );
      }
    } catch (error) {
      /// Handle server or connection errors.
      if (!mounted) return;

      await _showMessage('Unable to sign in. Please try again.');
    } finally {
      /// Re-enable the Login button after processing.
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// Displays a message to the user.
  Future<void> _showMessage(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  /// Dispose of the controllers when the widget is removed from the widget tree.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// The build method constructs the UI for the SignInPage.
    return Scaffold(
      /// The AppBar displays the title of the page.
      appBar: AppBar(title: const Text('Sign In')),

      /// The body of the page contains a ListView with form fields and buttons for signing in and creating an account.
      body: ListView(
        children: [
          /// FormTextField widgets are used to create input fields for email and password.
          FormTextField(label: "Email", textController: emailController),
          FormTextField(label: "Password", textController: passwordController),

          /// The TextButton widget is used to submit the sign-in form.
          TextButton(
            /// The onPressed callback is disabled when a submission is in progress to prevent multiple requests.
            onPressed: _isSubmitting ? null : _submitSignIn,

            /// The child of the button displays a CircularProgressIndicator when submitting, and "Login" text otherwise.
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : const Text('Login'),
          ),

          /// The TextButton widget is used to navigate to the RegisterPage for creating a new account.
          TextButton(
            /// The onPressed callback is disabled when a submission is in progress to prevent navigation during sign-in.
            onPressed: _isSubmitting
                ? null
                : () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },

            /// The child of the TextButton is a Text widget that displays "Create Account".
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }
}
