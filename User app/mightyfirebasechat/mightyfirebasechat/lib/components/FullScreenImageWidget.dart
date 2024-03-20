import '../../utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImageWidget extends StatefulWidget {
  final String? photoUrl;
  final String? name;
  final bool isFromChat;
  final bool isVideo;
  final String? heroId;

  FullScreenImageWidget({this.photoUrl, this.name, this.isFromChat = false, this.heroId = '', this.isVideo = false});

  _FullScreenImageWidgetState createState() => _FullScreenImageWidgetState();
}

class _FullScreenImageWidgetState extends State<FullScreenImageWidget> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    init();
    log("value--" + widget.heroId!.toString());
  }

  init() async {
    if (widget.isVideo) {
      controller = VideoPlayerController.networkUrl(Uri.parse(widget.photoUrl!))
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
          controller!.play();
          controller!.addListener(() {
            checkVideo();
          });
        });
    }
  }

  void checkVideo() {
    if (controller!.value.position == Duration(seconds: 0, minutes: 0, hours: 0)) {}

    if (controller!.value.position == controller!.value.duration) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      if (widget.isVideo) {
        return Container(
          height: context.height() * 0.8,
          width: context.width(),
          child: Stack(
            children: [
              VideoPlayer(controller!),
              IconButton(
                icon: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black38),
                  alignment: Alignment.center,
                  child: Icon(controller!.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white).center(),
                ),
                onPressed: () {
                  controller!.value.isPlaying ? controller!.pause() : controller!.play();
                  setState(() {});
                },
              ).center(),
            ],
          ),
        );
      }
      return SizedBox.expand(
        child: Hero(
          tag: widget.heroId!,
          child: PhotoView(
            imageProvider: NetworkImage(widget.photoUrl != null ? widget.photoUrl.validate() : ''),
            errorBuilder: (BuildContext? context, Object? exception, StackTrace? stackTrace) {
              return Image.asset('assets/placeholder.jpg');
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBarWidget("${widget.name.validate().capitalizeFirstLetter()} ", textColor: Colors.white, color: primaryColor),
      body: body(),
    );
  }
}
