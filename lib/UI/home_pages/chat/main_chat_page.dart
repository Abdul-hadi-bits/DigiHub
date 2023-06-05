import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

import 'messege_page.dart';
import 'package:crypto/crypto.dart' as encrypt;

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String value = "";

  Map<String, dynamic> result = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Messeges",
          style: TextStyle(
              fontSize: 30,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        titleSpacing: 70,
      ),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        /* child: StreamBuilder<String>(
            initialData: "initial Value",
            stream: valueStreamer,
            builder: (context, snapshot) {
              return ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: GestureDetector(
                    onTap: () {
                      print("taped");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MessegePage()));
                    },
                    child: chatTile(snapshot.requireData),
                  ),
                ),
              );
            }),*/
      ), 
    );
  }

  Widget chatTile(String text) {
    print("isnide widget $text");
    return Center(
      child: Container(
        color: Colors.transparent,
        height: MediaQuery.of(context).size.height / 8,
        width: MediaQuery.of(context).size.width * 0.9,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.26,
              ),
              padding: EdgeInsets.all(3),
              height: MediaQuery.of(context).size.height / 8,
              child: SizedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 9, child: senderAndMessage(text)),
                    Expanded(flex: 2, child: messegeTime()),
                  ],
                ),
              ),
            ),
            Align(alignment: Alignment.centerLeft, child: avatar()),
            Align(alignment: Alignment.centerRight, child: newMessegesCounter())
          ],
        ),
      ),
    );
  }

  String updateRealTimeDataWithEventListener() {
    String output = "";
    String emailAddress = FirebaseAuth.instance.currentUser!.email.toString();
    String hashedEmailAddress =
        encrypt.sha256.convert(utf8.encode(emailAddress)).toString();
    DatabaseReference reference = FirebaseDatabase.instance
        .ref('UserData/$hashedEmailAddress/Conversations');
    reference.onValue.listen((DatabaseEvent event) {
      print(event.snapshot.value);
      if (event.snapshot.value != null) {
        result = Map<String, String>.from(
            event.snapshot.value! as Map<Object?, Object?>);

        output = result['conId'].toString();
      }
    });

    return output;
  }

  Widget newMessegesCounter() {
    return Container(
      width: MediaQuery.of(context).size.width / 14,
      height: MediaQuery.of(context).size.width / 14,
      child: Center(
        child: FittedBox(
          child: Text(
            "2",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
    );
  }

  Widget messegeTime() {
    return FittedBox(
      child: Text(
        "12:20",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget senderAndMessage(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            text,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text(
              "hello friend how is hadhijsoifjd your day, let me know if had time ..........................., so i can meet you in person. Alright? ther is somethign important",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              softWrap: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget avatar() {
    return Container(
      height: MediaQuery.of(context).size.width / 4,
      width: MediaQuery.of(context).size.width / 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.lightBlue,
      ),
    );
  }
}
