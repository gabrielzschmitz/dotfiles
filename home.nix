{
  config,
  pkgs,
  zen-browser,
  ...
}:

let
  # St
  st = import ./st.nix { inherit pkgs; };
  # Font
  sfMonoNerdFont = pkgs.runCommand "sfmono-nerd-font" { } ''
    mkdir -p $out/share/fonts/opentype/SFMonoNerdFont
    cp ${./fonts/SFMonoNerdFont}/*.otf \
      $out/share/fonts/opentype/SFMonoNerdFont/
  '';
in
{
  home.username = "gabrielzschmitz";
  home.homeDirectory = "/home/gabrielzschmitz";

  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    # Font
    sfMonoNerdFont

    # Browser
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Window manager / terminal
    dmenu
    st

    # Development
    neovim
    go
    python3
    nodejs
    yarn
    gcc
    gnumake
    bear
    git
    gnupg
    pinentry-gnome3
    fd
    fzf
    jq
    btop
    tree-sitter
    lazygit

    # Formatters / linters
    nixd
    nixfmt
    clang-tools
    gofumpt
    gotools
    golangci-lint
    ruff
    stylua
    prettier

    # Documents
    zathura

    # File manager
    thunar

    # Cloud
    nextcloud-client

    # LaTeX
    (texliveSmall.withPackages (
      ps: with ps; [
        latexmk
      ]
    ))

    # Command-line utilities
    fastfetch
    imagemagick
    xclip
    tree
    unzip
    zip
    wget
    curl
    bat
    ripgrep
  ];

  # FONTS
  fonts.fontconfig.enable = true;

  fonts.fontconfig.defaultFonts = {
    serif = [ "SF Mono" ];
    sansSerif = [ "SF Mono" ];
    monospace = [ "SF Mono" ];
  };

  # GPG
  programs.gpg = {
    enable = true;

    settings = {
      use-agent = true;
    };

    scdaemonSettings = {
      disable-ccid = true;
    };
  };

  services.gpg-agent = {
    enable = true;

    pinentry.package = pkgs.pinentry-gnome3;

    defaultCacheTtl = 3600;
    maxCacheTtl = 7200;
  };

  services.ssh-agent = {
    enable = true;
  };

  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    settings = {
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/github_ed25519";
        IdentitiesOnly = true;
      };
    };
  };

  # Git
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "gabrielzschmitz";
        email = "gabrielzschmitz@protonmail.com";
        signingkey = "F0E934F98F9A8371";
      };

      commit.gpgsign = true;
      tag.gpgSign = true;

      gpg.format = "openpgp";
    };
  };

  # Neovim
  home.file.".config/nvim/init.lua".source = ./nvim/init.lua;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Fish
  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "bass";
        src = pkgs.fetchFromGitHub {
          owner = "edc";
          repo = "bass";
          rev = "79b62958ecf4e87334f24d6743e5766475bcf4d0";
          hash = "sha256-3d/qL+hovNA4VMWZ0n1L+dSM1lcz7P5CQJyy+/8exTc=";
        };
      }
    ];

    shellAliases = {
      ll = "ls -lah";
      ".." = "cd ..";
      rebuild = "sudo nixos-rebuild switch --flake '$HOME/.dotfiles#nixos'";
      reswitch = "sudo nixos-rebuild switch --flake '$HOME/.dotfiles#nixos'";
      reclean = "sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +1 && sudo nix-collect-garbage -d";
    };

    interactiveShellInit = ''
      if test -z "$SSH_AUTH_SOCK"; and test -S "/run/user/"(id -u)"/ssh-agent"
        set -gx SSH_AUTH_SOCK "/run/user/"(id -u)"/ssh-agent"
      end

      set -gx EDITOR nvim
      set -gx VISUAL nvim
      set -gx MPD_HOST "$HOME/.config/mpd/socket"
      fish_add_path "$HOME/.local/bin"

      set -g fish_key_bindings fish_vi_key_bindings
      set -g fish_cursor_default block
      set -g fish_cursor_insert line
      set -g fish_cursor_replace_one underscore
      set -g fish_cursor_visual block
    '';

    functions = {
      fish_prompt = ''
        switch $fish_bind_mode
          case default
            set_color --bold cyan
            echo -n '[N]'

          case insert
            set_color --bold magenta
            echo -n '[I]'

          case replace replace_one
            set_color --bold red
            echo -n '[R]'

          case visual
            set_color --bold yellow
            echo -n '[V]'

          case '*'
            set_color --bold cyan
            echo -n '[?]'
        end

        set_color normal
        echo -n ' '

        set_color --bold cyan
        echo -n $PWD
        set_color normal

        echo
        echo -n '❯ '
      '';

      # Disable Fish's built-in mode indicator.
      fish_mode_prompt = "";

      fish_greeting = ''
        fastfetch
      '';

      emsdk = ''
        bass source /usr/lib/emsdk/emsdk_env.sh ';'
      '';
    };
  };

  # SPICE clipboard agent
  systemd.user.services.spice-vdagent = {
    Unit = {
      Description = "SPICE guest clipboard agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "forking";
      ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent -d";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        type = "small";
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

  # Home Manager
  programs.home-manager.enable = true;
}
