import 'package:flutter/material.dart';

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    required this.labelText,
    required this.hintText,
    super.key,
    this.controller,
    this.validator,
    this.prefixIcon,
  });

  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_resetIfEmpty);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_resetIfEmpty);
    super.dispose();
  }

  void _resetIfEmpty() {
    if ((widget.controller?.text.isEmpty ?? false) && !_obscured) {
      setState(() => _obscured = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscured,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon:
            widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
        suffixIcon: IconButton(
          icon: Icon(
            _obscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
