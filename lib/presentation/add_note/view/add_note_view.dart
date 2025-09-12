import 'package:flutter/material.dart';

class AddNoteView extends StatefulWidget {
  const AddNoteView({super.key});

  @override
  State<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends State<AddNoteView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Note View'),
      ),
    );
  }
}
