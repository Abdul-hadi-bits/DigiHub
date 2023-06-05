import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/UI/home_pages/settings/change_phone_num/change_phone_num.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart' as cache_images;
import 'package:connectivity_plus/connectivity_plus.dart' as network_connection;
import 'package:crypto/crypto.dart' as encrypt;

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? image;
  String error = "";
  String imageUrl = '';
  String firstName = "";
  String lastName = "Enter Last Name";
  String location = "Enter a Location";

  bool networkConnection = false;
  late StreamSubscription<network_connection.ConnectivityResult> subscription;
  String langauge = "";
  late FToast ftoast;

  @override
  void initState() {
    super.initState();
    getUserData();
    ftoast = FToast();
    ftoast.init(context);

    subscription = network_connection.Connectivity()
        .onConnectivityChanged
        .listen((network_connection.ConnectivityResult result) {
      if (result != network_connection.ConnectivityResult.none) {
        print("has connection");
        print(result.name);
        networkConnection = true;
      } else {
        print("does not have connection");
        networkConnection = false;
      }
      getUserData();
    });
    network_connection.Connectivity().checkConnectivity().then((value) {
      networkConnection =
          value != network_connection.ConnectivityResult.none ? true : false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () async {
            subscription.cancel();
            Navigator.pop(context);
          },
        ),
        title: const Text("Profile Details",
            style: TextStyle(color: Colors.black, fontSize: 25)),
        centerTitle: true,
        backgroundColor: Colors.white,
        //foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              profileImageSection(),
              firstNameTile(),
              lastNameTile(),
              locationTile(),
              settingSections(description: "ACCOUNT INFORMATION"),
              emailTile(),
              phoneTile(),
              settingSections(description: "GLOBAL PREFERENCES"),
              languageTile(),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileImageSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        imageUrl.isNotEmpty
            ? Center(
                child: cache_images.CachedNetworkImage(
                  imageUrl: imageUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(60),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.fill,
                        )),
                  ),
                  placeholder: (context, url) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: Colors.grey,
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          color: Colors.grey,
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.solidQuestionCircle,
                            color: Colors.white,
                            size: 35,
                          ),
                        )),
                  ),
                ),
              )
            : Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: Colors.grey,
                ),
              ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: InkWell(
            child: Container(
              width: 100,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.amber.shade200,
              ),
              child: Center(
                child: Text(
                  "Change",
                  style: TextStyle(
                      color: Colors.amber.shade700,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            splashColor: Colors.white,
            onTap: () async {
              // show image picker
              if (networkConnection) {
                await setImage();
              } else {
                _showToast();
              }
            },
          ),
        )
      ],
    );
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.orange,
      ),
      child: const Text(
        "Please Check Your Connection",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );

    ftoast.showToast(
      child: toast,
      fadeDuration: const Duration(seconds: 3),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Future<void> setImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      image = File(pickedFile!.path);
      await uploadImage(image!);

      setState(() {});
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  Future<void> uploadImage(File image) async {
    try {
      var userId = FirebaseAuth.instance.currentUser!.uid;
      print("user is signed in : $userId");
      // specify or reference a location in firebase storage
      firebase_storage.Reference reference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('profileImage/$userId/userImage');
      // upload the image
      firebase_storage.UploadTask uploads = reference.putFile(image);
      // get a snapshot of the uploaded image
      firebase_storage.TaskSnapshot snapshot = await uploads;
      //get the url of the uploaded image using the snapshot
      String imageUrl = await snapshot.ref.getDownloadURL();
      //store the url in local storage
      SharedPreferences prefMemory = await SharedPreferences.getInstance();
      await prefMemory.setString('pofileImageUrl', imageUrl);
      //upload the url to realtime database
      await addProfileImageLink(imageUrl);
      setState(() {
        this.imageUrl = imageUrl;
      });

      print("image added to cloud , address stored in memory");
      Map<String, dynamic> userData = {
        "profileUrl": imageUrl,
      };
      await FirebaseFirestore.instance
          .collection("Participant")
          .doc(userId)
          .update(userData)
          .then((value) {
        SharedPreferences.getInstance().then((instance) {
          setState(() {
            imageUrl = instance.getString('pofileImageUrl')!;
            print("image url updated in shared pref");
          });
        });
      });
    } on FirebaseAuthException catch (e) {
      print("user not logged in");
      print(e.code);
    } catch (e) {
      print(e);
    }
  }

  Widget settingSections({required String description}) {
    return ListTile(
      title: Text(
        description,
        style: TextStyle(
          fontSize: 17,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.only(left: 15),
      tileColor: Colors.grey.shade300,
    );
  }

  Widget firstNameTile() {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("First Name",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text(
                "${getUserInfo(userInfo: "firstName")}",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () async {
                    print("clicked");
                    if (networkConnection) {
                      popUpDialog(fieldName: "firstName");
                    } else {
                      _showToast();
                    }
                  },
                  icon: const FaIcon(FontAwesomeIcons.edit)),
            ],
          ),
        ],
      ),
    );
  }

  Widget lastNameTile() {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Last Name",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text("${getUserInfo(userInfo: "lastName")}",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold)),
              IconButton(
                  onPressed: () async {
                    print("clicked");
                    if (networkConnection) {
                      popUpDialog(fieldName: "lastName");
                    } else {
                      _showToast();
                    }
                  },
                  icon: const FaIcon(FontAwesomeIcons.edit)),
            ],
          ),
        ],
      ),
    );
  }

  Widget locationTile() {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Location",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text("${getUserInfo(userInfo: "location")}",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold)),
              IconButton(
                  onPressed: () async {
                    print("clicked");
                    if (networkConnection) {
                      popUpDialog(fieldName: "location");
                    } else {
                      _showToast();
                    }
                  },
                  icon: const FaIcon(FontAwesomeIcons.edit)),
            ],
          ),
        ],
      ),
    );
  }

  Widget emailTile() {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Email",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Text("${getUserInfo(userInfo: "email")}",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold)),
                /*  IconButton(
                    onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.edit)), */
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget phoneTile() {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Phone",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text(
                "${getUserInfo(userInfo: "phoneNumber")}",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () {
                    subscription.cancel();
                    Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: const ChangePhoneNumberPage()))
                        .then((value) async {
                      try {
                        if (networkConnection) {
                          await FirebaseAuth.instance.currentUser!.reload();
                        }
                      } on FirebaseAuthException catch (e) {
                        print(e.code);
                      } catch (e) {
                        print(e);
                      }

                      setState(() {
                        print("set state");
                      });
                    });
                  },
                  icon: const FaIcon(FontAwesomeIcons.arrowCircleRight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget languageTile() {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const Text(
                "Language",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                "english",
                style: TextStyle(
                    color: Colors.grey.shade600, fontWeight: FontWeight.bold),
              ) //getUserInfo(userInfo: "language")),
            ],
          ),
          IconButton(
              onPressed: () {},
              icon: const FaIcon(FontAwesomeIcons.arrowCircleRight)),
        ],
      ),
    );
  }

  Future<void> addProfileImageLink(String imageUrl) async {
    try {
      var user = FirebaseAuth.instance.currentUser!;
      String emailAddress = user.email.toString();
      String hashedEmailAddress =
          encrypt.sha256.convert(utf8.encode(emailAddress)).toString();
      DatabaseReference ref =
          FirebaseDatabase.instance.ref('Participants/$hashedEmailAddress');
      await ref.update({"ImageLink": imageUrl}).onError((error, stackTrace) {
        print("could not upload url to realtiem databsae $error");
      });
      print("updated profile image url in realtime database");
    } on FirebaseException catch (e) {
      print("did not upload image url into realtiem database" +
          " error: ${e.code}");
    } catch (e) {
      print("did not upload image url into realtiem database" + " error: $e");
    }
  }

  void getUserData() async {
    SharedPreferences.getInstance().then((instance) async {
      try {
        // save the url in the cloud so you can get it dynamicly for each user, (save inside user uid doc)
        if (networkConnection) {
          try {
            String id = FirebaseAuth.instance.currentUser!.uid;

            await FirebaseFirestore.instance
                .collection("Participant")
                .doc(id)
                .get()
                .then((response) async {
              var data = response.data();
              if (data != null) {
                if (data['profileUrl'] != null) {
                  // if(data['name']!=firstName){}
                  await instance.setString(
                      'pofileImageUrl', data['profileUrl']);
                  imageUrl = data['profileUrl'];
                  print('image url from cloud');
                } else {
                  print("this account does not have profile image");
                }
              }
              setState(() {});
            });
          } on FirebaseAuthException catch (e) {
            if (instance.getString('pofileImageUrl') != null) {
              imageUrl = instance.getString('pofileImageUrl')!;
              print("exception, profile image from shared pref");
            }
            print("error catch ${e.code}");
          } catch (e) {
            print("error catch $e");
          }
        } else if (instance.getString('pofileImageUrl') != null) {
          print("image url from shared pref");
          imageUrl = instance.getString('pofileImageUrl')!;
        }
      } catch (e) {
        print("error catched $e");
      }
      // getting first name

      try {
        if (networkConnection) {
          try {
            String id = FirebaseAuth.instance.currentUser!.uid;
            await FirebaseFirestore.instance
                .collection("Participant")
                .doc(id)
                .get()
                .then((response) {
              var data = response.data();
              if (data != null) {
                if (data['firstName'] != null) {
                  print("passed the checker first name");
                  instance.setString('firstName', data['firstName']);
                  firstName = data['firstName'];
                  print("first name from cloud");
                } else {
                  firstName = "Enter Frist Name";
                  instance.setString('firstName', "Enter First Name");
                  print("first name is not set");
                }
              }
              setState(() {});
            });
          } on FirebaseAuthException catch (e) {
            if (instance.getString('firstName') != null) {
              firstName = instance.getString('firstName')!;
              print("exeption , first name from shared pref");
            }
            print(e);
          } catch (e) {
            print(e);
          }
        } else if (instance.getString('firstName') != null) {
          print("first name from shared pref");
          firstName = instance.getString('firstName')!;
        }
      } catch (e) {
        print(e);
      }
      // getting last name
      try {
        if (networkConnection) {
          try {
            String id = FirebaseAuth.instance.currentUser!.uid;
            FirebaseFirestore.instance
                .collection("Participant")
                .doc(id)
                .get()
                .then((response) {
              var data = response.data();
              if (data != null) {
                if (data['lastName'] != null) {
                  print('passed the checker');
                  instance.setString('lastName', data['lastName']);
                  lastName = data['lastName'];
                  print("last name from cloud");
                } else {
                  lastName = "Enter Last Name";
                  instance.setString('lastName', "Enter Last Name");
                  print("last name is not set");
                }
              }
              setState(() {});
            });
          } on FirebaseAuthException catch (e) {
            if (instance.getString('lastName') != null) {
              lastName = instance.getString('lastName')!;
              print("exeption , last name from shared pref");
            }
            print(e.code);
          } catch (e) {
            print(e);
          }
        } else if (instance.getString('lastName') != null) {
          print("last name from shard pref");
          lastName = instance.getString('lastName')!;
        }
      } catch (e) {
        print(e);
      }

      // getting location
      try {
        if (networkConnection) {
          try {
            String id = FirebaseAuth.instance.currentUser!.uid;
            FirebaseFirestore.instance
                .collection("Participant")
                .doc(id)
                .get()
                .then((response) {
              var data = response.data();
              if (data != null) {
                if (data['location'] != null) {
                  print('passed the checker');
                  instance.setString('location', data['location']);
                  location = data['location'];
                  print("location from cloud");
                } else {
                  location = "Enter a Location";
                  instance.setString('location', "Enter a Location");
                  print("location not set");
                }
              }
              setState(() {});
            });
          } on FirebaseAuthException catch (e) {
            if (instance.getString('location') != null) {
              location = instance.getString('location')!;
              print("exeption , location from shared pref");
            }
            print(e.code);
          } catch (e) {
            print(e);
          }
        } else if (instance.getString('location') != null) {
          location = instance.getString('location')!;
          print("location from shared pref");
        }
      } on FirebaseAuthException catch (e) {
        print(e);
      }

      setState(() {});
    });
  }

  void popUpDialog({required String fieldName}) {
    TextEditingController textField = TextEditingController();
    showDialog(
        context: context,
        builder: (context) => BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10,
                sigmaY: 10,
              ),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Colors.white,
                      content: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: TextField(
                                  controller: textField,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        width: 4,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        width: 4,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        width: 4,
                                        color: Color.fromARGB(255, 255, 160, 0),
                                      ),
                                    ),
                                    // hintText: hintText,
                                    label: Text("Enter $fieldName"),
                                    hintStyle: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: const BorderSide(
                                        width: 4,
                                        color: Color.fromARGB(255, 255, 160, 0),
                                      ),
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 5,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (textField.text.isNotEmpty) {
                                        try {
                                          String id = FirebaseAuth
                                              .instance.currentUser!.uid;
                                          Map<String, dynamic> userData = {
                                            fieldName: textField.text,
                                          };
                                          await FirebaseFirestore.instance
                                              .collection("Participant")
                                              .doc(id)
                                              .update(userData);
                                          print("user Data is added");

                                          switch (fieldName) {
                                            case "firstName":
                                              firstName = textField.text;
                                              SharedPreferences pref =
                                                  await SharedPreferences
                                                      .getInstance();
                                              pref.setString(
                                                  'firstName', textField.text);
                                              await updateNameRealDatabase(
                                                  textField.text);

                                              break;
                                            case "lastName":
                                              lastName = textField.text;
                                              SharedPreferences pref =
                                                  await SharedPreferences
                                                      .getInstance();
                                              pref.setString(
                                                  'lastName', textField.text);

                                              break;
                                            case "location":
                                              location = textField.text;
                                              SharedPreferences pref =
                                                  await SharedPreferences
                                                      .getInstance();
                                              pref.setString(
                                                  'location', textField.text);
                                              break;
                                            default:
                                          }
                                          setState(() {});

                                          textField.clear();
                                          Navigator.pop(context);
                                        } catch (e) {
                                          print(e);
                                        }
                                      }
                                    },
                                    child: const Text(
                                      "Update",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      //  elevation: 5,
                                      primary: const Color.fromARGB(
                                          255, 255, 160, 0),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 5,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      textField.clear();
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Cancle",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      //  elevation: 5,
                                      primary: const Color.fromARGB(
                                          255, 255, 160, 0),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }

  Future<void> updateNameRealDatabase(String name) async {
    try {
      var user = FirebaseAuth.instance.currentUser!;
      String emailAddress = user.email.toString();
      String hashedEmailAddress =
          encrypt.sha256.convert(utf8.encode(emailAddress)).toString();
      DatabaseReference ref =
          FirebaseDatabase.instance.ref('Participants/$hashedEmailAddress');
      await ref.update({"Name": name}).onError((error, stackTrace) {
        print("could not update user name to realtiem databsae $error");
      });
      print("updated user name  in realtime database");
    } on FirebaseException catch (e) {
      print("did not update user name into realtiem database" +
          " error: ${e.code}");
    } catch (e) {
      print("did not update user name into realtiem database" + " error: $e");
    }
  }

  String? getUserInfo({required String userInfo}) {
    switch (userInfo) {
      case "firstName":
        return firstName;

      case "lastName":
        return lastName;

      case "location":
        return location;
      case "email":
        try {
          return FirebaseAuth.instance.currentUser!.email!;
        } on FirebaseAuthException catch (e) {
          print(e.code);
          return "failed";
        } catch (e) {
          print(e);
          return "failed";
        }

      case "phoneNumber":
        try {
          print("getting phone number");
          if (networkConnection) {
            FirebaseAuth.instance.currentUser!.reload();
          }

          if (FirebaseAuth.instance.currentUser!.phoneNumber!.isNotEmpty) {
            return FirebaseAuth.instance.currentUser!.phoneNumber;
          }
          return "Not Set";
        } on FirebaseAuthException catch (e) {
          print(e.code);
          return "failed";
        } catch (e) {
          print(e);
          return "Not Set";
        }

      default:
        return "default";
    }
  }
}
