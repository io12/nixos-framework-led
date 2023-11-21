{ config, lib, pkgs }:

let
  cfg = config.services.framework-led;

  somethingEnabled = cfg.default.setOnBoot || cfg.fprint.enable
    || cfg.shell.enableBash || cfg.shell.enableZsh;

  shellLed = color: "${config.security.wrapperDir}/framework-led ${color}";

  shellBlink = color: ''
    ${shellLed color}
    ${lib.optionalString (!(builtins.isNull cfg.shell.flashDuration)) ''
      sleep ${lib.strings.floatToString (cfg.shell.flashDuration)}
      ${shellLed cfg.default.color}
    ''}
  '';

  shellInitCommon = ''
    precmd() {
      if [ $? -eq 0 ]; then
        ((${shellBlink cfg.shell.successColor}) &)
      else
        ((${shellBlink cfg.shell.failColor}) &)
      fi
    }
    trap '${shellLed cfg.default.color}' EXIT
  '';

in lib.mkMerge [

  # Normally ectool requires root.
  # Create a setuid wrapper so other users can use it.
  (lib.mkIf somethingEnabled {
    security.wrappers.framework-led = {
      setuid = true;
      owner = "root";
      group = "root";
      source = pkgs.writeScript "framework-led" ''
        #!${pkgs.bash}/bin/bash -p
        # Ensure argument is nonempty to avoid segfault
        [ -n "$1" ] && ${pkgs.fw-ectool}/bin/ectool led power "$1"
      '';
    };
  })

  (lib.mkIf cfg.shell.enableBash {
    programs.bash.interactiveShellInit = ''
      ${shellInitCommon}
      PROMPT_COMMAND=precmd
    '';
  })

  (lib.mkIf cfg.shell.enableZsh {
    programs.zsh.interactiveShellInit = shellInitCommon;
  })

  (lib.mkIf cfg.default.setOnBoot {
    systemd.services.framework-led-boot-default = {
      wantedBy = [ "multi-user.target" ];
      description = "Set default Framework power LED color on boot";
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = shellLed cfg.default.color;
      };
    };
  })

  (lib.mkIf cfg.fprint.enable {
    systemd.services.framework-led-fprint = {
      wantedBy = [ "fprintd.service" ];
      description = "Change Framework power LED during fprintd events";
      serviceConfig = {
        User = cfg.user;
        ExecStart =
          import ./fprint-script.nix { inherit pkgs lib cfg shellLed; };
      };
    };
  })

]
