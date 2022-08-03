import 'package:app/model/user.dart';
import 'package:flutter/material.dart';
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
    var status = await FlutterNfcKit.nfcAvailability;
    if (status == NFCAvailability.available) {
      final NFCTag tag =  await FlutterNfcKit.poll();
      model.tokenId = tag.id;
    }

    return status;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NFCAvailability>(
      future: retrieveId(context.read<UserModel>()),
      builder: (BuildContext context, AsyncSnapshot<NFCAvailability> snapshot) {
        if (snapshot.hasData && snapshot.data == NFCAvailability.available) {
          return widget.child;
        } else if (snapshot.hasData || snapshot.hasError) {
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
                      children: const [Icon(Icons.refresh), Text('Refresh')],
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
