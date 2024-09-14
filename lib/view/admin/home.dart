import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tv_ads/model/ad.dart';
import 'package:tv_ads/view/admin/upload_edit_ad.dart';

import '../../app/functions.dart';
import '../shared/cache.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  AdminHomePageState createState() => AdminHomePageState();
}

class AdminHomePageState extends State<AdminHomePage> {
  int calculateCrossAxisCount(BuildContext context) {
    final screenWidth = Dimensions.screenWidth(context);

    if (screenWidth > 1200) {
      return 4;
    } else if (screenWidth > 768) {
      return 3;
    } else {
      return 2;
    }
  }

  Stream<List<AdModel>> _getAds() {
    final fireStore = FirebaseFirestore.instance;
    return fireStore.collection("tv_ads").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AdModel.fromJson(doc.data());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: StreamBuilder<List<AdModel>>(
            stream: _getAds(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final data = snapshot.data;
              return GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: calculateCrossAxisCount(context),
                  mainAxisSpacing: Dimensions.heightPercentage(context, 1),
                  crossAxisSpacing: Dimensions.widthPercentage(context, 1),
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  return CardItem(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return UploadEditAdView(
                              adModel: data[index],
                            );
                          },
                        ),
                      );
                    },
                    scale: data[index].scale,
                    title: data[index].title,
                  );
                },
                itemCount: data!.length,
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const UploadEditAdView();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CardItem extends StatefulWidget {
  const CardItem({
    required this.scale,
    required this.title,
    this.onTap,
    super.key,
  });

  final GestureTapCallback? onTap;
  final String scale;
  final String title;

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {});
      });

    _animation2 = Tween<double>(begin: -30, end: 0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Opacity(
        opacity: _animation.value,
        child: Transform.translate(
          offset: Offset(0, _animation2.value),
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: widget.onTap,
            child: SizedBox(
              height: w / 1.5,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CustomCacheImage(
                      imageUrl:
                          'https://plus.unsplash.com/premium_photo-1701713781709-966e8f4c5920?w=700&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHx8',
                      height: w / 1.1,
                      width: double.infinity,
                      radius: 25,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(
                            15,
                          ),
                        ),
                        child: Text(
                          widget.scale,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      height: 35,
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(25),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.title,
                          maxLines: 4,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
