{ ... }:

{
  flake.modules.nixos.tailscale =
    { config, ... }:
    {
      # Enable Tailscale at startup
      services.tailscale = {
        enable = true;
      };

      # Allow traffic from the Tailscale network
      networking.firewall = {
        trustedInterfaces = [
          config.services.tailscale.interfaceName
        ];

        # Allow direct WireGuard connections
        allowedUDPPorts = [
          config.services.tailscale.port
        ];
      };
    };
}
