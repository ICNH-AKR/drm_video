import 'package:flutter/material.dart';
import 'package:drm_video/drm_video.dart';
import 'package:drm_video/video_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  VideoController _videoController;
  String dashUrl = "https://storage.googleapis.com/wvmedia/cenc/h264/tears/tears.mpd";
  String licenseUrl = "https://proxy.staging.widevine.com/proxy";
  // String dashUrl =
  //     "https://media.at2010.net/test-drm/item3/dash/00307268_47MetersDown_Feature_FEATURE_DE_169_1080_p_24_ProResHQ_TC00000000.mpd";
  // String licenseUrl = "https://lic.drmtoday.com/license-proxy-widevine/cenc/";

  final String drmTodayUrl = 'https://lic.drmtoday.com/license-proxy-widevine/cenc/';
  final String assetId = 'dash2';
  final String variantId = '';
  final String merchant = 'cliq';
  final String userId = 'rental1';
  final String sessionId = 'p0';
  final String authToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2NTA1NTY3NTMsInJvbGVzIjpbXSwiaWQiOiJmMTQ3NWJlNy00YTExLTRmZWItYjRiMi04OGM2ZmRlMzMzZTYifQ.IHZHtXU8QDVCbDuHVb4dUEhAczI6-9fTLEHrlLPFbO9zvqa7RhzLU4jbOeZwik_PMcLZsw32-aayxT3baJn_VwBbX8UxiMJhy85ObEZ21Fj5ZSZZikz8EW6mw98U-HghKThuoJKe7DaSus9qafL4IXAD6XGsP6Fcclo44haO90e9cfqxSj9V4JaiWOQ-ksq3Orn2cxwUKyL72W8wqnsolW_WTzddvQUNL8rtjtwyxPdCzuVoWPwXy21mhb4pCqjjEfed4n2szxu0BGVH0hMqVtXFSVGA72ikrTlOxjnjGDF5G4LkxE7fAeEoZlsUoIq2AS47qxufJNfba7ichIPPWtV0Qps3bKn45ffPr1Y8Rl1eW_rpmBv3WYQundfYqECWfSDP4D4XbbyzgEa6p6zytaz4VkuQOhKvNbG4EFv1HhaFrty-TU7208HwPMpTvXJx6NiG9P9Zynadk14Gfd7HllejlIFXBO9kGtUu2UU1P_jSLG6EhOjc2ZHVZLTu1jq6YlETdGwrxD-xOooDXc4t2ypMDw96nzsnPjVHPSSO5r3O3zc1MpdnDOJyKFRU-i4p8EODG7y_NHmz0V2ilo5gsZYsj2WIisCsLN3ICD9Ecl0RVJtSxCyCIDcqoFsqufYOzJKIDPx0no_9UgW9lxO2YxsTAbeiVzvNCAgnXljNpX4';
  final bool useCastlab = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: _videoController?.value?.aspectRatio ?? 16 / 9,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    Container(
                      child: DrmVideoPlayer(
                        videoUrl: dashUrl,
                        autoPlay: false,
                        drmLicenseUrl: licenseUrl,
                        onVideoControls: (VideoController controller) {
                          print("onVideoControls $controller");
                          _videoController = controller;
                          _videoController.addListener(() {
                            setState(() {});
                          });
                          setState(() {});
                        },
                        assetId: assetId,
                        authToken: authToken,
                        isCastlab: useCastlab,
                        merchant: merchant,
                        sessionId: sessionId,
                        userId: userId,
                      ),
                    ),
                    if (_videoController != null) _ControlsOverlay(controller: _videoController),
                  ],
                ),
              ),
              if (_videoController != null)
                VideoProgressIndicator(
                  _videoController,
                  allowScrubbing: true,
                  colors: VideoProgressColors(),
                ),
              if (_videoController != null) Text("text ${_videoController.value.position}"),
              if (_videoController != null) Text("text ${_videoController.value.duration}"),
              Text("text ${_videoController == null}"),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key key, this.controller}) : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoController controller;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: controller?.value?.aspectRatio ?? 16 / 9,
      child: Stack(
        children: <Widget>[
          AnimatedSwitcher(
            duration: Duration(milliseconds: 50),
            reverseDuration: Duration(milliseconds: 200),
            child: controller.value.isPlaying
                ? SizedBox.shrink()
                : Container(
                    color: Colors.black26,
                    child: Center(
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 100.0,
                      ),
                    ),
                  ),
          ),
          GestureDetector(
            onTap: () {
              controller.value.isPlaying ? controller.pause() : controller.play();
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: PopupMenuButton<double>(
              initialValue: controller.value.playbackSpeed,
              tooltip: 'Playback speed',
              onSelected: (speed) {
                controller.setPlaybackSpeed(speed);
              },
              itemBuilder: (context) {
                return [
                  for (final speed in _examplePlaybackRates)
                    PopupMenuItem(
                      value: speed,
                      child: Text('${speed}x'),
                    )
                ];
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  // Using less vertical padding as the text is also longer
                  // horizontally, so it feels like it would need more spacing
                  // horizontally (matching the aspect ratio of the video).
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Text('${controller.value.playbackSpeed}x'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
