import 'dart:convert';

import 'package:app/api.dart';
import 'package:app/dto/statistics.dart';
import 'package:app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class Statistics extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(
      child: Consumer<UserModel>(builder: (context, user, child) {
        if (!user.hasValidId()) {
          return const Text("Please register your device fist.");
        }

        return FutureBuilder<Response>(
            future: Api.retrieveStatistics(user.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data?.statusCode == 200) {
                  var statistics = StatisticsDto.fromJson(
                      jsonDecode("${snapshot.data?.body}"));

                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Today: ${statistics.today}',
                        ),
                        Text(
                          'Week: ${statistics.week}',
                        ),
                        Text(
                          'Month: ${statistics.month}',
                        ),
                        Text(
                          'Total ${statistics.total}',
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Refresh',
                              onPressed: () {
                                setState(() {});
                              },
                            ))
                      ]);
                } else {
                  return Column(children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                          'Data retrieval failed with status code ${snapshot.data?.statusCode}.'),
                    )
                  ]);
                }
              } else if (snapshot.hasError) {
                return Column(children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child:
                        Text('Data retrieval failed. Error: ${snapshot.error}'),
                  )
                ]);
              } else {
                return Column(children: const [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Retrieving user data ...'),
                  )
                ]);
              }
            });
      }),
    ));
  }
}
