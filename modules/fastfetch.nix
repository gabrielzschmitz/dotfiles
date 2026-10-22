{ ... }:

{
  flake.modules.homeManager.fastfetch = {
    programs.fastfetch = {
      enable = true;

      settings = {
        logo = {
          type = "kitty";
          source = "${../configs/fastfetch/GZS.png}";
          width = 21;
          height = 11;
          padding = {
            top = 0;
            right = 0;
          };
        };

        display = {
          separator = " ";
        };

        modules = [
          {
            key = "┌───────────┐";
            type = "custom";
          }

          {
            key = "│ {#32}󰇅 hname   {#keys}│";
            type = "title";
            format = "{host-name}";
          }

          {
            key = "│ {#33}󰅐 uptime  {#keys}│";
            type = "uptime";
          }

          {
            key = "│ {#35} kernel  {#keys}│";
            type = "kernel";
          }

          {
            key = "│ {#32} shell   {#keys}│";
            type = "shell";
          }

          {
            key = "│ {#33}󰍛 cpu     {#keys}│";
            type = "cpu";
            format = "{name}";
          }

          {
            key = "│ {#34}󰉉 home    {#keys}│";
            type = "disk";
            format = "{size-used}/{size-total} ({size-percentage}) - {filesystem}";
            folders = [ "/home" ];
          }

          {
            key = "│ {#31}󰉉 root    {#keys}│";
            type = "disk";
            format = "{size-used}/{size-total} ({size-percentage}) - {filesystem}";
            folders = [ "/" ];
          }

          {
            key = "│ {#35} memory  {#keys}│";
            type = "memory";
            format = "{used}/{total} ({percentage})";
          }

          {
            key = "│ {#36} battery {#keys}│";
            type = "battery";
          }

          {
            key = "│ {#39} colors  {#keys}│";
            type = "colors";
            symbol = "circle";
          }

          {
            key = "└───────────┘";
            type = "custom";
          }
        ];
      };
    };
  };
}
