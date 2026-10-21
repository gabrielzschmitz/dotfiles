{
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        type = "sixel";
        source = "${../../configs/fastfetch/GZS.png}";
        padding = {
          top = 1;
        };
      };

      display = {
        separator = " ";
      };

      modules = [
        {
          key = "╭───────────╮";
          type = "custom";
        }

        {
          key = "│ {#31} user    {#keys}│";
          type = "title";
          format = "{user-name}";
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
          key = "│ {#36}󰇄 desktop {#keys}│";
          type = "de";
        }

        {
          key = "│ {#31} term    {#keys}│";
          type = "terminal";
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
          folders = [ "/home" ];
        }

        {
          key = "│ {#31}󰉉 root    {#keys}│";
          type = "disk";
          folders = [ "/" ];
        }

        {
          key = "│ {#35} memory  {#keys}│";
          type = "memory";
        }

        {
          key = "│ {#36} battery {#keys}│";
          type = "battery";
        }

        {
          key = "├───────────┤";
          type = "custom";
        }

        {
          key = "│ {#39} colors  {#keys}│";
          type = "colors";
          symbol = "circle";
        }

        {
          key = "╰───────────╯";
          type = "custom";
        }
      ];
    };
  };
}
