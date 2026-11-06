import 'package:flutter/material.dart';
import 'package:hadlock_central_flutter/functions/post_data_function.dart';
import 'package:hadlock_central_flutter/pages/sign_in_page.dart';
import 'package:hadlock_central_flutter/widgets/form_text_field.dart';

/// RegisterPage is a StatefulWidget that allows users to create an account.
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController fnController = TextEditingController();
  TextEditingController lnController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  
  // Prevents multiple requests at the same time.
  bool _isSubmitting = false;

  Future<void> _submitRegistration() async {
    // Do not submit if a request is already running.
    if (_isSubmitting) {
      return;
    }

    // Check that all required fields contain information.
    if (fnController.text.trim().isEmpty ||
        lnController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showMessage('Please fill in all required fields.');
      return;
    }

    // Check that the email belongs to George Fox University.
    if (!emailController.text.trim().toLowerCase().endsWith('@georgefox.edu')) {
      _showMessage('Please use a George Fox University email (@georgefox.edu).');
      return;
    }

    // Disable the submit button while the request runs.
    setState(() {
      _isSubmitting = true;
    });

    try {
      final value = await postData('/register', {
        'email': emailController.text.trim(),
        'firstName': fnController.text.trim(),
        'lastName': lnController.text.trim(),
        'password': passwordController.text,
      });

      if (!mounted) return;

      if (value['success'] == true) {
        // Registration was successful.
        await _showMessage(
          value['message']?.toString() ??
              'Registration successful!',
        );

        if (!mounted) return;

        // Navigate to the sign-in page.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SignInPage(),
          ),
        );
      } else {
        // Registration failed; stay on the form.
        await _showMessage(
          value['message']?.toString() ??
              'Registration failed. Please try again.',
        );
      }
    } catch (error) {
      // Handle failed requests or unexpected errors.
      if (!mounted) return;

      await _showMessage(
        'Unable to complete registration. Please try again.',
      );
    } finally {
      // Allow another submission after the request finishes.
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  /// Displays a dialog with the provided message.
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

  @override
  void dispose() {
    fnController.dispose();
    lnController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// The build method constructs the UI for the RegisterPage.
    return Scaffold(
      /// The AppBar displays the title of the page.
      appBar: AppBar(title: const Text('Sign Up')),

      /// The body of the page contains a ListView with form fields and a submit button.
      body: ListView(
        children: [
          /// FormTextField widgets are used to create input fields for first name, last name, email, and password.
          FormTextField(label: "First Name", textController: fnController),
          FormTextField(label: "Last Name", textController: lnController),
          FormTextField(label: "Email", textController: emailController),
          FormTextField(label: "Password", textController: passwordController),

          /// The TextButton widget is used to submit the registration form.
          TextButton(
            /// The onPressed callback is disabled when a submission is in progress to prevent multiple requests.
            onPressed: _isSubmitting ? null : _submitRegistration,

            /// The child of the button displays a CircularProgressIndicator when submitting, and "Submit" text otherwise.
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
