import 'package:cogbeh/Database.dart';
import 'package:cogbeh/constants.dart';
import 'package:cogbeh/thoughtModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'modal.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _thoughts = <ThoughtModel>[];

  bool _isLoading = true;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _hasMore = true;
    _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🧘 Automatica'),
      ),
      body: _buildStory(),
      floatingActionButton: FloatingActionButton(
        // backgroundColor: Colors.orange[400],
        onPressed: () {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => ModalBottomSheet(callback));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _loadMore() {
    print('loadmore');
    _isLoading = true;
    DBProvider.db.getNThought(_thoughts.length, 5).then((fetchedList) {
      if (fetchedList.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _thoughts.addAll(fetchedList);
        });
      }
    });
  }

  callback(ThoughtModel thought) {
    setState(() {
      _thoughts.insert(0, thought);
      // _hasMore = true;
    });
  }

  Widget _buildStory() {
    return ListView.builder(
        padding: EdgeInsets.all(4.0),
        itemCount: _hasMore ? _thoughts.length + 1 : _thoughts.length,
        itemBuilder: (context, index) {
          if (index >= _thoughts.length) {
            if (!_isLoading) {
              _loadMore();
            }
            return Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                height: 24,
                width: 24,
              ),
            );
          }
          ThoughtModel thought = _thoughts[index];
          String distortions = "";
          var splittedDistortions = thought.distortions
              .replaceAll(new RegExp(r"[[\],]"), "")
              .split(" ");
          for (int i = 0; i < splittedDistortions.length; i++) {
            String element = splittedDistortions[i];
            if (element == 'true') {
              distortions += distortionList[i].emoji + " ";
            }
          }
          return Dismissible(
              direction: DismissDirection.horizontal,
              onDismissed: (direction) {
                DBProvider.db.deleteThought(thought.id);
                setState(() {
                  _thoughts.removeAt(index);
                });
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text("${thought.content} dismissed")));
              },
              key: UniqueKey(),
              child: Card(
                  child: MyListItem(
                thought: thought.content,
                emojis: distortions,
                date: DateTime.parse(thought.datetime),
              )));
        });
  }
}

class MyListItem extends StatelessWidget {
  const MyListItem({this.thought, this.emojis, this.date});

  final String thought;
  final String emojis;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            thought,
            style: TextStyle(fontSize: 14.0),
          ),
          SizedBox(height: 5),
          Container(
            child: emojis.isNotEmpty
                ? Text(
                    emojis,
                    style: TextStyle(fontSize: 12.0),
                  )
                : null,
          ),
          SizedBox(height: 7),
          Text(
            DateFormat.yMd('ru_RU').add_jm().format(date.toLocal()),
            style: TextStyle(fontSize: 11.0),
          )
        ],
      ),
    );
  }
}
