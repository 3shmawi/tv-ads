// import 'dart:math' as math;
//
// import 'package:chewie/chewie.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:tv_ads/model/ad.dart';
// import 'package:video_player/video_player.dart';
//
// class VideoPlayerCard extends StatefulWidget {
//   const VideoPlayerCard({super.key});
//
//   @override
//   VideoPlayerCardState createState() => VideoPlayerCardState();
// }
//
// class VideoPlayerCardState extends State<VideoPlayerCard> {
//   late VideoPlayerController _videoPlayerController;
//   ChewieController? _chewieController;
//   final fireStore = FirebaseFirestore.instance;
//
//   late Stream<DocumentSnapshot> _videoControlStream;
//   double _rotation = 0.0;
//   bool _isVideoInitialized = false;
//
//   int newAdId = -1;
//   bool isNewAdIdInitialized = false;
//
//   _getAds() async {
//     final response = await fireStore.collection("tv_ads").get();
//     for (var doc in response.docs) {
//       if (newAdId.toString() == doc.id) {
//         setState(() {
//           isNewAdIdInitialized = true;
//         });
//       }
//     }
//     if (!isNewAdIdInitialized) return;
//
//     _videoControlStream = FirebaseFirestore.instance
//         .collection('tv_ads')
//         .doc(newAdId.toString())
//         .snapshots();
//     _videoControlStream.listen((snapshot) {
//       if (snapshot.exists) {
//         final data = AdModel.fromJson(snapshot.data() as Map<String, dynamic>);
//         if (_isVideoInitialized == false) {
//           _initializeVideo(data);
//         }
//
//         if (data.ads.first.isPlaying) {
//           pauseVideo();
//         } else {
//           stopVideo();
//         }
//         if (data.ads.first.isFullScreen) {
//           _chewieController!.enterFullScreen();
//         } else {
//           _chewieController!.exitFullScreen();
//         }
//
//         setState(() {
//           _rotation = data.ads.first.rotation;
//         });
//       }
//     });
//   }
//
//   _start() async {
//     final shared = await SharedPreferences.getInstance();
//     final fireStore = FirebaseFirestore.instance;
//     if (shared.getString("id") == null) {
//       fireStore.collection("count").doc("#").get().then((v) {
//         String id = v.data()!["count"];
//         shared.setString("id", id);
//         _videoControlStream = FirebaseFirestore.instance
//             .collection('tv_ads')
//             .doc(newAdId.toString())
//             .snapshots();
//         _videoControlStream.listen((snapshot) {
//           if (snapshot.exists) {
//             final data =
//                 AdModel.fromJson(snapshot.data() as Map<String, dynamic>);
//             if (_isVideoInitialized == false) {
//               _initializeVideo(data);
//             }
//
//             if (data.ads.first.isPlaying) {
//               pauseVideo();
//             } else {
//               stopVideo();
//             }
//             if (data.ads.first.isFullScreen) {
//               _chewieController!.enterFullScreen();
//             } else {
//               _chewieController!.exitFullScreen();
//             }
//
//             setState(() {
//               _rotation = data.ads.first.rotation;
//             });
//           }
//         });
//       });
//     } else {
//       _videoControlStream = FirebaseFirestore.instance
//           .collection('ads')
//           .doc(shared.getString("id"))
//           .snapshots();
//       _videoControlStream.listen((snapshot) {
//         if (snapshot.exists) {
//           final data =
//               AdModel.fromJson(snapshot.data() as Map<String, dynamic>);
//           if (_isVideoInitialized == false) {
//             _initializeVideo(data);
//           } else {
//             if (data.ads.first.isPlaying) {
//               pauseVideo();
//             } else {
//               stopVideo();
//             }
//             if (data.ads.first.isFullScreen) {
//               _chewieController!.enterFullScreen();
//             } else {
//               _chewieController!.exitFullScreen();
//             }
//
//             setState(() {
//               _rotation = data.ads.first.rotation;
//             });
//           }
//         }
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _start();
//   }
//
//   Future<void> _initializeVideo(AdModel ad) async {
//     _videoPlayerController = VideoPlayerController.networkUrl(
//       Uri.parse(ad.ads.first.url),
//     )..initialize().then((_) {
//         _chewieController = ChewieController(
//           videoPlayerController: _videoPlayerController,
//           autoPlay: true,
//           looping: true,
//           allowMuting: ad.ads.first.isMute,
//           allowFullScreen: ad.ads.first.isFullScreen,
//         );
//         setState(() {
//           _isVideoInitialized = true;
//         });
//       });
//   }
//
//   @override
//   void dispose() {
//     _chewieController!.dispose();
//     _videoPlayerController.dispose();
//
//     super.dispose();
//   }
//
//   void pauseVideo() {
//     _chewieController!.pause();
//   }
//
//   void resumeVideo() {
//     _chewieController!.play();
//   }
//
//   void stopVideo() {
//     _chewieController!.pause();
//     _chewieController!.seekTo(Duration.zero);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: _isVideoInitialized
//           ? Transform.rotate(
//               angle: _rotation * math.pi / 180,
//               child: FittedBox(
//                 fit: BoxFit.cover,
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width,
//                   height: MediaQuery.of(context).size.height,
//                   child: Chewie(
//                     controller: _chewieController!,
//                   ),
//                 ),
//               ),
//             )
//           : const CircularProgressIndicator.adaptive(),
//     );
//   }
// }
