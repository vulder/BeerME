import 'package:app/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:provider/provider.dart';

class ReadTagIdFragment extends StatefulWidget {
  final Function(NFCTag?) onSuccess;

  const ReadTagIdFragment({Key? key, required this.onSuccess})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReadTagIdFragmentState();
}

class _ReadTagIdFragmentState extends State<ReadTagIdFragment> {
  bool _hasError = false;
  bool _hasNfc = false;
  bool _isPolling = false;

  Future<NFCTag?> read() async {
    setState(() {
      _hasError = false;
    });
    try {
      if (_hasNfc) {
        setState(() {
          _isPolling = true;
          _hasNfc = true;
        });

        return await FlutterNfcKit.poll();
      }
    } on PlatformException catch (e) {
      setState(() {
        _hasError = false;
      });
    } finally {
      setState(() {
        _isPolling = false;
      });
    }

    return null;
  }

  checkNfc() {
    setState(() {
      _hasNfc = false;
    });
    return FlutterNfcKit.nfcAvailability.then((NFCAvailability availability) {
      if (availability == NFCAvailability.available) {
        setState(() {
          _hasNfc = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkNfc();
  }

  @override
  Widget build(BuildContext context) {
    if (_isPolling) {
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
    }

    if (_hasError) {
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
            child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => setState(() => _hasError = false)))
      ]);
    }

    if (!_hasNfc) {
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
            child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => setState(() => checkNfc())))
      ]);
    }

    return ButtonTheme(
      minWidth: 200.0,
      height: 100.0,
      child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            onPrimary: Theme.of(context).colorScheme.onPrimary,
            primary: Theme.of(context).colorScheme.primary,
          ),
          icon: const Icon(Icons.sensors),
          label: const Text('Register Token'),
          onPressed: () => read().then((value) => widget.onSuccess(value))),
    );
  }
}
