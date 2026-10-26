using Avalonia;
using System;
using SkiaSharp;
using Avalonia.Skia;
using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Skia;
using SkiaSharp;
using Avalonia.Controls;
using Avalonia.Controls.ApplicationLifetimes;


namespace DivAcerManagerMax;

class Program
{
    // Initialization code. Don't use any Avalonia, third-party APIs or any
    // SynchronizationContext-reliant code before AppMain is called: things aren't initialized
    // yet, and stuff might break.
    [STAThread]
    public static void Main(string[] args) => BuildAvaloniaApp()
        .StartWithClassicDesktopLifetime(args);

    
     
    // Avalonia configuration, don't remove; also used by visual designer.
    public static AppBuilder BuildAvaloniaApp()
        => AppBuilder.Configure<App>()
            .UsePlatformDetect()
            .WithInterFont()
            .LogToTrace();
        
    
    
}
