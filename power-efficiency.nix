# Advanced power efficiency module with udev-based charging detection
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.kiyurica.power-efficiency;

  # Script to apply power saving settings when on battery
  batteryPowerScript = pkgs.writeShellScript "battery-power" ''
    ${config.boot.kernelPackages.x86_energy_perf_policy}/bin/x86_energy_perf_policy power

    # Disable P-cores (performance cores) on battery
    if [ -f /sys/devices/cpu_core/cpus ]; then
      pcores=$(cat /sys/devices/cpu_core/cpus)
      # Parse CPU list (format: 0-7 or 0,2,4,6 or combination)
      echo "$pcores" | tr ',' '\n' | while read -r range; do
        if echo "$range" | grep -q '-'; then
          start=$(echo "$range" | cut -d'-' -f1)
          end=$(echo "$range" | cut -d'-' -f2)
          for cpu_num in $(seq "$start" "$end"); do
            [ "$cpu_num" = "0" ] && continue  # Keep CPU0 online
            [ -f "/sys/devices/system/cpu/cpu$cpu_num/online" ] && \
              echo 0 > "/sys/devices/system/cpu/cpu$cpu_num/online" 2>/dev/null || true
          done
        else
          [ "$range" = "0" ] && continue  # Keep CPU0 online
          [ -f "/sys/devices/system/cpu/cpu$range/online" ] && \
            echo 0 > "/sys/devices/system/cpu/cpu$range/online" 2>/dev/null || true
        fi
      done
    fi
  '';

  # Script to apply performance settings when on AC power
  acPowerScript = pkgs.writeShellScript "ac-power" ''
    ${config.boot.kernelPackages.x86_energy_perf_policy}/bin/x86_energy_perf_policy performance

    # Re-enable all P-cores when on AC power
    if [ -f /sys/devices/cpu_core/cpus ]; then
      pcores=$(cat /sys/devices/cpu_core/cpus)
      # Parse CPU list (format: 0-7 or 0,2,4,6 or combination)
      echo "$pcores" | tr ',' '\n' | while read -r range; do
        if echo "$range" | grep -q '-'; then
          start=$(echo "$range" | cut -d'-' -f1)
          end=$(echo "$range" | cut -d'-' -f2)
          for cpu_num in $(seq "$start" "$end"); do
            [ -f "/sys/devices/system/cpu/cpu$cpu_num/online" ] && \
              echo 1 > "/sys/devices/system/cpu/cpu$cpu_num/online" 2>/dev/null || true
          done
        else
          [ -f "/sys/devices/system/cpu/cpu$range/online" ] && \
            echo 1 > "/sys/devices/system/cpu/cpu$range/online" 2>/dev/null || true
        fi
      done
    fi
  '';

in
{
  options.kiyurica.power-efficiency = {
    enable = mkEnableOption "automatic power efficiency management";
  };

  config = mkIf cfg.enable {
    # Install required packages
    environment.systemPackages = [
      config.boot.kernelPackages.x86_energy_perf_policy
    ];

    # Create udev rules for power adapter detection
    services.udev.extraRules = ''
      # Power adapter connected/disconnected detection
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="${batteryPowerScript}"
      SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="${acPowerScript}"

      # Alternative rule for ADP1 (common power adapter name)
      KERNEL=="ADP1", ATTR{online}=="0", RUN+="${batteryPowerScript}"
      KERNEL=="ADP1", ATTR{online}=="1", RUN+="${acPowerScript}"
    '';

    # Create systemd service to apply initial power settings
    systemd.services.power-efficiency-init = {
      description = "Initialize power efficiency settings";
      wantedBy = [ "multi-user.target" ];
      after = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "power-efficiency-init" ''
          # Check if we're on battery or AC power
          if [ -f /sys/class/power_supply/ADP1/online ]; then
            if [ "$(cat /sys/class/power_supply/ADP1/online)" = "1" ]; then
              ${acPowerScript}
            else
              ${batteryPowerScript}
            fi
          elif [ -f /sys/class/power_supply/AC/online ]; then
            if [ "$(cat /sys/class/power_supply/AC/online)" = "1" ]; then
              ${acPowerScript}
            else
              ${batteryPowerScript}
            fi
          else
            # Default to battery power settings if adapter state is unknown
            ${batteryPowerScript}
          fi
        '';
      };
    };

    # Ensure CPU frequency scaling is available
    boot.kernelModules = [
      "cpufreq_powersave"
      "cpufreq_performance"
    ];

    # Enable CPU frequency scaling
    powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  };
}
