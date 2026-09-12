import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallScreen extends StatelessWidget {
  final String callID;
  final String currentUserId;
  final String currentUserName;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.callID,
    required this.currentUserId,
    required this.currentUserName,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: 624326593,
        appSign:
            "061cafbc1e8e09e8afb72e669b57cad3f231b8d0ad97ec073e8fa8858b2389f9",
        userID: currentUserId,
        userName: currentUserName,
        callID: callID,
        config: isVideo
            ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
            : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall(),
      ),
    );
  }
}
