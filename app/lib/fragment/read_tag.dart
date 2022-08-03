import 'package:app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:provider/provider.dart';

class ReadTagIdFragment extends StatefulWidget {
  final Widget child;

  const ReadTagIdFragment({Key? key, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReadTagIdFragmentState();
}

class _ReadTagIdFragmentState extends State<ReadTagIdFragment> {
  Future<NFCAvailability> retrieveId(UserModel model) async {
    try {
      var status = await FlutterNfcKit.nfcAvailability;
      if (status == NFCAvailability.available) {
        final NFCTag tag = await FlutterNfcKit.poll();
        model.tokenId = tag.id;
      }

      return status;
    } on PlatformException catch (e) {
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NFCAvailability>(
      future: retrieveId(context.read<UserModel>()),
      builder: (BuildContext context, AsyncSnapshot<NFCAvailability> snapshot) {
        if (snapshot.hasData && snapshot.data == NFCAvailability.available) {
          return widget.child;
        } else if (snapshot.hasData) {
          return Column(children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('NFC reader not available.'),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                    child: Row(
                      children: const [Icon(Icons.refresh), Text('Retry')],
                    ),
                    onPressed: () => setState(() {})))
          ]);
        } else if (snapshot.hasError) {
          return Column(children: [
            const Icon(
              Icons.warning_outlined,
              color: Colors.yellow,
              size: 60,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('Failed to read token.'),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                    child: Row(
                      children: const [Icon(Icons.refresh), Text('Retry')],
                    ),
                    onPressed: () => setState(() {})))
          ]);
        }

        return Column(children: const [
          Icon(
            Icons.sensors,
            size: 80,
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text("Hold token near phone ..."),
          )
        ]);
      },
    );
  }
}
