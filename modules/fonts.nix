{ ... }:

{
  flake.modules.homeManager.fonts =
    { pkgs, ... }:
    {
      # FONTS
      home.packages = [
        pkgs.sfmono-nerd-font
      ];

      fonts.fontconfig.enable = true;

      fonts.fontconfig.defaultFonts = {
        serif = [ "SF Mono" ];
        sansSerif = [ "SF Mono" ];
        monospace = [ "SF Mono" ];
      };
    };
}
