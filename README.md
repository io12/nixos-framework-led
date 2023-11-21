# nixos-framework-led

NixOS module for changing the LED color on Framework laptops

## Features

- Set a default LED color to be applied on boot,
  or turn the power LED off on boot
- Make the LED blink a color depending on whether shell commands succeeded or failed
- Make the LED color track the status of the fingerprint reader (by default yellow when scanning for fingerprints, green on success, and red on failure)

## Installation

### Flakes

Example minimal`/etc/nixos/flake.nix`:

``` nix
{
  description = "NixOS configuration";

  inputs = {
    nixos-framework-led.url = "github:io12/nixos-framework-led";
  };

  outputs = { nixpkgs, nixos-framework-led }: {
    nixosConfigurations.my-hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        (import nixos-framework-led)
        {
          services.framework-led = {
            default = {
              color = "off";
              setOnBoot = true;
            };
            fprint.enable = true;
            shell = {
              enableBash = true;
              enableZsh = true;
            };
          };
        }
      ];
    };
  };
}
```

A full list of options can be explored with the `nixos-option services.framework-led` command.

### Channels

Add a `nixos-framework-led` channel with

``` sh
sudo nix-channel --add https://github.com/io12/nixos-framework-led/archive/main.tar.gz nixos-framework-led
sudo nix-channel --update
```

Then make the following modification to `/etc/nixos/configuration.nix`:

``` nix
{ ... }:

{
  imports = [
    (import <nixos-framework-led>)
  ];

  services.framework-led = {
    user = "user";
    default = {
      color = "off";
      setOnBoot = true;
    };
    fprint.enable = true;
    shell = {
      enableBash = true;
      enableZsh = true;
    };
  };
}
```

A full list of options can be explored with the `nixos-option services.framework-led` command.
