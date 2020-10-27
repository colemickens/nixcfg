let
  az = inputs.nixos-azure.nixosModules.azure-arm;

  imageName = "imageName";
  imageFile = "/path/to/file.img"; # this could even be dynamic
  location = "westus2";

  # imgStorage holds my devenv golden img
  imgGroup = az.mkGroupTemplate {
      resources = [
        az.mkStorageAccount {}
      ];
      postDeployScripts = [
        az.scripts.upload-image {
          name = imageName;
          group = imgGroup;
          file = imageFile;
        }
      ];
  };
  imgDeploy = az.mkGroupTemplate {
    resources = [
      az.mkImage {}
    ];
  };
  # cacheStorage holds my Nix cache blob storage
  cacheStorage = az.mkGroupTemplate {
    resources = [
      az.mkStorageAccount {}
    ];
  };
  # dataStorage holds my VM persistent data
  dataStorage = az.mkGroupTemplate {
    resources = [
      az.mkDisk {}
    ];
  };

  # build my dev env from the pieces
  devenvMachine = az.mkGroupTemplate {
    resources = [
      az.mkComputeVirtualMachine {
        size = "Standard_D64s";
        location = location;
        dataDisks = [
          "dataDisk/${diskName}"
        ];
      }
    ];
  };
in
  pkgs.writeFiles {
    "prepare.sh" =
      az.runSteps [
        { steps = [ imgGroup imgDeploy ]; }
        { steps = [ cacheStorage ]; }
        { steps = [ dataStorage ]; }
      ];

    "deploy-vm.sh" =
      az.runSteps [
        { steps = [ devenvMachine ]; }
      ];
  }