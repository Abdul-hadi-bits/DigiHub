import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MessegePage extends StatefulWidget {
  const MessegePage({Key? key}) : super(key: key);

  @override
  State<MessegePage> createState() => _MessegePageState();
}

class _MessegePageState extends State<MessegePage> {
  bool turn = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Sender Name"),
          titleSpacing: 70,
          toolbarHeight: 100,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 13.0),
              child: Container(
                height: MediaQuery.of(context).size.width / 8,
                width: MediaQuery.of(context).size.width / 8,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              ),
            )
          ],
        ),
        backgroundColor: Colors.grey,
        floatingActionButton: FloatingActionButton(
          child: Text("upload"),
          onPressed: () async {
            addToRealTimeDatabase();
          },
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              Expanded(
                flex: 9,
                child: ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15),
                      child: turn ? messegeBoxSend() : messegeBoxReceive(),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: messegeWriteSection(),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> addToRealTimeDatabase() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref("Participants/");
      print("try to ");

      await ref.update({
        "uid1": {
          "Name": "ali",
        }
      }).then((value) => print("data was added to realtime database"));
      print("finished");
    } on FirebaseException catch (e) {
      print("firebase exception " + e.code);
      print("data not added to database real");
    } catch (e) {
      print(e.toString());
      print("data not added to database real");
    }
  }

  Widget messegeWriteSection() {
    return Container(
      height: double.maxFinite,
      color: Colors.white,
      child: Align(
        alignment: Alignment.topLeft,
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          minLines: 1,
                          maxLines: null,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400),
                          decoration: InputDecoration(
                              hintText: "Message",
                              hintStyle: TextStyle(color: Color(0xFF00BFA5)),
                              border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: MediaQuery.of(context).size.width / 8,
                  decoration: const BoxDecoration(
                      color: Color(0xFF00BFA5), shape: BoxShape.circle),
                  child: InkWell(
                    child: Icon(Icons.send_outlined),
                    onLongPress: () {},
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget messegeBoxSend() {
    turn = false;
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: MediaQuery.of(context).size.width / 1.5,
          decoration: BoxDecoration(
              color: Colors.lightBlue.shade100,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              "hellow to everyone , today we got some news on an up comming event!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  Widget messegeBoxReceive() {
    turn = true;
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width / 1.5,
          decoration: BoxDecoration(
              color: Colors.lightBlue.shade100,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30))),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
                "hellow to everyone , today we got some news on an up comming event!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}
