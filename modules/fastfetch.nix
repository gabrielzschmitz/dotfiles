{ ... }:

{
  flake.modules.homeManager.fastfetch = {
    programs.fastfetch = {
      enable = true;

      settings = {
        logo = {
          # kitty-direct sends only the file path, so st decodes and scales the
          # image. GZS-220.png is pre-rendered at the exact display size
          # (22 x 11 cells, 10x20 px cells -> 220x220 px), so st skips scaling.
          # Rebuild after editing GZS.svg:
          #   inkscape GZS.svg --export-width=880 --export-height=880 \
          #     --export-type=png --export-filename=/tmp/GZS-880.png
          #   magick /tmp/GZS-880.png -filter Lanczos -resize 220x220 -strip \
          #     -colors 256 -define png:compression-level=9 PNG8:GZS-220.png
          type = "kitty-direct";
          source = "${../configs/fastfetch/GZS.png}";
          width = 22;
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
            key = "┌──────────┐";
            type = "custom";
          }

          {
            key = "│ {#32}󰇅 hname  {#keys}│";
            type = "title";
            format = "{host-name}";
          }

          {
            key = "│ {#33}󰅐 uptime {#keys}│";
            type = "uptime";
          }

          {
            key = "│ {#35} kernel {#keys}│";
            type = "kernel";
          }

          {
            key = "│ {#32} shell  {#keys}│";
            type = "shell";
          }

          {
            key = "│ {#33}󰍛 cpu    {#keys}│";
            type = "cpu";
            format = "{name}";
          }

          {
            key = "│ {#34}󰉉 home   {#keys}│";
            type = "disk";
            format = "{size-used}/{size-total} ({size-percentage}) - {filesystem}";
            folders = [ "/home" ];
          }

          {
            key = "│ {#31}󰉉 root   {#keys}│";
            type = "disk";
            format = "{size-used}/{size-total} ({size-percentage}) - {filesystem}";
            folders = [ "/" ];
          }

          {
            key = "│ {#35} memory {#keys}│";
            type = "memory";
            format = "{used}/{total} ({percentage})";
          }

          {
            key = "│ {#39} colors {#keys}│";
            type = "colors";
            symbol = "circle";
          }

          {
            key = "└──────────┘";
            type = "custom";
          }
        ];
      };
    };
  };
}
