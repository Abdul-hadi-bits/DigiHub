import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class WhyUseDigihub extends StatefulWidget {
  const WhyUseDigihub({Key? key}) : super(key: key);

  @override
  _WhyUseDigihubState createState() => _WhyUseDigihubState();
}

class _WhyUseDigihubState extends State<WhyUseDigihub> {
  bool isTileEnabled = false;
  int selectedValue = 0;
  List<String> uses = [
    "I need a Tasker to manage my work on daily basis",
    "I need a digital wallet",
    "I want to learn more about bussiness",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "What Is Your Goal?",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
          ),

          //titleSpacing: MediaQuery.of(context).size.width ,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: Text(
                    "So We Can Help You The Best Way Possible",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            ListView.builder(
                addAutomaticKeepAlives: true,
                controller: ScrollController(keepScrollOffset: true),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: uses.length,
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      children: [
                        const Divider(
                          height: 10,
                        ),
                        Container(
                          // color: Colors.blueGrey,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            decoration: BoxDecoration(),
                            child: ListTile(
                              style: ListTileStyle.drawer,
                              title: Center(
                                  child: Text(
                                uses[index],
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              )),
                              selectedColor: Colors.black,
                              selectedTileColor:
                                  const Color.fromARGB(170, 255, 160, 0),
                              selected: selectedValue == index ? true : false,
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Colors.grey, width: 3),
                                  borderRadius: BorderRadius.circular(20)),
                              onTap: () {
                                setState(() {
                                  selectedValue = index;

                                  // Store the Date some where
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            Spacer(),
            Container(
              height: MediaQuery.of(context).size.height * 0.11,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  button(),
                ],
              ),
            )
          ],
        ));
  }

  Widget button() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          await addQueryToCloud();
          Navigator.of(context).pushNamedAndRemoveUntil(
              "/DigiHubPage",
              //MaterialPageRoute(builder: (context) => const DigiHub()),
              (Route<dynamic> route) => false);
        },
        child: const Text("Continue"),
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: const Color.fromARGB(255, 255, 160, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  Future<void> addQueryToCloud() async {
    try {
      String query = uses[selectedValue];
      Map<String, dynamic> userQuery = {
        'chosenUse': query,
      };
      await FirebaseFirestore.instance.collection("Query").doc().set(userQuery);
      print("user query is added");
    } on FirebaseAuthException catch (e) {
      print(e.code);
      print("query not added to cloud");
    } catch (e) {
      print(e);
      print("query not added to cloud");
    }
  }
}
