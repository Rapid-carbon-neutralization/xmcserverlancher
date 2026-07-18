// 文件下载服务
// 提供流式 HTTP 下载能力，支持逐块写入文件并回调实时进度（已下载字节、总字节、百分比、速度）。
// 本文件为纯 Dart 服务，不依赖 Flutter，仅使用 http、path 与 dart:io。

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// 下载进度信息。
///
/// 由 [Downloader.downloadFile] 在下载过程中周期性回调，
/// 用于驱动 UI 进度条与速度显示等。
class DownloadProgress {
  /// 已下载的字节数。
  final int downloadedBytes;

  /// 文件总字节数，服务端未提供时为 -1。
  final int totalBytes;

  /// 当前下载速度（字节/秒）。
  final double speedBytesPerSec;

  const DownloadProgress({
    required this.downloadedBytes,
    required this.totalBytes,
    required this.speedBytesPerSec,
  });

  /// 下载百分比（0.0 - 100.0）。
  ///
  /// 总字节数未知（<= 0）时返回 0.0。
  double get percent {
    if (totalBytes <= 0) return 0.0;
    return (downloadedBytes / totalBytes) * 100.0;
  }
}

/// 文件下载服务。
///
/// 封装基于 http 包的流式下载逻辑，将响应体逐块写入目标文件，
/// 并在每块写入后回调最新进度。
class Downloader {
  /// 下载指定 URL 的文件到目标路径。
  ///
  /// [url] 资源地址；[targetFilePath] 本地保存路径；[onProgress] 进度回调。
  ///
  /// 使用 `http.Client().send(http.Request('GET', ...))` 获取流式响应，
  /// 逐块读取 [StreamedResponse.stream] 并写入文件 IOSink。
  /// 成功时返回目标文件路径；HTTP 状态码非 200 时抛出 [Exception]。
  Future<String> downloadFile(
    String url,
    String targetFilePath,
    void Function(DownloadProgress) onProgress,
  ) async {
    // 确保目标文件的父目录存在。
    final parentDir = Directory(p.dirname(targetFilePath));
    if (!parentDir.existsSync()) {
      parentDir.createSync(recursive: true);
    }

    final client = http.Client();
    try {
      // 发起流式 GET 请求。
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('下载失败：HTTP 状态码 ${response.statusCode}');
      }

      // contentLength 为 -1 表示服务端未提供总大小。
      final totalBytes = response.contentLength ?? -1;
      final sink = File(targetFilePath).openWrite();
      final stopwatch = Stopwatch()..start();
      var downloadedBytes = 0;

      try {
        // 逐块读取响应流并写入文件，每块更新进度。
        await for (final chunk in response.stream) {
          sink.add(chunk);
          downloadedBytes += chunk.length;

          // 根据已用时间计算平均下载速度。
          final elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
          final speed =
              elapsedSeconds > 0 ? downloadedBytes / elapsedSeconds : 0.0;

          onProgress(DownloadProgress(
            downloadedBytes: downloadedBytes,
            totalBytes: totalBytes,
            speedBytesPerSec: speed,
          ));
        }
      } finally {
        await sink.close();
      }

      return targetFilePath;
    } finally {
      client.close();
    }
  }
}
