import 'package:flutter/material.dart';

class EditNoteView extends StatefulWidget {
  const EditNoteView({super.key});

  @override
  State<EditNoteView> createState() => _EditNoteViewState();
}

class _EditNoteViewState extends State<EditNoteView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Edit Note View'),
      ),
    );
  }
}
