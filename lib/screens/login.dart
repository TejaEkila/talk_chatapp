// ignore_for_file: avoid_print, prefer_const_constructors, use_key_in_widget_constructors, unnecessary_string_interpolations
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:talk/components/mybutton.dart';
import 'package:talk/components/mytextfield.dart';
import 'package:talk/screens/otp.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final mobileController = TextEditingController();

  @override
  void initState() {
    
    super.initState();
  }

  Country selectedCountry = Country(
    phoneCode: "1",
    countryCode: "US",
    e164Sc: 0,
    geographic: true,
    level: 0,
    name: "United States",
    example: "United States",
    displayName: "United States",
    displayNameNoCountryCode: "US",
    e164Key: "",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Gap(130),
            const Icon(
              Icons.quickreply,
              size: 130,
              color: Colors.blueAccent,
            ),
            const Text(
              "T A l K",
              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),
            ),
            const Gap(40),
            mytextfield(
              Controller: mobileController,
              hinttext: "Mobile no",
              obscureText: false,
              keyboardtype: TextInputType.number,
              // country code
              prefix: Container(
                padding: EdgeInsets.all(15),
                child: InkWell(
                  onTap: () {
                    showCountryPicker(
                      
                      countryListTheme: CountryListThemeData(
                        textStyle: TextStyle(color: Colors.white),
                        backgroundColor: Color.fromARGB(255, 48, 43, 43),
                        bottomSheetHeight: 500,
                      ),
                      context: context,
                      onSelect: ((value) {
                        setState(() {
                          selectedCountry = value;
                        });
                      }),
                    );
                  },
                  child: Text(
                    "${selectedCountry.flagEmoji}",
                    style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const Gap(20),
            Mybutton(
              ontap: () {
                print("working");
                // Format the phone number with the country code
                String phoneNumber = "+${selectedCountry.phoneCode}${mobileController.text}";

                // Ensure that the phone number is in the correct format
                if (phoneNumber.isNotEmpty) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OptPage(
                        verificationID: phoneNumber,
                      ),
                    ),
                  );
                } else {
                  print("Invalid phone number format");
                }
              },
              buttontext: "send otp",
            ),
            const Gap(20),
            const Text(
              "or",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const Gap(20),
            GestureDetector(
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => const GmailLink()));
              },
              child: SizedBox(
                height: 50,
                width: 50,
                child: GestureDetector(
                  onTap: () {
                    print("working");
                  },
                  child: Image.asset(
                    "assets/google.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Gap(200)
          ],
        ),
      ),
    );
  }
}
