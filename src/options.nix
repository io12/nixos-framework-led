{ lib }:

let
  mkColorOption = default: description:
    lib.mkOption {
      inherit default description;
      type = lib.types.enum [ "off" "red" "green" "yellow" "white" "amber" ];
    };

  mkFlashDurationOption = default: description:
    lib.mkOption {
      inherit default description;
      type = lib.types.nullOr lib.types.float;
    };

in {
  services.framework-led = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = "User to run the systemd services";
    };

    default = {
      color = mkColorOption "white" "The default color of the power LED";
      setOnBoot =
        lib.mkEnableOption "Set Framework LED color to default on boot";
    };

    fprint = {
      enable =
        lib.mkEnableOption "Change Framework LED color to fprintd status";

      flashDuration = mkFlashDurationOption 0.3
        "Duration of power LED flash when fprintd succeeds or fails, or null for the new color to persist";

      scanColor = mkColorOption "yellow"
        "Color of the power LED when scanning for fingerprints with fprintd";

      successColor = mkColorOption "green"
        "Color of the power LED when fingerprint verification succeeds";

      failColor = mkColorOption "red"
        "Color of the power LED when fingerprint verification fails";
    };

    shell = {
      enableBash = lib.mkEnableOption
        "Set Framework LED color to last Bash command status";

      enableZsh =
        lib.mkEnableOption "Set Framework LED color to last Zsh command status";

      flashDuration = mkFlashDurationOption 5.0e-2
        "Duration of power LED flash when shell command succeeds or fails, or null for the new color to persist";

      successColor = mkColorOption "green"
        "Color of the power LED when shell command succeeds";

      failColor =
        mkColorOption "red" "Color of the power LED when shell command fails";
    };
  };
}
