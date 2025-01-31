{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Boot configuration
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
    };
  };

  ########### NETWORKING ###########

  # disable bluetooth
  hardware.bluetooth.enable = false;

  # host settings
  networking = {
    hostName = "vics-pi";
    nameservers = [ "1.1.1.1" ];
    firewall.enable = true;
  };

  # ethernet nic settings
  networking.interfaces.enu1u1u1.useDHCP = true;
  
  # wifi nic settings
  networking = {
    wireless = {
      enable = true;
      networks = {
        "Airnet" = {
          psk = "over9000";
        };
      };
    };
  };

  ##################################

  # Time and locale settings
  time.timeZone = "US/Eastern";
  i18n.defaultLocale = "en_US.UTF-8";

  # Maintenance automation
  system = {
    autoUpgrade = {
      enable = true;
      dates = "Tue 03:00";
      persistent = true;
      allowReboot = true;
    };
    stateVersion = "24.11";
  };
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "Tue 03:00";
      options = "--delete-older-than +7";
      persistent = true;
    };
  };

  # swap
  zramSwap = {
    enable = true;
    memoryPercent = 25;
    priority = 5;
  };
   swapDevices = [ {
    device = "/swapfile";
    size = 4*1024;
    priority = 1;
  } ];

  # zoneminder and ssh services
  services = {
    openssh.enable = true;
    zoneminder = {
      enable = true;
      port = 443;
      storageDir = "/srv/security_cam";
      openFirewall = true;
      cameras = 2;
      database = {
        createLocally = true;
        name = "zm";
        username = "zoneminder";
        password = "zmpass";
        host = "localhost";
      };
    };
  };

  # create zoneminder required directories
  systemd.tmpfiles.rules = [
    "d /srv/security_cam 0755 zoneminder nginx -"
    "d /srv/security_cam/events 0755 zoneminder nginx -"
    "d /srv/security_cam/exports 0755 zoneminder nginx -"
    "d /srv/security_cam/images 0755 zoneminder nginx -"
    "d /srv/security_cam/sounds 0755 zoneminder nginx -"
  ];

  # Environment and packages
  nixpkgs.config.allowUnfree = true;
  environment = {
    systemPackages = with pkgs; [
      git
    ];
  };

  # User configuration
  users.users = {
    vic = {
      isNormalUser = true;
      description = "Vic";
      extraGroups = [ "wheel" ];
      password = "password";
    };
  };
}
