// ignore_for_file: avoid_print, deprecated_member_use, use_key_in_widget_constructors, use_build_context_synchronously, file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart'; // Unused import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk/screens/Editprofile.dart';
import 'package:talk/screens/login.dart';
import 'package:url_launcher/url_launcher.dart'; // Unused import

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _alterDiaglog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 48, 43, 43),
            title: Center(
                child: Icon(
              Icons.warning_amber_rounded,
              size: 40,
              color: Colors.blueAccent,
            )),
            content: Text("Are you sure ??",style: TextStyle(color: Colors.white, fontSize: 17),),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Add border radius if needed
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "cancle",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  await pref.setBool("statuslog", false);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                },
                child: Text("logout", style: TextStyle(color: Colors.white, fontSize: 15)),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "profile",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              print("working");
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      decoration: const BoxDecoration(color: Color.fromARGB(255, 48, 43, 43), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                      height: 140,
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 5,
                            width: 55,
                            decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)),
                          ),
                          const Gap(20),
                          const SizedBox(
                            height: 50,
                            width: 400,
                            child: Center(
                                child: Text(
                              "Share",
                              style: TextStyle(fontSize: 17, color: Colors.white),
                            )),
                          ),
                          const SizedBox(
                            height: 50,
                            width: 400,
                            child: Center(
                                child: Text(
                              "Deactive",
                              style: TextStyle(fontSize: 17, color: Colors.white),
                            )),
                          )
                        ],
                      )),
                    );
                  });
            },
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection("users").doc(user?.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("error:${snapshot.error}");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            var data = snapshot.data?.data();

            if (data == null || data.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 250),
                  child: Text(
                    "No data available",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }
            return Column(
              children: [
                //profil photo
                Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            height: 200,
                            width: 200,
                            decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                            child: Image.network(
                              data["imageurl"],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 210),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${data['Firstname']}",
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w400, color: Colors.white),
                              ),
                              const Gap(10),
                              Text("${data['lastname']}", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w400, color: Colors.white)),
                            ],
                          ),
                          Text("${data["profession"]}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Color.fromARGB(255, 116, 115, 115))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              _alterDiaglog();
                            },
                            child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(color: const Color.fromARGB(255, 48, 43, 43), borderRadius: BorderRadius.circular(10)),
                              child: const Center(
                                  child: Text(
                                "logout",
                                style: TextStyle(fontSize: 17, color: Colors.white),
                              )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfile()));
                            },
                            child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(color: const Color.fromARGB(255, 48, 43, 43), borderRadius: BorderRadius.circular(10)),
                              child: const Center(child: Text("edit", style: TextStyle(fontSize: 17, color: Colors.white))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 360),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  height: 80,
                                  width: 410,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 48, 43, 43),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Gap(20),
                                    Text("${data['Bio']}", style: const TextStyle(fontSize: 17, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
