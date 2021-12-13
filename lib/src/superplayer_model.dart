import './superplayer_video_id.dart';
import './superplayer_video_id_v2.dart';

class SuperPlayerModel {
  /// AppId 用于腾讯云点播 File ID 播放及腾讯云直播时移功能
  int? appId;

  /// 直接使用URL播放
  /// <p>
  /// 支持 RTMP、FLV、MP4、HLS 封装格式
  /// 使用腾讯云直播时移功能则需要填写appId
  String? url = ""; // 视频URL

  /// 多码率视频 URL
  /// <p>
  /// 用于拥有多个播放地址的多清晰度视频播放
  List<SuperPlayerURL>? multiURLs;

  /// 指定多码率情况下，默认播放的连接Index
  int? playDefaultIndex;

  /// 腾讯云点播 File ID 播放参数
  SuperPlayerVideoId? videoId;

  /// 用于兼容旧版本(V2)腾讯云点播 File ID 播放参数（即将废弃，不推荐使用）
  @deprecated
  SuperPlayerVideoIdV2? videoIdV2;

  /// 用户设置的封面图片
  String? coverPictureUrl = "";

  SuperPlayerModel({
    this.appId,
    this.url,
    this.multiURLs,
    this.playDefaultIndex,
    this.videoId,
    this.videoIdV2,
    this.coverPictureUrl,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonObject = Map<String, dynamic>();
    if (appId != null) jsonObject.putIfAbsent("appId", () => appId);
    if (url != null) jsonObject.putIfAbsent("url", () => url);
    if (multiURLs != null)
      jsonObject.putIfAbsent(
        "multiURLs",
        () => multiURLs!.map((e) => e.toJson()).toList(),
      );
    if (playDefaultIndex != null)
      jsonObject.putIfAbsent("playDefaultIndex", () => playDefaultIndex);
    if (videoId != null)
      jsonObject.putIfAbsent("videoId", () => videoId!.toJson());
    if (videoIdV2 != null)
      jsonObject.putIfAbsent("videoIdV2", () => videoIdV2!.toJson());
    if (coverPictureUrl != null)
      jsonObject.putIfAbsent("coverPictureUrl", () => coverPictureUrl);

    return jsonObject;
  }
}

class SuperPlayerURL {
  /// 清晰度名称（用于显示在UI层）
  String? qualityName = "原画";

  /// 该清晰度对应的地址
  String? url = "";

  SuperPlayerURL({this.url, this.qualityName});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonObject = Map<String, dynamic>();
    if (qualityName != null)
      jsonObject.putIfAbsent("qualityName", () => qualityName);
    if (url != null) jsonObject.putIfAbsent("url", () => url);

    return jsonObject;
  }
}
