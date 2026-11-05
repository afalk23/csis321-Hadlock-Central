import 'package:flutter/material.dart';
import 'package:hadlock_central_flutter/pages/form_text_field.dart';
import 'package:hadlock_central_flutter/main.dart';
import 'package:hadlock_central_flutter/functions/post_data_function.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: ListView(
        children: [
          FormTextField(label: "Email", textController: emailController),
          FormTextField(label: "Password", textController: passwordController),
          TextButton(
            onPressed: () {
              postData('/login', {
                'email': emailController.text,
                'password': passwordController.text,
              }).then(
                (value) async => {
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
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => const AppShell()));
            },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }
}
