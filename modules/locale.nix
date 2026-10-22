{ ... }:

{
  flake.modules.nixos.locale = {
    time.timeZone = "America/Sao_Paulo";
    i18n.defaultLocale = "en_US.UTF-8";
  };
}
