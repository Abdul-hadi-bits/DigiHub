import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WellcomePage extends StatefulWidget {
  const WellcomePage({Key? key}) : super(key: key);

  @override
  State<WellcomePage> createState() => _WellcomePageState();
}

class _WellcomePageState extends State<WellcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.15,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                "DIGI",
                textAlign: TextAlign.center,
                style: TextStyle(
                    letterSpacing: 8,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Text(
                "HUB",
                textAlign: TextAlign.center,
                style: TextStyle(
                    letterSpacing: 8,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
            ],
          ),
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.15,
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fill,
                              image:
                                  AssetImage('assets/images/welcomePage.png'))),
                      // color: Colors.deepOrange,
                    ),
                  )
                ],
              )),
          Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        bottom:
                            MediaQuery.of(context).viewInsets.bottom * 0.85),
                    child: sendOtpButton(),
                  ),
                  Center(
                    child: SizedBox(
                      // height: 30,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Having Account!",
                              style: TextStyle(
                                  // letterSpacing: 8,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            TextButton(
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                    // letterSpacing: 8,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange),
                              ),
                              style: ButtonStyle(
                                overlayColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      const Color.fromARGB(50, 255, 170, 0),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  "/SignInPhoneNumberPage",
                                  /* PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: const SignInPhoneNumberPage()) */
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget sendOtpButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          // Future.delayed(Duration(milliseconds: 500));
          Navigator.pushNamed(
            context,
            "/RegisterationPage",
            /*  PageTransition(
                type: PageTransitionType.rightToLeft,
                // duration: Duration(milliseconds: 500),
                child: const RegisterationPage()), */
          );
        },
        child: const Text("Create Account"),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 255, 160, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}
