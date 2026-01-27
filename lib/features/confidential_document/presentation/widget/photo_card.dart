import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/entity/picture_download.dart';

class PhotoCard extends StatelessWidget{
  final PictureDownload image;
  final VoidCallback? onDelete;

  const PhotoCard({super.key, required this.image, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
    clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(image.byte,
          fit: BoxFit.cover,),
          Positioned(bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(image.title),
          ),)
        ],
      ),
    );
  }

}