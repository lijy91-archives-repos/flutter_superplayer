/// 使用腾讯云fileId播放
class SuperPlayerVideoId {
  String? fileId; // 腾讯云视频fileId
  String? pSign; // v4 开启防盗链必填

  SuperPlayerVideoId({this.fileId, this.pSign});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonObject = Map<String, dynamic>();
    if (fileId != null) jsonObject.putIfAbsent("fileId", () => fileId);
    if (pSign != null) jsonObject.putIfAbsent("pSign", () => pSign);
    
    return jsonObject;
  }
}
