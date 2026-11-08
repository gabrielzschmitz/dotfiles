{
  flake.modules.nixos.audio = {
    # Audio
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    environment.sessionVariables.PULSE_COOKIE = "$XDG_DATA_HOME/pulse/cookie";
  };
}
