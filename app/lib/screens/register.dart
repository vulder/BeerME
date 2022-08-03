import 'dart:convert';

import 'package:app/api.dart';
import 'package:app/dto/user.dart';
import 'package:app/fragment/read_tag.dart';
import 'package:app/fragment/retrieve_user.dart';
import 'package:app/model/user.dart';
import 'package:app/screens/statistics.dart';
import 'package:app/service/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:app/fragment/register_form.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ReadTagIdFragment(child: RegistrationFragment()),
            //     child: RetreiveUserFragment(
            //   successChild: StatisticsFragment(),
            //   failedChild: RegistrationFragment(),
            // ))
          ],
        ),
      ),
    );
  }
}
