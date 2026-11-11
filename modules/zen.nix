{ inputs, ... }:

{
  flake.modules.homeManager.zen =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      addons = inputs.firefox-addons.packages.${system};

      agentSpooferId = "agent-spoofer@addon";
      aria2cweb = "baptistecdr@users.noreply.github.com";
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
          HardwareAcceleration = true;
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

          # Install and enforce the newer Aria2 Integration extension.
          ExtensionSettings = {
            "${aria2cweb}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/aria2-extension/latest.xpi";
            };

            "${agentSpooferId}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/file/4498171/agent_spoofer-2025.5.21.2.xpi";
            };
          };

          # Configure Aria2 Integration through Firefox enterprise policies.
          "3rdparty" = {
            Extensions = {
              "${aria2cweb}" = {
                servers = [
                  {
                    uuid = "0b6a1f9e-3c2d-4e5f-8a9b-1c2d3e4f5a6b";
                    name = "Local aria2";
                    host = "127.0.0.1";
                    port = 6800;
                    path = "/jsonrpc";
                    secure = false;
                  }
                ];

                captureServer = "0b6a1f9e-3c2d-4e5f-8a9b-1c2d3e4f5a6b";
                captureDownloads = true;

                excludedProtocols = [
                  "blob"
                  "data"
                  "about"
                  "file"
                  "moz-extension"
                ];

                notifyErrorOccurs = true;
              };
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
            "${aria2cweb}"
            "${agentSpooferId}"
          ];
        };
      };
    };
}
