import 'dart:async';
import 'dart:math' as math;

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tv_ads/model/ad.dart';
import 'package:video_player/video_player.dart';

import '../shared/cache.dart';

class TvAdView extends StatefulWidget {
  const TvAdView({super.key});

  @override
  TvAdViewState createState() => TvAdViewState();
}

class TvAdViewState extends State<TvAdView> {
  final fireStore = FirebaseFirestore.instance;

  bool isStarted = false;
  late Stream<DocumentSnapshot> _videoControlStream;

  int newAdId = -1;
  bool isNewAdIdInitialized = false;

  AdModel? ad;

  _start1() {
    fireStore.collection("count").doc("#").get().then((response) {
      newAdId = response.data()!["count"] + 1; ////////////////////////////////
      setState(() {});
      _bind();
    });
  }

  _bind() {
    if (!isNewAdIdInitialized) {
      Timer.periodic(
        Duration(seconds: 3),
        (timer) {
          _getAds();
        },
      );
    }
  }

  _getAds() async {
    final response = await fireStore.collection("tv_ads").get();
    for (var doc in response.docs) {
      if (newAdId.toString() == doc.id) {
        setState(() {
          isNewAdIdInitialized = true;
        });
        break;
      }
    }
    if (!isNewAdIdInitialized) return;

    _videoControlStream = FirebaseFirestore.instance
        .collection('tv_ads')
        .doc(newAdId.toString())
        .snapshots();
    _videoControlStream.listen(
      (snapshot) {
        if (snapshot.exists) {
          final data =
              AdModel.fromJson(snapshot.data() as Map<String, dynamic>);

          if (ad == null) {
            setState(() {
              ad = data;
              // if (isStarted == false) {
              _repeat();
              // }
            });
          }
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _start1();
  }

  int currentAdId = 0;

  _repeat() async {
    // _disposeCtrl();
    _initialize();

    Timer.periodic(Duration(seconds: ad!.duration), (t) {
      currentAdId++;
      if (currentAdId >= ad!.ads.length) {
        currentAdId = 0;
      }
      // if (currentAdId - 1 == -1) {
      //   if (ad!.ads[ad!.ads.length - 1].isVideo) {
      //     _disposeCtrl();
      //   }
      // } else {
      //   if (ad!.ads[currentAdId - 1].isVideo) {
      //     _disposeCtrl();
      //   }
      // }

      setState(() {});
    });
  }

  //ads
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  double _rotation = 0.0;

  bool _isVideoInitialized = false;

  _initialize() async {
    if (ad!.ads[currentAdId].isVideo) {
      if (_isVideoInitialized == false) {
        await _initializeVideo(ad!.ads[currentAdId]);
      }

      if (ad!.ads[currentAdId].isPlaying) {
        pauseVideo();
      } else {
        stopVideo();
      }
      // if (ad!.ads[currentAdId].isFullScreen) {
      //   _chewieController!.enterFullScreen();
      // } else {
      // _chewieController!.exitFullScreen();
      // }
    }
    setState(() {
      _rotation = ad!.ads[currentAdId].rotation;
    });
  }

  Future<void> _initializeVideo(Ad ad) async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(ad.url),
    )..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          looping: true,
          allowMuting: false,
          allowFullScreen: ad.isFullScreen,
          showOptions: false,
          showControls: false,
          showControlsOnInitialize: false,
        );
        _chewieController!.setVolume(0);
        setState(() {
          _isVideoInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _disposeCtrl();

    super.dispose();
  }

  _disposeCtrl() {
    if (_isVideoInitialized) {
      _chewieController!.dispose();
      _videoPlayerController.dispose();
    }
  }

  void pauseVideo() {
    _chewieController!.pause();
  }

  void resumeVideo() {
    _chewieController!.play();
  }

  void stopVideo() {
    _chewieController!.pause();
    _chewieController!.seekTo(Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    if (isNewAdIdInitialized) {
      if (ad == null) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
      }
      // return Scaffold(
      //   body: AdVideoView(ad!.ads[currentAdId]),
      // );
      if (!ad!.ads[currentAdId].isVideo) {
        return Scaffold(
          body: Center(
            child: CustomCacheImage(
              width: ad!.ads[currentAdId].isFullScreen ? double.infinity : null,
              height:
                  ad!.ads[currentAdId].isFullScreen ? double.infinity : null,
              imageUrl: ad!.ads[currentAdId].url,
              radius: 20,
              topLeft: true,
              topRight: true,
              bottomLeft: true,
              bottomRight: true,
            ),
          ),
        );
      }
      return Scaffold(
        body: Center(
          child: _isVideoInitialized
              ? Transform.rotate(
                  angle: _rotation * math.pi / 180,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Chewie(
                        controller: _chewieController!,
                      ),
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator.adaptive(),
                    const SizedBox(height: 20),
                    const Text(
                      'Video/Image loading...',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
        ),
      );
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            newAdId == -1
                ? CircularProgressIndicator()
                : Text(
                    newAdId.toString(),
                    style: TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
            const SizedBox(
              height: 40,
            ),
            Text(
              'هذا الرقم التسلسلي للإعلان',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              'قم بادخالة في تطبيق الادمن،\nثم اكمل عملية تحميل الفيديو',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
