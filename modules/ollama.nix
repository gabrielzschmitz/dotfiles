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
          # OpenCode sends a ~8k-token system prompt plus tool schemas. The
          # default 4096 context truncates it, so the model never sees the tool
          # definitions and answers in prose instead of calling tools.
          OLLAMA_CONTEXT_LENGTH = "65536";

          # Avoid multiplying KV-cache memory usage.
          OLLAMA_NUM_PARALLEL = "1";
          # Keep only one model loaded at a time.
          OLLAMA_MAX_LOADED_MODELS = "1";
          # Quantized KV cache
          OLLAMA_KV_CACHE_TYPE = "q8_0";
        };
        loadModels = [
          "gemma4:12b"
          "mimo-v2.6:9b"
          "qwen3.5:9b"
        ];
      };

      # Force model path at systemd level (module may override service env).
      systemd.services.ollama.environment.OLLAMA_MODELS =
        lib.mkForce "/home/gabrielzschmitz/.local/share/ollama/models";
      # Allow ollama service user to access models stored in user XDG data dir.
      systemd.services.ollama.serviceConfig = {
        ReadWritePaths = [ "/home/gabrielzschmitz/.local/share/ollama" ];
        ProtectHome = lib.mkForce false;
      };
      system.activationScripts.ollama-models-perms.text = ''
        chmod a+x /home/gabrielzschmitz /home/gabrielzschmitz/.local /home/gabrielzschmitz/.local/share /home/gabrielzschmitz/.local/share/ollama || true
        chmod -R a+rwX /home/gabrielzschmitz/.local/share/ollama || true
      '';

      environment.systemPackages = [ pkgs.ollama-cuda ];
    };
}
