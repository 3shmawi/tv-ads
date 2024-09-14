// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:tv_ads/model/ad.dart';
//
// class AdminPanelPage extends StatefulWidget {
//   const AdminPanelPage({this.ad, super.key});
//
//   final AdModel? ad;
//
//   @override
//   AdminPanelPageState createState() => AdminPanelPageState();
// }
//
// class AdminPanelPageState extends State<AdminPanelPage> {
//   final _videoUrlController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _titleController = TextEditingController();
//   String? scale;
//   bool _autoPlay = true;
//   bool _fullScreen = false;
//   bool _enableCaption = false;
//   bool _loop = true;
//   bool _hideControls = true;
//   bool _mute = true;
//   bool _controlsVisibleAtStart = false;
//   UploadTask? uploadTask;
//   bool showLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.ad != null) {
//       _videoUrlController.text = widget.ad!.videoUrl;
//       _locationController.text = widget.ad!.location;
//       _titleController.text = widget.ad!.title;
//       scale = widget.ad!.scale;
//       _autoPlay = widget.ad!.isAutoPlay;
//       _fullScreen = widget.ad!.isFullScreen;
//       _enableCaption = widget.ad!.isEnableCaption;
//       _loop = widget.ad!.isLoop;
//       _hideControls = widget.ad!.isHideControls;
//       _mute = widget.ad!.isMute;
//       _controlsVisibleAtStart = widget.ad!.isControlsVisibleAtStart;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Admin Panel'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             ElevatedButton(
//               onPressed: _uploadVideo,
//               child: const Text('Upload Video'),
//             ),
//             if (showLoading) _buildProgress(),
//             const SizedBox(height: 20),
//             TextField(
//               readOnly: true,
//               controller: _videoUrlController,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Firebase Video URL',
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _titleController,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Title',
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextFormField(
//               controller: _locationController,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Location',
//               ),
//             ),
//             const SizedBox(height: 20),
//             DropdownButtonFormField<String>(
//               value: scale,
//               decoration: const InputDecoration(
//                   border: OutlineInputBorder(), labelText: 'TV Aspect Ratio'),
//               items: [
//                 "16:9",
//                 "4:3",
//                 "21:9",
//                 "1.85:1",
//                 "2.39:1",
//                 "1:1",
//                 "3:2",
//                 "5:4",
//                 "18:9",
//                 "16:10",
//               ].map((String category) {
//                 return DropdownMenuItem<String>(
//                   value: category,
//                   child: Text(category),
//                 );
//               }).toList(),
//               onChanged: (newValue) {
//                 setState(() {
//                   scale = newValue;
//                 });
//               },
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Please select a category';
//                 }
//                 return null;
//               },
//             ),
//             const SizedBox(height: 20),
//             const Divider(),
//             SwitchListTile(
//               title: const Text('Auto Play'),
//               value: _autoPlay,
//               onChanged: (value) {
//                 setState(() {
//                   _autoPlay = value;
//                 });
//               },
//             ),
//             SwitchListTile(
//               title: const Text('Loop Video'),
//               value: _loop,
//               onChanged: (value) {
//                 setState(() {
//                   _loop = value;
//                 });
//               },
//             ),
//             SwitchListTile(
//               title: const Text('Full Screen'),
//               value: _fullScreen,
//               onChanged: (value) {
//                 setState(() {
//                   _fullScreen = value;
//                 });
//               },
//             ),
//             SwitchListTile(
//               title: const Text('Mute Video'),
//               value: _mute,
//               onChanged: (value) {
//                 setState(() {
//                   _mute = value;
//                 });
//               },
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed:
//                   widget.ad != null ? _editVideoConfig : _saveVideoConfig,
//               child: Text(widget.ad == null ? "Create" : "Edit"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _uploadVideo() async {
//     FilePickerResult? result =
//         await FilePicker.platform.pickFiles(type: FileType.video);
//     if (result != null) {
//       File file = File(result.files.single.path!);
//       try {
//         // Upload file to Firebase Storage
//         String fileName = result.files.single.name;
//         final uploadVideo = FirebaseStorage.instance.ref('videos/$fileName');
//
//         setState(() {
//           showLoading = true;
//
//           uploadTask = uploadVideo.putFile(file);
//         });
//         final snapshot = await uploadTask!.whenComplete(() => null);
//
//         final urlDownload = await snapshot.ref.getDownloadURL();
//         // Get the URL of the uploaded file
//         _videoUrlController.text = urlDownload;
//
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Video uploaded successfully')));
//       } catch (e) {
//         showLoading = false;
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to upload video')));
//       }
//     }
//   }
//
//   void _saveVideoConfig() {
//     if (_videoUrlController.text.isNotEmpty &&
//         _locationController.text.isNotEmpty &&
//         _titleController.text.isNotEmpty) {
//       FirebaseFirestore.instance
//           .collection("count")
//           .doc("#")
//           .get()
//           .then((response) {
//         FirebaseFirestore.instance
//             .collection('ads')
//             .doc(response.data()!["count"])
//             .set(
//               AdModel(
//                 id: response.data()!["count"],
//                 videoUrl: _videoUrlController.text,
//                 location: _locationController.text,
//                 scale: scale!,
//                 title: _titleController.text,
//                 control: _autoPlay ? "play" : "pause",
//                 rotation: 0.0,
//                 isMute: _mute,
//                 isLoop: _loop,
//                 isAutoPlay: _autoPlay,
//                 isFullScreen: _fullScreen,
//                 isEnableCaption: _enableCaption,
//                 isControlsVisibleAtStart: _controlsVisibleAtStart,
//                 isHideControls: _hideControls,
//               ).toJson(),
//               SetOptions(merge: true),
//             )
//             .then((v) {
//           setState(() {
//             _videoUrlController.clear();
//             uploadTask = null;
//             _autoPlay = false;
//             _fullScreen = false;
//             _enableCaption = false;
//             _loop = false;
//             _hideControls = false;
//             _mute = false;
//             showLoading = false;
//             _controlsVisibleAtStart = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               backgroundColor: Colors.green,
//               content: Text('Video configuration saved successfully'),
//             ),
//           );
//           Navigator.pop(context);
//         }).catchError((e) {
//           showLoading = false;
//           setState(() {});
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               backgroundColor: Colors.red,
//               content: Text('Failed to save video configuration'),
//             ),
//           );
//         });
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: Colors.red,
//           content: Text('Please Fill all fields'),
//         ),
//       );
//     }
//   }
//
//   void _editVideoConfig() {
//     final fireStore = FirebaseFirestore.instance;
//     if (_videoUrlController.text.isNotEmpty &&
//         _locationController.text.isNotEmpty &&
//         _titleController.text.isNotEmpty) {
//       fireStore
//           .collection('ads')
//           .doc(widget.ad!.id)
//           .update(
//             AdModel(
//               id: widget.ad!.id,
//               videoUrl: _videoUrlController.text,
//               location: _locationController.text,
//               scale: scale!,
//               title: _titleController.text,
//               control: _autoPlay ? "play" : "pause",
//               rotation: 0.0,
//               isMute: _mute,
//               isLoop: _loop,
//               isAutoPlay: _autoPlay,
//               isFullScreen: _fullScreen,
//               isEnableCaption: _enableCaption,
//               isControlsVisibleAtStart: _controlsVisibleAtStart,
//               isHideControls: _hideControls,
//             ).toJson(),
//           )
//           .then((v) {
//         setState(() {
//           _videoUrlController.clear();
//           uploadTask = null;
//           _autoPlay = false;
//           _fullScreen = false;
//           _enableCaption = false;
//           _loop = false;
//           _hideControls = false;
//           _mute = false;
//           showLoading = false;
//           _controlsVisibleAtStart = false;
//         });
//         fireStore.collection("count").doc("#").get().then((data) {
//           if (data.exists) {
//             int id = int.parse(data.data()!["count"]);
//             fireStore
//                 .collection("count")
//                 .doc("#")
//                 .update({"count": (id + 1).toString()});
//           } else {
//             fireStore.collection("count").doc("#").set({"count": "0"});
//           }
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             backgroundColor: Colors.green,
//             content: Text('Video configuration saved successfully'),
//           ),
//         );
//         Navigator.of(context).pop();
//       }).catchError((e) {
//         showLoading = false;
//         setState(() {});
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             backgroundColor: Colors.red,
//             content: Text('Failed to save video configuration'),
//           ),
//         );
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           backgroundColor: Colors.red,
//           content: Text('Please Fill all fields'),
//         ),
//       );
//     }
//   }
//
//   Widget _buildProgress() => uploadTask == null
//       ? Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               TweenAnimationBuilder(
//                 tween: Tween(begin: 0.0, end: 1.0),
//                 duration: const Duration(seconds: 10),
//                 builder: (context, value, child) {
//                   return Column(
//                     children: [
//                       Text('${(value * 100).toInt().toString()}%'),
//                       LinearProgressIndicator(
//                         value: value,
//                         backgroundColor: Colors.black,
//                         color: Colors.green,
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         )
//       : StreamBuilder<TaskSnapshot>(
//           stream: uploadTask?.snapshotEvents,
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               final data = snapshot.data!;
//               double progress = data.bytesTransferred / data.totalBytes;
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TweenAnimationBuilder(
//                   tween: Tween(begin: 0.0, end: progress),
//                   duration: Duration(seconds: progress.toInt()),
//                   builder: (context, value, child) {
//                     return Column(
//                       children: [
//                         Text('${(value * 100).toInt().toString()}%'),
//                         LinearProgressIndicator(
//                           value: value,
//                           backgroundColor: Colors.grey.shade300,
//                           color: Colors.green,
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               );
//             } else {
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     TweenAnimationBuilder(
//                       tween: Tween(begin: 0.0, end: 1.0),
//                       duration: const Duration(seconds: 1),
//                       builder: (context, value, child) {
//                         return Column(
//                           children: [
//                             Text('${(value * 100).toInt().toString()}%'),
//                             LinearProgressIndicator(
//                               value: value,
//                               backgroundColor: Colors.black,
//                               color: Colors.green,
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             }
//           },
//         );
// }
