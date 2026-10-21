{
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
}
