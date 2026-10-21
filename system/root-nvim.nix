{
  environment.etc."root-nvim-init.lua".source = ../configs/nvim/init.lua;

  system.activationScripts.rootNeovimConfig = {
    text = ''
      mkdir -p /root/.config/nvim
      ln -sfn /etc/root-nvim-init.lua /root/.config/nvim/init.lua
    '';
  };
}
