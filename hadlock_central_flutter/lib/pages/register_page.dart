import 'package:flutter/material.dart';
import 'package:hadlock_central_flutter/functions/post_data_function.dart';
import 'package:hadlock_central_flutter/pages/sign_in_page.dart';
import 'package:hadlock_central_flutter/widgets/form_text_field.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: ListView(
        children: [
          FormTextField(label: "First Name", textController: fnController),
          FormTextField(label: "Last Name", textController: lnController),
          FormTextField(label: "Email", textController: emailController),
          FormTextField(label: "Password", textController: passwordController),
          TextButton(
            onPressed: () {
              postData('/register', {
                'email': emailController.text,
                'firstName': fnController.text,
                'lastName': lnController.text,
                'password': passwordController.text,
              }).then(
                (value) => {
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
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
