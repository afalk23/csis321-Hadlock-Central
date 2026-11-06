import 'package:flutter/material.dart';
import 'package:hadlock_central_flutter/pages/register_page.dart';
import 'package:hadlock_central_flutter/widgets/form_text_field.dart';
import 'package:hadlock_central_flutter/main.dart';
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
            onPressed: () {
              /// When the sign-in button is pressed, the postData function is called to send the sign-in data to
              /// the server.
              postData('/login', {
                'email': emailController.text,
                'password': passwordController.text,
              }).then(
                (value) async => {
                  /// If the sign-in is successful, an AlertDialog is shown with a success message, and the user
                  /// is navigated to the AppShell.
                  if (value['success'] == true)
                    {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(value['message']),
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
                      ).then(
                        (value) => {
                          Navigator.of(context).pop(),
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AppShell(),
                            ),
                          ),
                        },
                      ),
                    }
                  /// If the sign-in fails, an AlertDialog is shown with an error message.
                  else if (value['success'] == false)
                    {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(content: Text(value['message']));
                        },
                      ),
                    },
                },
              );
            },

            /// The child of the TextButton is a Text widget that displays "Login".
            child: const Text('Login'),
          ),

          /// The TextButton widget is used to navigate to the RegisterPage for creating a new account.
          TextButton(
            onPressed: () {
              /// When the "Create Account" button is pressed, the user is navigated to the RegisterPage.
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const RegisterPage()),
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
