using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Timers;
using Avalonia.Controls;
using Avalonia.Threading;

public class PowerSourceDetection
{
    private readonly List<string> _possiblePowerSupplyPaths;
    private readonly Timer _powerSourceCheckTimer;
    private readonly ToggleSwitch _powerToggleSwitch;

    public PowerSourceDetection(ToggleSwitch powerToggleSwitch)
    {
        _powerToggleSwitch = powerToggleSwitch;

        // Common paths for power supply status on Linux systems
        _possiblePowerSupplyPaths = new List<string>
        {
            "/sys/class/power_supply/AC/online",
            "/sys/class/power_supply/ACAD/online",
            "/sys/class/power_supply/ADP1/online",
            "/sys/class/power_supply/AC0/online"
        };

        // Initialize and start the timer to check power source every 5 seconds
        _powerSourceCheckTimer = new Timer(5000);
        _powerSourceCheckTimer.Elapsed += OnTimerElapsed;
        _powerSourceCheckTimer.AutoReset = true;
        _powerSourceCheckTimer.Start();

        // Initial check of power source
        UpdatePowerSourceStatus();
    }

    private void OnTimerElapsed(object sender, ElapsedEventArgs e)
    {
        UpdatePowerSourceStatus();
    }

    private void UpdatePowerSourceStatus()
    {
        var isPluggedIn = IsLaptopPluggedIn();

        // Update UI on UI thread
        Dispatcher.UIThread.InvokeAsync(() => { _powerToggleSwitch.IsChecked = isPluggedIn; });
    }

    private bool IsLaptopPluggedIn()
    {
        try
        {
            // Try each possible path for power supply status
            foreach (var path in _possiblePowerSupplyPaths)
                if (File.Exists(path))
                {
                    var status = File.ReadAllText(path).Trim();
                    return status == "1";
                }

            // If no power supply file is found, try to check using UPower command-line tool
            return CheckUsingUPower();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error checking power status: {ex.Message}");
            return false;
        }
    }

    private bool CheckUsingUPower()
    {
        try
        {
            using (var process = new Process())
            {
                process.StartInfo.FileName = "upower";
                process.StartInfo.Arguments = "-i /org/freedesktop/UPower/devices/line_power_AC";
                process.StartInfo.UseShellExecute = false;
                process.StartInfo.RedirectStandardOutput = true;
                process.StartInfo.CreateNoWindow = true;

                process.Start();
                var output = process.StandardOutput.ReadToEnd();
                process.WaitForExit();

                // Check if the output contains the online status
                if (output.Contains("online:") && output.Contains("yes")) return true;
            }
        }
        catch
        {
            // UPower command failed, try alternative method
            return CheckUsingLsAcpi();
        }

        return false;
    }

    private bool CheckUsingLsAcpi()
    {
        try
        {
            using (var process = new Process())
            {
                process.StartInfo.FileName = "acpi";
                process.StartInfo.Arguments = "-a";
                process.StartInfo.UseShellExecute = false;
                process.StartInfo.RedirectStandardOutput = true;
                process.StartInfo.CreateNoWindow = true;

                process.Start();
                var output = process.StandardOutput.ReadToEnd();
                process.WaitForExit();

                // Check if the output indicates AC adapter is on-line
                return output.Contains("on-line");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error checking ACPI power status: {ex.Message}");
            return false;
        }
    }
}