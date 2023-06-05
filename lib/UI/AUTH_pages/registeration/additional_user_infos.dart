import 'package:cloud_firestore/cloud_firestore.dart' as cloud;

import 'package:firebase_auth/firebase_auth.dart' as auth;
import "package:flutter/material.dart";
import 'package:my_project/UI/AUTH_pages/registeration/choose_business_type.dart';
import 'package:page_transition/page_transition.dart';

class AdditionalUserData extends StatefulWidget {
  const AdditionalUserData({Key? key}) : super(key: key);

  @override
  _AdditionalUserDataState createState() => _AdditionalUserDataState();
}

class _AdditionalUserDataState extends State<AdditionalUserData> {
  TextEditingController companyNameField = TextEditingController();
  TextEditingController locationField = TextEditingController();
  TextEditingController teamNumberField = TextEditingController();
  String selectedRole = "owner";
  String alerts = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            child: const Text(
              "Skip",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            onPressed: () {
              setState(() {
                selectedRole = "owner";
                companyNameField.clear();
                locationField.clear();
                teamNumberField.clear();
              });
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const BusinessSelection()));
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const FittedBox(
          child: Text(
            "About Your Business",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        //titleSpacing: MediaQuery.of(context).size.width ,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          // padding: const EdgeInsets.only(top: 8),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.868,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Center(
                      child: Container(
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height / 20,
                        child: Center(
                          child: Text(
                            alerts,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                    inputField(
                        controller: companyNameField,
                        hintText: "company name",
                        labelText: "Company Name"),
                    inputField(
                        controller: locationField,
                        hintText: "location",
                        labelText: "Location"),
                    inputField(
                        controller: teamNumberField,
                        hintText: "team number",
                        labelText: "Team Number"),
                    roleField(),
                  ],
                ),
                Column(
                  children: [
                    button(),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  /////temp

  //temp
  Widget inputField(
      {required TextEditingController controller,
      required String hintText,
      required String labelText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: TextField(
            onTap: () {
              setState(() {
                alerts = "";
              });
            },
            controller: controller,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 255, 160, 0),
                ),
              ),
              hintText: hintText,
              label: Text(labelText),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 255, 160, 0),
                ),
              ),
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

/*   Widget inputField(
      {required TextEditingController controller,
      required String hintText,
      required String labelText}) {
    return Card(
      elevation: 15,
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.transparent,
          ),
        ),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.08,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
              hintText: hintText,
              label: Text(labelText),
              border: InputBorder.none),
        ),
      ),
    );
  } */
/* 
  Widget roleField() {
    return Card(
      elevation: 15,
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: Colors.transparent,
          ),
        ),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.08,
        child: DropdownButton(
            isExpanded: true,
            value: selectedRole,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: const [
              DropdownMenuItem(
                child: Text("Role1", style: TextStyle(color: Colors.grey)),
                value: "none",
              ),
              DropdownMenuItem(
                child: Text("Role2"),
                value: "role2",
              ),
              DropdownMenuItem(
                child: Text("Role3"),
                value: "role3",
              )
            ],
            onChanged: (String? newRole) {
              selectedRole = newRole!;
              setState(() {});
            }),
      ),
    );
  }

   */
  Widget button() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          if (await addUserInfo()) {
            setState(() {
              selectedRole = "owner";
              companyNameField.clear();
              locationField.clear();
              teamNumberField.clear();
            });
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const BusinessSelection()));
          }
        },
        child: const Text("Continue"),
        style: ElevatedButton.styleFrom(
          elevation: 5,
          primary: const Color.fromARGB(255, 255, 160, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  Widget roleField() {
    return Container(
      //
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.09,
      child: DropdownButton(
          isExpanded: true,
          value: selectedRole,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: const [
            DropdownMenuItem(
              child: Text("Owner",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              value: "owner",
            ),
            DropdownMenuItem(
              child: Text("CEO",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              value: "ceo",
            ),
            DropdownMenuItem(
              child: Text("Investor",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              value: "investor",
            ),
            DropdownMenuItem(
              child: Text("Employee",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              value: "employee",
            ),
            DropdownMenuItem(
              child: Text("Other",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              value: "other",
            )
          ],
          onChanged: (String? newRole) {
            selectedRole = newRole!;
            setState(() {});
          }),
    );
  }

  //***************************** functions  ********************************/
  Future<bool> addUserInfo() async {
    try {
      String companyName = companyNameField.text;
      String location = locationField.text;
      String teamNumber = teamNumberField.text;
      String role = selectedRole;
      if (companyName.isNotEmpty &&
          location.isNotEmpty &&
          teamNumber.isNotEmpty) {
        String id = auth.FirebaseAuth.instance.currentUser!.uid;
        Map<String, dynamic> userData = {
          'companyName': companyName,
          'location': location,
          'teamNumber': teamNumber,
          'role': role,
        };
        await cloud.FirebaseFirestore.instance
            .collection("Participant")
            .doc(id)
            .collection('MoreUserInfo')
            .doc('info')
            .set(userData);
        print("user Data is added");
        return true;
      } else {
        setState(() {
          alerts = "Please fill all fields properly";
        });
        return false;
      }
    } on auth.FirebaseException catch (e) {
      print(e.code);

      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
