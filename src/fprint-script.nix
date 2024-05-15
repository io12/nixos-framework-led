{ pkgs, lib, cfg, shellLed }:

let

  name = "framework-led-fprint";

  src = ''
    #!/usr/bin/env python3

    from pydbus import SystemBus
    from gi.repository import GLib
    from os import system
    from time import sleep


    ${if builtins.isNull cfg.fprint.flashDuration then ''
      def off():
          pass
    '' else ''
      def off():
          sleep(${lib.strings.floatToString (cfg.fprint.flashDuration)})
          system("${shellLed cfg.default.color}")
    ''}


    def callback(_, __, ___, signal_name, fields):
        if signal_name == "VerifyFingerSelected":
            system("${shellLed cfg.fprint.scanColor}")
        elif signal_name == "VerifyStatus":
            (result, done) = fields
            if result == "verify-match":
                system("${shellLed cfg.fprint.successColor}")
                off()
            else:
                system("${shellLed cfg.fprint.failColor}")
                if done:
                    off()


    bus = SystemBus()
    bus.subscribe(iface="net.reactivated.Fprint.Device", signal_fired=callback)

    loop = GLib.MainLoop()
    loop.run()
  '';

in pkgs.stdenv.mkDerivation {
  inherit name src;
  passAsFile = [ "src" ];
  nativeBuildInputs = with pkgs; [ gobject-introspection wrapGAppsHook ];
  buildInputs = [ (pkgs.python3.withPackages (ps: with ps; [ pydbus ])) ];
  dontUnpack = true;
  buildPhase = ''
    mkdir -p $out/bin
    mv $srcPath $out/bin/$name
    chmod +x $out/bin/$name
  '';
  meta.mainProgram = name;
}
