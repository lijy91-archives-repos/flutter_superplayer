class SuperPlayerVideoIdV2 {
  String fileId; // 腾讯云视频fileId
  String timeout; // 【可选】加密链接超时时间戳，转换为16进制小写字符串，腾讯云 CDN 服务器会根据该时间判断该链接是否有效。
  String us; // 【可选】唯一标识请求，增加链接唯一性
  String sign; // 【可选】防盗链签名

  int exper = -1; // 【V2可选】试看时长，单位：秒。可选

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonObject = Map<String, dynamic>();
    if (fileId != null) jsonObject.putIfAbsent("fileId", () => fileId);
    if (timeout != null) jsonObject.putIfAbsent("timeout", () => timeout);
    if (us != null) jsonObject.putIfAbsent("us", () => us);
    if (sign != null) jsonObject.putIfAbsent("sign", () => sign);
    if (exper != null) jsonObject.putIfAbsent("exper", () => exper);
    
    return jsonObject;
  }
}
