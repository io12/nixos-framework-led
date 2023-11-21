{ config, lib, pkgs, ... }:

{
  options = import ./options.nix { inherit lib; };
  config = import ./config.nix { inherit config lib pkgs; };
}
