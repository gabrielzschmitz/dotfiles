{ ... }:

{
  flake.modules.homeManager.git = { pkgs, ... }: {
    # Git LFS
    home.packages = [
      pkgs.git-lfs
    ];

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

        # Git LFS filters
        filter.lfs = {
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
          required = true;
        };
      };
    };
  };
}
