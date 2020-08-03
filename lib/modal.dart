import 'package:cogbeh/constants.dart';
import 'package:cogbeh/thoughtModel.dart';
import 'package:flutter/material.dart';

import 'Database.dart';

class ModalBottomSheet extends StatefulWidget {
  final callback;
  ModalBottomSheet(this.callback);
  @override
  _ModalBottomSheetState createState() => _ModalBottomSheetState();
}

class _ModalBottomSheetState extends State<ModalBottomSheet> {
  final textController = TextEditingController();
  var _selected = List<bool>.generate(distortionList.length, (i) => false);

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  Future<void> _addThought() async {
    var thought = ThoughtModel(
        content: textController.text,
        distortions: _selected.toString(),
        datetime: DateTime.now().toString());
    if (thought.content.isNotEmpty) {
      thought.id = await DBProvider.db.newThought(thought);
      widget.callback(thought);
    }
    Navigator.of(context).pop();
  }

  Widget _buildRow(int i) {
    Distortion distortion = distortionList[i];
    return Container(
      decoration: BoxDecoration(
          color: _selected[i] == true ? Colors.lightBlue.shade100 : null,
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: ListTile(
        leading: Text(distortion.emoji),
        title: Text(distortion.name),
        subtitle: Text(distortion.description + "\n" + distortion.example),
        onTap: () {
          setState(() {
            _selected[i] = !_selected[i];
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.8,
        minChildSize: 0.6,
        expand: false,
        builder: (_, controller) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Новое высказывание",
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 18.0),
                    ),
                    RaisedButton(
                      onPressed: _addThought,
                      color: Colors.blue,
                      child: Text(
                        'Добавить',
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 6.0),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(hintText: 'Введите мысль'),
                  style: TextStyle(fontSize: 14.0),
                ),
                SizedBox(height: 12.0),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    separatorBuilder: (BuildContext context, int index) =>
                        SizedBox(height: 6.0),
                    itemCount: distortionList.length,
                    itemBuilder: (context, i) => _buildRow(i),
                  ),
                )
              ],
            ),
          );
        });
  }
}
