import 'dart:convert';

import 'package:app/api.dart';
import 'package:app/dto/statistics.dart';
import 'package:app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class Element {
  final String title;
  final int number;
  final Color color;
  final Color accent;

  Element(
      {required this.title,
      required this.number,
      required this.color,
      required this.accent});
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(builder: (context, user, child) {
      if (!user.hasId()) {
        return const Text("Please register your device fist.");
      }

      return FutureBuilder<Response>(
          future: Api.retrieveStatistics(user.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data?.statusCode == 200) {
                var statistics = StatisticsDto.fromJson(
                    jsonDecode("${snapshot.data?.body}"));

                var elements = [
                  Element(
                    title: "Today",
                    number: statistics.today,
                    color: Color(0xFFffe169),
                    accent: Color(0xFFdbb42c),
                  ),
                  Element(
                    title: "Week",
                    number: statistics.today,
                    color: Color(0xFFedc531),
                    accent: Color(0xFFdbb42c),
                  ),
                  Element(
                    title: "Month",
                    number: statistics.today,
                    color: Color(0xFFc9a227),
                    accent: Color(0xFFb69121),
                  ),
                  Element(
                    title: "Total",
                    number: statistics.today,
                    color: Color(0xFFa47e1b),
                    accent: Color(0xFF926c15),
                  )
                ];

                return Column(children: <Widget>[
                  GridView.builder(
                    itemCount: elements.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 15,
                            childAspectRatio: 1,
                            crossAxisCount: 2,
                            mainAxisSpacing: 20),
                    itemBuilder: (context, index) {
                      return ElementWidget(element: elements[index]);
                    },
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: ElementWidget(
                        element: Element(
                            title: "Unpaid",
                            number: statistics.unpaid,
                            color: Color(0xFF805b10),
                            accent: Color(0xFF76520e)),
                      )),
                  Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh',
                          onPressed: () => setState(() {})))
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
            }

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
          });
    });
  }
}

class ElementWidget extends StatelessWidget {
  final Element element;

  const ElementWidget({required this.element});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: element.color,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              element.title,
              maxLines: 2,
              softWrap: true,
              style: const TextStyle(
                fontSize: 40,
                color: Colors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 40,
                  width: 7,
                  decoration: BoxDecoration(
                      color: element.accent,
                      borderRadius: BorderRadius.circular(15)),
                ),
                Text(
                  element.number.toString(),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
