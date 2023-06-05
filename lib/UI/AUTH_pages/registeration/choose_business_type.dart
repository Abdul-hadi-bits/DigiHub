import 'package:flutter/material.dart';
import 'package:my_project/UI/AUTH_pages/registeration/why_use_digihub.dart';
import 'package:page_transition/page_transition.dart';

class BusinessSelection extends StatefulWidget {
  const BusinessSelection({Key? key}) : super(key: key);

  @override
  _BusinessSelectionState createState() => _BusinessSelectionState();
}

class _BusinessSelectionState extends State<BusinessSelection> {
  bool isTileEnabled = false;
  int selectedValue = 0;
  List<String> businessTypes = [
    "Not Specified",
    "Retail",
    "E-Commerce",
    "Real Estate",
    "Manufacturing",
    "Software Solutions",
    "Service",
  ];

  get children => null;
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
            "About Your Business",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
          ),

          //titleSpacing: MediaQuery.of(context).size.width ,
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8825,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: Column(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "Your Field Of",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  "Work?",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      // height: MediaQuery.of(context).size.height * 0.60,
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          addAutomaticKeepAlives: true,
                          controller: ScrollController(keepScrollOffset: true),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: businessTypes.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              // width: MediaQuery.of(context).size.width * 0.9,
                              child: Column(
                                children: [
                                  const Divider(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: ListTile(
                                      style: ListTileStyle.drawer,
                                      title: Center(
                                          child: Text(
                                        businessTypes[index],
                                        style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      )),
                                      selectedColor: Colors.black,
                                      selectedTileColor: const Color.fromARGB(
                                          170, 255, 160, 0),
                                      selected:
                                          selectedValue == index ? true : false,
                                      shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            color: Colors.grey,
                                            width: 3,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      onTap: () {
                                        setState(() {
                                          selectedValue = index;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.11,
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [button()],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }

  Widget button() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: const WhyUseDigihub()));
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
}
