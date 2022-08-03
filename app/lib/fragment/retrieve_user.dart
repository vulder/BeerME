import 'package:app/model/user.dart';
import 'package:app/service/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RetreiveUserFragment extends StatefulWidget {
  final Widget failedChild;
  final Widget successChild;

  RetreiveUserFragment({required this.failedChild, required this.successChild});

  @override
  State<StatefulWidget> createState() => _RetreiveUserFragmentState();
}

class _RetreiveUserFragmentState extends State<RetreiveUserFragment> {
  @override
  Widget build(BuildContext context) {
    var model = context.read<UserModel>();

    return FutureBuilder<WrappedResponse>(
        future: UserService.retrieveUserAndUpdateState(model),
        builder: (BuildContext context,
            AsyncSnapshot<WrappedResponse> retrieveUserSnapshot) {
          if (retrieveUserSnapshot.hasData) {
            if (retrieveUserSnapshot.data?.response.statusCode == 200) {
              return widget.successChild;
            } else if (retrieveUserSnapshot.data?.response.statusCode == 404) {
              return widget.failedChild;
            } else {
              return Column(children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                      'User data retrieval API request failed due to unknown reason. Return code is ${retrieveUserSnapshot.data?.response.statusCode} and body content ${retrieveUserSnapshot.data?.response.body}'),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                        child: Row(
                          children: const [
                            Icon(Icons.refresh),
                            Text('Refresh')
                          ],
                        ),
                        onPressed: () => setState(() {})))
              ]);
            }
          } else if (retrieveUserSnapshot.hasError) {
            return Column(children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                    'User data retrieval failed. Error: ${retrieveUserSnapshot.error}'),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                      child: Row(
                        children: const [Icon(Icons.refresh), Text('Refresh')],
                      ),
                      onPressed: () => setState(() {})))
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
  }
}
