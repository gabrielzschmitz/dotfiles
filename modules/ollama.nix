{ ... }:

{
  flake.modules.nixos.ollama =
    { pkgs, lib, ... }:
    {
      services.ollama = {
        enable = true;
        # NVIDIA GPU on this machine; use CUDA package.
        package = pkgs.ollama-cuda;
        environmentVariables = {
          OLLAMA_MODELS = lib.mkForce "/home/gabrielzschmitz/.local/share/ollama/models";
        };
      };

      # Force model path at systemd level (module may override service env).
      systemd.services.ollama.environment.OLLAMA_MODELS = lib.mkForce "/home/gabrielzschmitz/.local/share/ollama/models";
      # Allow ollama service user to access models stored in user XDG data dir.
      systemd.services.ollama.serviceConfig = {
        ReadWritePaths = [ "/home/gabrielzschmitz/.local/share/ollama" ];
        ProtectHome = lib.mkForce false;
      };
      system.activationScripts.ollama-models-perms.text = ''
        chmod a+x /home/gabrielzschmitz /home/gabrielzschmitz/.local /home/gabrielzschmitz/.local/share /home/gabrielzschmitz/.local/share/ollama || true
        chmod -R a+rX /home/gabrielzschmitz/.local/share/ollama || true
      '';

      environment.systemPackages = [ pkgs.ollama-cuda ];
    };
}
