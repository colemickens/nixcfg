{ inputs, system, ... }:

let
  pkgs = import inputs.nixpkgs {
    config.allowUnfree = true;
    system = system;
    overlays = [
      (final: prev: {
        python3 = prev.python3.override {
          packageOverrides = python-self: python-super: {
            pytorch = python-super.pytorch.override { cudaSupport= true; };
          };
        };
      })
    ];
  };
  inherit (pkgs) lib;

  python = pkgs.python3;
  ps = python.pkgs;
in
pkgs.mkShell {
  packages = [
    pkgs.cudatoolkit
    python

    # From conda-forge
    ps.pytorch
    ps.torchvision
    ps.numpy

    # Pip
    ps.opencv4
    ps.pudb
    ps.imageio
    ps.imageio-ffmpeg
    ps.pytorch-lightning
    ps.omegaconf
    ps.test-tube
    ps.einops
    ps.transformers
    ps.torchmetrics
    ps.pynvml

    # Missing from nixpkgs:
    # - streamlit>=0.73.1
    # - albumentations==0.4.3
    # - torch-fidelity==0.3.0
    # - kornia==0.6
    # - -e git+https://github.com/CompVis/taming-transformers.git@master#egg=taming-transformers
    # - -e git+https://github.com/openai/CLIP.git@main#egg=clip
    # - -e .
  ];

  LD_LIBRARY_PATH = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc
  ];

  shellHook = ''
    python3 -m venv venv
    . venv/bin/activate

    pip install \
      "streamlit>=0.73.1" \
      "albumentations==0.4.3" \
      "torch-fidelity==0.3.0" \
      "kornia==0.6" \
      "imwatermark" \
      "gradio==3.3.1" \
      -e "git+https://github.com/CompVis/taming-transformers.git@master#egg=taming-transformers" \
      -e "git+https://github.com/crowsonkb/k-diffusion#egg=k_diffusion" \
      -e .
  '';
}
