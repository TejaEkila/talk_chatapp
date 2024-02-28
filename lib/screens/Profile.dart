import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart'; // Unused import
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "profile",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
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
                      decoration: BoxDecoration(color: Color.fromARGB(255, 196, 194, 196), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                      height: 140,
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 5,
                            width: 55,
                            
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          ),
                          Gap(20),
                          Container(
                            height: 50,
                            width: 400,
                            child: Center(child: Text("Share",style: TextStyle(fontSize: 17,color: Colors.black),)),
                          ),
                          
                          Container(
                            height: 50,
                            width: 400,
                            child: Center(child: Text("Deactive",style: TextStyle(fontSize: 17,color: Colors.black),)),
                          )
                        ],
                      )),
                    );
                  });
            },
            icon: Icon(Icons.menu,color: Colors.white,),
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
                          TextButton(
                            onPressed: () {
                              setState(() {});
                              print("working");
                              launchURL(data['linkedin']);
                            },
                            child: Text(data["linkedin"], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.blue)),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 330),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              SharedPreferences pref = await SharedPreferences.getInstance();
                              await pref.setBool("statuslog", false);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                            },
                            child: Container(
                              height: 50,
                              width: 200,
                              decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(
                                "logout",
                                style: TextStyle(fontSize: 17, color: Colors.black),
                              )),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 200,
                            decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("edit", style: TextStyle(fontSize: 17, color: Colors.black))),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 390),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  height: 80,
                                  width: 410,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(133, 127, 247, 1),
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
                                    Gap(20),
                                    Text("${data['Bio']}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white)),
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
