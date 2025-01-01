{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Boot configuration
  boot = {
    loader= {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
    };
  };

# Networking
  networking = {
    hostName = "vics-pi";
    firewall.enable = true;
    nameservers = [ "1.1.1.1" ];
    wireless = {
      enable = true;
      networks = {
        "Airnet" = {
          psk = "over9000";
        };
      };
    };
  };

  # Networking configuration
  # networking = {
  #   hostName = "vics-pi";
  #   interfaces.enu1u1u1 = {
  #     ipv4.addresses = [{
  #       address = "192.168.0.11";
  #       prefixLength = 24;
  #     }];
  #   };
  #   defaultGateway = {
  #     address = "192.168.0.1";
  #     interface = "enu1u1u1";
  #   };
  #   nameservers = [ "1.1.1.1" ];
  #   firewall.enable = true;

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
  nix.gc = {
    automatic = true;
    dates = "Tue 03:30";
    options = "--delete-older-than +7";
    persistent = true;
  };

  # Modules and services
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

  services = {
    openssh.enable = true;
    technitium-dns-server = {
      enable = true;
      openFirewall = true;
    };
    zoneminder = {
      enable = true;
      port = 8095;
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

  systemd.tmpfiles.rules = [
    "d /srv/security_cam 0755 zoneminder nginx -"
    "d /srv/security_cam/events 0755 zoneminder nginx -"
    "d /srv/security_cam/exports 0755 zoneminder nginx -"
    "d /srv/security_cam/images 0755 zoneminder nginx -"
    "d /srv/security_cam/sounds 0755 zoneminder nginx -"
  ];

  virtualisation.docker.enable = true;

  # Environment and packages
  nixpkgs.config.allowUnfree = true;
  environment = {
    systemPackages = with pkgs; [
      git
      wireguard-tools
    ];
  };

  # User configuration
  users.users = {
    justin = {
      isNormalUser = true;
      description = "Justin";
      extraGroups = [ "wheel" ];
      password = "password";
    };
  };
}
