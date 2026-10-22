{ inputs, ... }:

{
  flake.modules.homeManager.zen =
    { pkgs, ... }:
    let
      addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [ inputs.zen-browser.homeModules.beta ];

      programs.zen-browser = {
        enable = true;

        globalExtensions = with addons; [
          vimium
          nextcloud-passwords
          ublock-origin
          theater-mode-for-youtube
          privacy-badger
          user-agent-string-switcher
        ];

        policies = {
          AutofillAddressEnabled = true;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableFeedbackCommands = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = false;
          EnableTrackingProtection = {
            Value = true;
            Locked = true;
            Cryptomining = true;
            Fingerprinting = true;
          };
          SearchEngines = {
            Default = "DuckDuckGo";
            PreventInstalls = true;
            Remove = [
              "Amazon.com"
              "Baidu"
              "Bing"
              "eBay"
              "Ecosia"
              "Google"
              "Perplexity"
              "Qwant"
              "Wikipedia"
              "Wikipedia (en)"
              "Yahoo"
              "Yandex"
            ];
          };
          Preferences = {
            "zen.view.use-single-toolbar" = {
              Value = false;
              Status = "locked";
            };
            "zen.view.sidebar-expanded" = {
              Value = true;
              Status = "locked";
            };
            "zen.view.compact.enable-at-startup" = {
              Value = false;
              Status = "locked";
            };
          };
        };

        profiles.default = {
          isDefault = true;
          name = "Default Profile";
          path = "hliq7r8h.Default Profile";

          settings = {
            "zen.view.window.scheme" = 0;
            "layout.css.prefers-color-scheme.content-override" = 0;
            "ui.systemUsesDarkTheme" = 1;
          };

          search = {
            force = true;
            default = "ddg";
            privateDefault = "ddg";
            order = [ "ddg" ];
          };

          extensionButtons."nav-bar" = [
            "{d7742d87-e61d-4b78-b8a1-b469842139fa}"
            "ncpasswords@mdns.eu"
            "uBlock0@raymondhill.net"
            "jid1-MnnxcxisBPnSXQ@jetpack"
            "{a6c4a591-f1b2-4f03-b3ff-767e5bedf4e7}"
          ];
        };
      };
    };
}
