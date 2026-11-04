import 'package:flutter/material.dart';

class FormTextField extends StatefulWidget {
  const FormTextField(
      {Key? key,
        required this.label,
        required this.textController,})
      : super(key: key);
  final String label;
  final TextEditingController textController;

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 25, 10, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextField(
          keyboardType: (widget.label == 'Date of Birth')
              ? TextInputType.datetime
              : TextInputType.text,
          controller: widget.textController,
          textInputAction: (widget.label == 'Password')
              ? TextInputAction.done
              : TextInputAction.next,
          obscureText: (widget.label == 'Password') ? true : false,
          decoration: InputDecoration(hintText: (widget.label == 'Date of Birth')? 'MM/DD/YYYY' : 'Please enter ${widget.label.toLowerCase()} here.'),
        ),
      ]),
    );
  }
}