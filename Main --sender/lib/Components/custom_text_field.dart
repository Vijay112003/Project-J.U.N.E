import 'package:flutter/material.dart';
import 'package:pc_connect/Config/text_theme.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final Widget icon;
  final int maxLines;
  final int? maxLength; // Nullable max length
  final String? Function(String?)? validator;
  final bool isEnabled; // New property to enable/disable the field
  final String inputType;
  final Function()? onClicked;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.icon = const Icon(Icons.edit, color: Colors.transparent),
    this.maxLines = 1,
    this.maxLength, // Nullable, no default value
    this.validator,
    this.isEnabled = true, // Default is true, allowing editing
    this.inputType = 'text',
    this.onClicked,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late ValueNotifier<int> _charCountNotifier;

  @override
  void initState() {
    super.initState();
    _charCountNotifier = ValueNotifier<int>(widget.controller.text.length);
    widget.controller.addListener(_updateCharCount);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateCharCount);
    _charCountNotifier.dispose();
    super.dispose();
  }

  void _updateCharCount() {
    _charCountNotifier.value = widget.controller.text.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          onTap: widget.onClicked,
          controller: widget.controller,
          keyboardType: widget.inputType == 'number'
              ? TextInputType.number
              : TextInputType.text,
          maxLength: widget.maxLength, // Apply maxLength if provided
          decoration: InputDecoration(
            hintText: widget.label,
            filled: true,
            fillColor: widget.isEnabled ? Colors.grey[200] : Colors.grey[400],
            hintStyle: widget.isEnabled
                ? MyTextTheme.normal
                : MyTextTheme.normal.copyWith(color: Colors.white),
            suffixIcon: widget.icon,
            suffixIconColor: Colors.grey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            counterText: '', // Hide default counter if maxLength is present
          ),
          maxLines: widget.maxLines,
          validator: widget.validator,
          enabled: widget.isEnabled, // Set the enabled state here
        ),
        if (widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: ValueListenableBuilder<int>(
              valueListenable: _charCountNotifier,
              builder: (context, charCount, _) {
                return Text(
                  '$charCount / ${widget.maxLength} characters',
                  style: MyTextTheme.headline.copyWith(
                    color: charCount > (widget.maxLength ?? 0)
                        ? Colors.red
                        : Colors.grey,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
