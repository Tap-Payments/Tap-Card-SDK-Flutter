import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class TapCardViewWidget extends StatefulWidget {
  final Function()? onReady, onFocus;
  final Function(String?)? onSuccess,
      onError,
      onValidInput,
      onBindIdentification,
      onHeightChange;
  final bool generateToken;
  final Map<String, dynamic> sdkConfiguration;

  const TapCardViewWidget({
    super.key,
    this.onReady,
    this.onSuccess,
    this.onError,
    this.onValidInput,
    this.onBindIdentification,
    this.onHeightChange,
    this.onFocus,
    required this.generateToken,
    required this.sdkConfiguration,
  });

  @override
  State<TapCardViewWidget> createState() => _TapCardViewWidgetState();
}

class _TapCardViewWidgetState extends State<TapCardViewWidget> {
  late Function()? onReadyFunction;
  late Function()? onFocusFunction;
  late Function(String?)? onSuccessFunction;
  late Function(String?)? onErrorFunction;
  late Function(String?)? onValidInputFunction;
  late Function(String?)? onBindIdentificationFunction;
  late Function(String?)? onHeightChangeFunction;

  static const MethodChannel _channel = MethodChannel('card_flutter');

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 0), () {
      startTapCardSDK();
    });
    super.initState();
  }

  Future<dynamic> startTapCardSDK() async {
    try {
      dynamic result = await _channel.invokeMethod(
        'start',
        {"configuration": widget.sdkConfiguration},
      );
      handleCallbacks(result);
      _startTapCardSDK2();
      // return responseData;
    } catch (ex) {
      debugPrint("Start SDK Exception >>>>>> $ex");
    }
  }

  Future<dynamic> _startTapCardSDK2() async {
    try {
      dynamic result = await _channel.invokeMethod(
        'start2',
        {
          "configuration": widget.sdkConfiguration,
        },
      );

      handleCallbacks(result);
      _startTapCardSDK2();
      //  return responseData;
    } catch (ex) {
      debugPrint("Exception >>>>>> $ex");
    }
  }

  Future<dynamic> generateTapToken() async {
    try {
      dynamic result = await _channel.invokeMethod(
        'generateToken',
        {
          "configuration": widget.sdkConfiguration,
        },
      );

      handleCallbacks(result);
      _startTapCardSDK2();
    } catch (ex) {
      debugPrint("Exception >>>>>> $ex");
    }
  }

  handleCallbacks(dynamic result) {
    if (result.containsKey("onHeightChange")) {
      /// onHeightChange Callbacks Triggered From SDK
    }

    if (result.containsKey("onBindIdentification")) {
      /// onBindIdentification Callbacks Triggered From SDK
      var resultOfBindIdentification =
          jsonDecode(result["onBindIdentification"]);
      onBindIdentificationFunction = widget.onBindIdentification;
      onBindIdentificationFunction!(resultOfBindIdentification.toString());
    }

    if (result.containsKey("onError")) {
      /// onError Callbacks Triggered From SDK
      var resultOfError = jsonDecode(result["onError"]);
      onErrorFunction = widget.onError;
      onErrorFunction!(resultOfError.toString());
    }

    if (result.containsKey("onFocus")) {
      /// onFocus Callbacks Triggered From SDK
      onFocusFunction = widget.onFocus;
      onFocusFunction!();
    }

    if (result.containsKey("onReady")) {
      onReadyFunction = widget.onReady;
      onReadyFunction!();
    }

    if (result.containsKey("onSuccess")) {
      /// onSuccess Callbacks Triggered From SDK
      var resultOfSuccess = jsonDecode(result["onSuccess"]);
      onSuccessFunction = widget.onSuccess;
      onSuccessFunction!(resultOfSuccess.toString());
    }

    if (result.containsKey("onValidInput")) {
      /// onValidInput Callbacks Triggered From SDK
      var resultOfValidInput = jsonDecode(result["onValidInput"]);
      onValidInputFunction = widget.onValidInput;
      onValidInputFunction!(resultOfValidInput.toString());
    }
  }

  double height = 120;

  @override
  Widget build(BuildContext context) {
    if (widget.generateToken) {
      generateTapToken();
    }
    return SizedBox(
      height: height,
      child: AndroidView(
        viewType: "plugin/tap_card_sdk",
        creationParams: widget.sdkConfiguration,
        creationParamsCodec: const StandardMessageCodec(),
        layoutDirection: TextDirection.ltr,
      ),
    );
  }
}
