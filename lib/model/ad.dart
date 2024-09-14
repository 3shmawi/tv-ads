class AdModel {
  String id;

  List<Ad> ads;
  String title;
  String location;
  String scale;
  int duration;

  AdModel({
    required this.id,
    required this.ads,
    required this.title,
    required this.location,
    required this.scale,
    required this.duration,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    List<Ad> ads = [];

    if (json['ads'] != null) {
      json['ads'].forEach((v) {
        ads.add(Ad.fromJson(v));
      });
    }
    return AdModel(
      id: json['id'],
      ads: ads,
      title: json['title'],
      location: json['location'],
      scale: json['scale'],
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ads': ads.map((e) => e.toJson()).toList(),
      'title': title,
      'location': location,
      'scale': scale,
      'duration': duration,
    };
  }

  AdModel copyWith({
    List<Ad>? ads,
    String? title,
    String? location,
    String? scale,
    int? duration,
  }) {
    return AdModel(
      id: id,
      ads: ads ?? this.ads,
      title: title ?? this.title,
      location: location ?? this.location,
      scale: scale ?? this.scale,
      duration: duration ?? this.duration,
    );
  }
}

class Ad {
  final String id;
  final String url;
  final bool isVideo;
  final double rotation;
  final bool isMute;
  final bool isPlaying;
  final bool isFullScreen;

  Ad({
    required this.id,
    required this.url,
    required this.isVideo,
    this.rotation = 0.0,
    this.isMute = false,
    this.isPlaying = true,
    this.isFullScreen = true,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'],
      url: json['url'],
      isVideo: json['isVideo'],
      rotation: json['rotation'].toDouble(),
      isMute: json['isMute'],
      isPlaying: json['isPlaying'],
      isFullScreen: json['isFullScreen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'isVideo': isVideo,
      'rotation': rotation,
      'isMute': isMute,
      'isPlaying': isPlaying,
      'isFullScreen': isFullScreen,
    };
  }
}
