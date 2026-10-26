using System.Linq;
using Avalonia;
using Avalonia.Controls.ApplicationLifetimes;
using Avalonia.Markup.Xaml;
using Avalonia.Media;
using Avalonia.Themes.Fluent;

namespace DivAcerManagerMax;

public class App : Application
{
    public override void Initialize()
    {
        AvaloniaXamlLoader.Load(this);

        var accentColor = Color.Parse("#1B89D8");
        Application.Current.Resources["SystemAccentColor"] = accentColor;
        Application.Current.Resources["SystemAccentBrush"] = new SolidColorBrush(accentColor);

    }

    public override void OnFrameworkInitializationCompleted()
    {
        if (ApplicationLifetime is IClassicDesktopStyleApplicationLifetime desktop)
            desktop.MainWindow = new MainWindow();


        base.OnFrameworkInitializationCompleted();
    }
}