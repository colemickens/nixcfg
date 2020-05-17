{
  enable = true;
  config = {
    video-sync = "display-resample";
    hwdec = "vaapi";
    vo = "gpu";
    hwdec-codecs = "all";
    gpu-context = "wayland";
  };
}
