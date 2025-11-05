{
  description = "NixOS module for changing the LED color on Framework laptops";

  outputs =
    { self }:
    {
      nixosModules.default = import self;
    };
}
