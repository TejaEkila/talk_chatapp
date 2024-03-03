// ignore_for_file: await_only_futures, must_be_immutable, use_build_context_synchronously, avoid_print, non_constant_identifier_names, unnecessary_brace_in_string_interps, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk/components/mybutton.dart';
import 'package:talk/components/mytextfield.dart';
import 'package:talk/screens/home.dart';
import 'package:talk/screens/welcome.dart';

class OptPage extends StatefulWidget {
  String verificationID;
  OptPage({Key? key, required this.verificationID});

  @override
  State<OptPage> createState() => _OptPageState();
}

class _OptPageState extends State<OptPage> {
  final otpController = TextEditingController();
  String? _verificationCode;
  bool isLoading = false; // Add loading state

  @override
  void initState() {
    
    super.initState();
    verifyPhone_number();
  }

  verifyPhone_number() async {
    print(widget.verificationID);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.verificationID,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {
          final User? user = FirebaseAuth.instance.currentUser;
          final uid = user!.uid;
          print("########${uid}");
          var currentUser = await FirebaseFirestore.instance.collection("users").doc(uid).get();
          if (currentUser.exists) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return const HomePage();
            }));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return WelcomePage(phoneID: widget.verificationID);
            }));
          }
        });
      },
      verificationFailed: (FirebaseAuthException s) async {
        print(s);
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog();
            });
      },
      codeSent: (String? verificationID, int? resendToken) {
        setState(() {
          print("><>>>>>>>>>>${verificationID}");
          _verificationCode = verificationID;
        });
      },
      codeAutoRetrievalTimeout: ((String verificationID) {
        setState(() {
          _verificationCode = verificationID;
        });
      }),
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> submitOtp() async {
    final credential = PhoneAuthProvider.credential(verificationId: _verificationCode!, smsCode: otpController.text);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      final curentuser = FirebaseAuth.instance.currentUser;
      final snapshot = await FirebaseFirestore.instance.collection("users").doc(curentuser!.uid).get();
      if (snapshot.exists) {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return const HomePage();
          },
        ));
      } else {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return WelcomePage(
              phoneID: widget.verificationID,
            );
          },
        ));
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 250),
          child: Column(children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Verification Code",
                  style: TextStyle(fontSize: 40, color: Colors.blueAccent),
                ),
                Text(
                  "Enter the otp sent to the mobile ",
                  style: TextStyle(fontSize: 22, color: Colors.blueAccent),
                ),
                Text(
                  "number **********",
                  style: TextStyle(fontSize: 22, color: Colors.blueAccent),
                ),
              ],
            ),
            const Gap(40),
            mytextfield(
              Controller: otpController,
              hinttext: "otp",
              obscureText: false,
              keyboardtype: TextInputType.phone,
              prefix: null,
            ),
            const Gap(15),
            Mybutton(
              ontap: () async {
                print("working");
                setState(() {
                  isLoading = false;
                });
                SharedPreferences pref = await SharedPreferences.getInstance();
                await pref.setBool('statuslog', true);
                // bool? statuslog = pref.setBool("statuslog", true) as bool?;
                submitOtp();
              },
              buttontext: isLoading ? "Loading..." : "Submit",
            ),
            const Gap(10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Gap(40),
                const Text("If you didn't reeive a code!",style: TextStyle(color: Colors.white,fontSize: 18),), TextButton(onPressed: () {}, child: const Text("Resend",style: TextStyle(fontSize: 20,color: Colors.blueAccent),))],
            )
          ]),
        ),
      ),
    );
  }
}
