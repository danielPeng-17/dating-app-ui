import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:duos_ui/constants/api_constants.dart';
import 'package:provider/provider.dart';
import 'package:duos_ui/providers/providers.dart';

class EditProfileLanguages extends StatefulWidget {
  const EditProfileLanguages({Key? key}) : super(key: key);

  @override
  State<EditProfileLanguages> createState() => _EditProfileLanguagesState();
}

class _EditProfileLanguagesState extends State<EditProfileLanguages> {
  final GlobalKey<FormState> _languagesForm = GlobalKey<FormState>();
  late AuthProvider authProvider;
  late ProfileProvider profileProvider;
  String languagesText = '';
  TextEditingController languagesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
    profileProvider = context.read<ProfileProvider>();
    languagesController.text = profileProvider.languages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.0),
        centerTitle: true,
        leading: InkWell(
          onTap: () async {
            languagesText = languagesController.text;
            updateBio();
            if (!mounted) return;
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black54,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        child: Form(
          key: _languagesForm,
          child: ListView(
            //Listview is a fix in order to prevent overflow, (scrollable) works well needs formatting
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: ' Edit Languages'),
                    ],
                  ),
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: SizedBox(
                  width: 50,
                  height: 10,
                ),
              ),
              TextFormField(
                controller: languagesController,
                maxLines: 10,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  hintText: 'Tell us about yourself',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future updateBio() async {
    String uid = authProvider.sub;
    final apiBio = "${ApiConstants.apiBaseUrl}/user/$uid";
    String token = await FirebaseAuth.instance.currentUser!.getIdToken();
    final headers = ApiConstants.apiHeader(token ?? '');

    final data = {
      "info": {"languages": languagesText.trim()}
    };
    final encodedJson = jsonEncode(data);

    http.patch(Uri.parse(apiBio), headers: headers, body: encodedJson);
  }
}

