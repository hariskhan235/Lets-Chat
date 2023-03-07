import 'package:flutter/material.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        FocusScope.of(context).requestFocus(_focusNode);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            MaterialButton(
              onPressed: () {
                //_focusNode.requestFocus();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PopupMenuButton(
                  onOpened: () {},
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        child: Text('1'),
                      ),
                      PopupMenuItem(
                        child: Text('2'),
                      ),
                      PopupMenuItem(
                        child: Text('3'),
                      ),
                      PopupMenuItem(
                        child: Text('4'),
                      )
                    ];
                  },
                  child: Icon(Icons.more_vert),
                ),
              ),
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: TextFormField(
                      focusNode: _focusNode,
                      //autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Text Field',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
