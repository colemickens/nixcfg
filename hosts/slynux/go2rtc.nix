{ pkgs, inputs, ... }:

{
  config = {
    services.go2rtc = {
      enable = true;
      settings = {
        # api/webui = :1984
        streams = {
          webcam = "ffmpeg:device?video=/dev/video0&input_format=yuyv422&video_size=1920x1080#video=h264#hardware";
        };
      };
    };
  };
}
