import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class CallScreen extends StatefulWidget {
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
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // 1. طلب صلاحيات المايك والكاميرا
    await [Permission.microphone, Permission.camera].request();

    // 2. إنشاء المحرك الخاص بأجورا
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: '75afc60061774ef1888d34ca1359484b', // الـ ID بتاعك
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // 3. الاستماع لأحداث المكالمة
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("أنت دخلت المكالمة");
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("الطرف التاني دخل: $remoteUid");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("الطرف التاني خرج");
          setState(() {
            _remoteUid = null;
          });
          Navigator.pop(context); // قفل الشاشة لو الطرف التاني قفل
        },
      ),
    );

    // 4. تفعيل الفيديو أو الصوت حسب نوع المكالمة
    if (widget.isVideo) {
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine.enableVideo();
      await _engine.startPreview();
    } else {
      await _engine.enableAudio();
    }

    // 5. الانضمام للغرفة (الـ callID هو اسم الغرفة المشتركة بينكم)
    await _engine.joinChannel(
      token: '', // سيبها فاضية طول ما المشروع في Testing Mode على موقع أجورا
      channelId: widget.callID,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _engine.leaveChannel();
    _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.isVideo ? 'Video Call' : 'Voice Call'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // عرض كاميرا الطرف التاني
          Center(
            child: _remoteVideo(),
          ),
          
          // عرض كاميرتك أنت (لو المكالمة فيديو)
          if (widget.isVideo)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 120,
                  height: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _localUserJoined
                        ? AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _engine,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          )
                        : const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
                ),
              ),
            ),
            
          // زرار قفل المكالمة
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.call_end, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة لعرض الطرف الآخر
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return widget.isVideo 
        ? AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: _engine,
              canvas: VideoCanvas(uid: _remoteUid),
              connection: RtcConnection(channelId: widget.callID),
            ),
          ) 
        : const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 100, color: Colors.white54),
              SizedBox(height: 20),
              Text('مكالمة صوتية جارية...', style: TextStyle(fontSize: 20, color: Colors.white)),
            ],
          );
    } else {
      return const Text(
        'في انتظار الطرف الآخر...',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.white),
      );
    }
  }
}