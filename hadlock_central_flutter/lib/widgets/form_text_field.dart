import 'package:flutter/material.dart';

/// FormTextField is a StatefulWidget that creates a labeled text input field.
class FormTextField extends StatefulWidget {
  const FormTextField({
    super.key,
    required this.label,
    required this.textController,
  });
  final String label;
  final TextEditingController textController;

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  @override
  Widget build(BuildContext context) {
    /// The build method constructs the UI for the FormTextField widget.
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 25, 10, 0),

      /// The child of the Container is a Column that contains a Text widget for the label and a TextField
      /// for user input.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// The Text widget displays the label for the input field.
          Text(
            widget.label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          /// The TextField widget allows the user to input text, with properties set based on the label.
          TextField(
            /// The keyboardType is set to datetime for the "Date of Birth" label, and text for other labels.
            keyboardType: (widget.label == 'Date of Birth')
                ? TextInputType.datetime
                : TextInputType.text,
            controller: widget.textController,

            /// The textInputAction is set to done for the "Password" label, and next for other labels.
            textInputAction: (widget.label == 'Password')
                ? TextInputAction.done
                : TextInputAction.next,

            /// The obscureText property is set to true for the "Password" label to hide the input text,
            /// and false for other labels.
            obscureText: (widget.label == 'Password') ? true : false,

            /// The decoration property sets the hint text for the input field based on the label.
            decoration: InputDecoration(
              hintText: (widget.label == 'Date of Birth')
                  ? 'MM/DD/YYYY'
                  : 'Please enter ${widget.label.toLowerCase()} here.',
            ),
          ),
        ],
      ),
    );
  }
}
