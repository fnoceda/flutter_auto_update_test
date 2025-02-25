import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_autoupdate/flutter_autoupdate.dart';
import 'package:version/version.dart';

class AutoUpdateService {
  UpdateManager updater;
  AutoUpdateService({
    required this.updater,
  }) {
    if (Platform.isAndroid) {
      // Android/Windows
      updater = UpdateManager(versionUrl: 'versionUrl');
    } else if (Platform.isIOS) {
// iOS
      updater = UpdateManager(appId: 1500009417);
    }
  }

  Future<void> autoUpdate() async {
// App Store country code, this flag is optional and only applies to iOS
    var result = await updater.fetchUpdates();
    print(result?.latestVersion);
    print(result?.downloadUrl);
    print(result?.releaseNotes);
    print(result?.releaseDate);

    if (result!.latestVersion > Version.parse('1.0.0')) {
      // Get update stream controller
      var update = await result.initializeUpdate();
      update.stream.listen((event) async {
        // You can build a download progressbar from the data available here
        debugPrint('event.receivedBytes => ${event.receivedBytes}');

        debugPrint('event.totalBytes => ${event.totalBytes}');

        if (event.completed) {
          print('Download completed');

          // Close the stream controller
          await update.close();

          // On Windows, autoExit and exitDelay flag are supported.
          // On iOS, this will attempt to launch the App Store from the appId provided
          // On Android, this will simply attempt to install the downloaded APK
          await result.runUpdate(event.path, autoExit: true, exitDelay: 5000);
        }
      });
    }
  }
}
