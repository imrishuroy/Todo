import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_todo/blocs/todo/todo_bloc.dart';
import 'package:flutter_todo/screens/add_edit_todo_screen.dart';
import 'package:flutter_todo/widgets/display_image.dart';
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';

class DetailsScreen extends StatelessWidget {
  final String? id;

  DetailsScreen({Key? key, @required this.id}) : super(key: key);

  Future<void> _onOpen(LinkableElement link) async {
    await launch(link.url);

    // if (await canLaunch(link.url)) {
    //   await launch(link.url);
    // } else {
    //   throw 'Could not launch $link';
    // }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodosBloc, TodosState>(
      builder: (context, state) {
        final todo = (state as TodosLoaded)
            .todos
            // .firstWhere((todo) => todo.id == id, orElse: () => null);
            .firstWhere((todo) => todo.id == id);
        // print('-----');
        // print(todo.imageUrl.isEmpty);
        return Scaffold(
          // backgroundColor: Color(0xff222831),
          appBar: AppBar(
            title: Text('Todo Details'),
            actions: [
              IconButton(
                tooltip: 'Delete Todo',
                icon: Icon(Icons.delete),
                onPressed: () {
                  BlocProvider.of<TodosBloc>(context).add(DeleteTodo(todo));
                  Navigator.pop(context, todo);
                },
              )
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Checkbox(
                          value: todo.completed,
                          onChanged: (_) {
                            BlocProvider.of<TodosBloc>(context).add(
                              UpdateTodo(
                                todo.copyWith(completed: !todo.completed),
                              ),
                            );
                          }),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: '${todo.id}__heroTag',
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                top: 8.0,
                                bottom: 16.0,
                              ),
                              child: Text(
                                todo.title,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                            ),
                          ),

                          SelectableLinkify(
                            onOpen: _onOpen,
                            options: LinkifyOptions(humanize: false),
                            text: todo.todo,
                            style: Theme.of(context).textTheme.subtitle1,
                            linkStyle: TextStyle(color: Colors.blue),
                          ),
                          //   child: Text(

                          //     style: Theme.of(context).textTheme.subtitle1,
                          //   ),
                          // ),

                          SizedBox(height: 20.0),
                          Container(
                            height: 250.0,
                            width: 250.0,
                            child: DisplayImage(todo.imageUrl),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Edit Todo',
            child: Icon(Icons.edit),
            onPressed:
                //  todo == null
                //     ? null
                //     :
                () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AddEditScreen(
                      onSave: (title, todoString, imageUrl) {
                        BlocProvider.of<TodosBloc>(context).add(
                          UpdateTodo(
                            todo.copyWith(
                              title: title,
                              todo: todoString,
                              imageUrl: imageUrl,
                            ),
                          ),
                        );
                      },
                      isEditing: true,
                      todo: todo,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
