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
            onPressed: () {
              /// When the submit button is pressed, the postData function is called to send the registration data to
              /// the server.
              postData('/register', {
                'email': emailController.text,
                'firstName': fnController.text,
                'lastName': lnController.text,
                'password': passwordController.text,
              }).then(
                (value) => {
                  /// If the registration is successful, an AlertDialog is shown with a success message, and the user
                  /// is navigated to the SignInPage.
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
                              builder: (context) => const SignInPage(),
                            ),
                          ),
                        },
                      ),
                    }
                  /// If the registration fails, an AlertDialog is shown with an error message.
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

            /// The child of the TextButton is a Text widget that displays "Submit".
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
