    import 'package:flutter/material.dart';
import 'package:poolinspection/src/controllers/photo_controller.dart';

var floatingActionButton2 = FloatingActionButton(shape: CircleBorder(),
              child: IconButton(
                icon: Icon(Icons.camera),
                onPressed: PhotoController().loadAssets,
              ),
            );