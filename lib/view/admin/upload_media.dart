import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../model/ad.dart';
import 'home.dart';

class AdUploadPage extends StatefulWidget {
  const AdUploadPage(this.model, {super.key});

  final AdModel model;

  @override
  _AdUploadPageState createState() => _AdUploadPageState();
}

class _AdUploadPageState extends State<AdUploadPage> {
  List<Map> _data = [];
  bool _isUploading = false;

  List<Ad> ads = []; // List to store ads

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia() async {
    final XFile? pickedFiles = await _picker.pickMedia();

    if (pickedFiles != null) {
      _data.add({
        'isVideo': pickedFiles.path.endsWith('.mp4'),
        'isPlaying': false,
        'mediaFile': File(pickedFiles.path),
        'videoController': _initializeVideo(
            pickedFiles.path.endsWith('.mp4') ? File(pickedFiles.path) : null)
      });
      setState(() {});
    }
  }

  VideoPlayerController? _initializeVideo(File? file) {
    if (file == null) return null;
    VideoPlayerController controller = VideoPlayerController.file(file);
    controller.initialize();
    controller.pause();
    return controller;
  }

  Future<void> _uploadAds() async {
    if (_data.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      for (int i = 0; i < _data.length; i++) {
        final file = _data[i]["mediaFile"];
        final isVideo = _data[i]["isVideo"];
        final fileName = file.path.split('/').last;
        final ref = FirebaseStorage.instance
            .ref()
            .child('${isVideo ? "Videos" : "Images"}/$fileName');
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask.whenComplete(() => {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        final ad = Ad(
          id: i.toString(),
          url: downloadUrl,
          isVideo: isVideo,
        );

        ads.add(ad);
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(' حدث خطأ:$e'),
        ),
      );
    }
  }

  Future<void> _saveAdsToFireStore() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.cyan,
        content: Text('جاري رفع الصور والفيديوهات'),
      ),
    );
    Future.delayed(Duration(seconds: 9)).then((v) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.cyan,
          content: Text('تبقى القليل'),
        ),
      );
    });
    await _uploadAds();

    FirebaseFirestore.instance
        .collection('tv_ads')
        .doc(widget.model.id)
        .set(widget.model.copyWith(ads: ads).toJson())
        .then((_) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('تم رفع الإعلانات بنجاح'),
          ),
        );
        _isUploading = false;
        _data = [];
        ads = [];
        FirebaseFirestore.instance.collection("count").doc("#").update({
          "count": FieldValue.increment(1),
        });
      });
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const AdminHomePage(),
        ),
        (route) => false,
      );
    }).catchError(
      (error) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(' حدث خطأ:$error'),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    for (var element in _data) {
      if (element["isVideo"]) {
        final controller = element["videoController"];
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text("اكمال تحميل واختيار الإعلانات"),
          ),
          body: _data.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_search,
                        size: 100.0,
                        color: Colors.grey.shade500,
                      ),
                      Text('لا توجد إعلاتات تم إخيارها'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _pickMedia,
                        child: Text('التقاط صورة أو فيديو'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 150, top: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: List.generate(
                            _data.length,
                            (index) {
                              final file = _data[index]["mediaFile"];
                              final isVideo = _data[index]["isVideo"];
                              final controller =
                                  _data[index]["videoController"];
                              return SizedBox(
                                height: isVideo ? null : 250,
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    Card(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: isVideo
                                          ? AspectRatio(
                                              aspectRatio: double.parse(widget
                                                      .model.scale
                                                      .split(":")
                                                      .first) /
                                                  double.parse(widget
                                                      .model.scale
                                                      .split(":")
                                                      .last),
                                              child: VideoPlayer(controller),
                                            )
                                          : Image.file(
                                              file,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    CircleAvatar(
                                      backgroundColor: Colors.black38,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete_forever,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          if (_data[index]['isVideo']) {
                                            controller.dispose();
                                          }
                                          _data.removeAt(index);

                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    if (isVideo)
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black38,
                                          child: IconButton(
                                            icon: Icon(
                                              CupertinoIcons.refresh,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              _data[index]["videoController"]
                                                  .seekTo(Duration.zero);
                                              _data[index]["videoController"]
                                                  .play();
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _pickMedia,
                          child: Text('التقاط المزيد'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _saveAdsToFireStore,
                            child: Text('تأكيد'),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Card(
                            color: Colors.cyan,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(widget.model.title),
                            ),
                          ),
                          Card(
                            color: Colors.cyan,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(widget.model.location),
                            ),
                          ),
                          Card(
                            color: Colors.cyan,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(widget.model.scale),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        if (_isUploading)
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.black38,
          ),
        if (_isUploading)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'يرجى الانتظار حتى\nيكتمل التحميل...',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
