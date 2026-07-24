import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConsultationNotificationService {

  static final AudioPlayer player =
      AudioPlayer();

  static Future<void> showIncomingConsultation({

    required String petName,
    required String symptoms,
    required VoidCallback onAccept,

  }) async {

    await player.play(
      AssetSource("ringtone.mp3"),
    );

    Get.dialog(

      barrierDismissible: false,

      AlertDialog(

        title: const Text(
          "New Consultation",
        ),

        content: Column(

          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Text("Pet Name : $petName"),

            const SizedBox(height: 8),

            Text("Symptoms : $symptoms"),
          ],
        ),

        actions: [

          ElevatedButton(

            onPressed: () {

              player.stop();

              Get.back();

              onAccept();
            },

            child: const Text(
              "Accept",
            ),
          ),

          ElevatedButton(

            onPressed: () {

              player.stop();

              Get.back();
            },

            child: const Text(
              "Reject",
            ),
          ),
        ],
      ),
    );
  }
}