{ pkgs, lib, cfg, shellLed }:

pkgs.writeScript "framework-led-fprint" ''
  #!${pkgs.python3.withPackages (ps: with ps; [ pydbus ])}/bin/python3

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
''
