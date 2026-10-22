{ ... }:

{
  flake.modules.nixos.nvim = {
    environment.etc."root-nvim-init.lua".source = ../configs/nvim/init.lua;

    system.activationScripts.rootNeovimConfig = {
      text = ''
        mkdir -p /root/.config/nvim
        ln -sfn /etc/root-nvim-init.lua /root/.config/nvim/init.lua
      '';
    };
  };

  flake.modules.homeManager.nvim = {
    home.file.".config/nvim/init.lua".source = ../configs/nvim/init.lua;

    home.file.".clang-format".source = ../configs/.clang-format;
    home.file.".config/clang-format/config".source = ../configs/.clang-format;
  };
}
