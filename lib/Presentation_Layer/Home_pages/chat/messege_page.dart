
import 'package:flutter/material.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class MessegePage extends StatefulWidget {
  late final String image;
  late final String friendName;
  late final List<types.User> users;
  MessegePage(String image, String friendName, List<types.User> friendAndMe,
      {Key? key})
      : super(
          key: key,
        ) {
    this.image = image;
    this.friendName = friendName;
    this.users = friendAndMe;
  }

  @override
  State<MessegePage> createState() =>
      _MessegePageState(image, friendName, users);
}

class _MessegePageState extends State<MessegePage> {
  bool turn = false;

  late final String friendName;
  late final String image;
  late final List<types.User> users;
  TextEditingController messegeField = TextEditingController();

  _MessegePageState(image, friendName, List<types.User> users) {
    this.friendName = friendName;
    this.image = image;
    this.users = users;
  }
  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState

    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(friendName),
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
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(image: NetworkImage(image))),
              ),
            )
          ],
        ),
        backgroundColor: Colors.grey,
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
                child: StreamBuilder<List<types.Message>>(
                  initialData: const [],
                  stream: FirebaseChatCore.instance.messages(types.Room(
                      id: "9ARci4cN5sHmuDnmF4T6",
                      type: types.RoomType.direct,
                      users: users)),
                  builder: (context, snapshot) {
                    if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                      print(
                          "${snapshot.data}  hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhheeeeeeeeereeeeeeeeee");

                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                              padding:
                                  const EdgeInsets.only(left: 15.0, right: 15),
                              child: messegeBoxSend(snapshot.data![index]));
                        },
                      );
                    }
                    return Text("no messeges");

                    // ...
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

  /* Future<void> addToRealTimeDatabase() async {
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
  } */

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
                          controller: messegeField,
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
                    onLongPress: () async {
                      try {
                        types.PartialText text =
                            types.PartialText(text: messegeField.text);
                        FirebaseChatCore.instance
                            .sendMessage(text, "9ARci4cN5sHmuDnmF4T6");
                        print(
                            "messege sent  ************************************************************");
                      } catch (e) {
                        print(
                            "noooooooooooooooooooooooooooooooooooooooooooooooooooooooo, $e");
                      }
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget messegeBoxSend(types.Message data) {
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
              {data.toJson()["text"]}
                  .toString()
                  .replaceAll("{}", "")
                  .replaceAll("{", "")
                  .replaceAll("}", ""),
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
