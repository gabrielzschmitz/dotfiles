<h1 data-loc-id="walkthrough.linux.title.run.and.debug.your.file">C++-Datei auf Linux ausführen und debuggen</h1>
<p data-loc-id="walkthrough.linux.run.and.debug.your.file">Zum Ausführen und Debuggen Ihrer C++-Datei in VS-Code tun Sie Folgendes:</p>
<ol>
<li><p data-loc-id="walkthrough.linux.instructions1">Öffnen Sie die C++-Quelldatei, die Sie ausführen und debuggen möchten. Stellen Sie sicher, dass diese Datei im Editor aktiv ist, d.&nbsp;h. aktuell angezeigt wird und ausgewählt ist.</p>
</li>
<li><p data-loc-id="walkthrough.linux.press.f5">Drücken Sie <code>F5</code>, oder wählen Sie im Hauptmenü <strong><span data-loc-id="walkthrough.linux.run" data-loc-hint="Refers to Run command on main menu">Ausführen</span> &gt; <span data-loc-id="walkthrough.linux.start.debugging" data-loc-hint="Refers to Start Debugging command under Run menu on main menu">Debuggen starten</span></strong> aus.</p>
</li>
<li><p data-loc-id="walkthrough.linux.select.compiler">Wählen Sie <strong>C++ (GDB/LLDB)</strong>.</p>
</li>
<li><p data-loc-id="walkthrough.linux.choose.build.active.file">Wählen Sie <strong>g++ - <span data-loc-id="walkthrough.linux.build.and.debug.active.file" data-loc-hint="Should be the same as translation for build.and.debug.active.file in extension.ts">Aktive Datei erstellen und debuggen</span></strong>.</p>
</li>
</ol>
<p data-loc-id="walkthrough.linux.after.running">Nachdem Sie die C++-Datei zum ersten Mal ausgeführt und debuggt haben, werden Sie zwei neue Dateien im <strong>.vscode</strong>-Ordner Ihres Projekts sehen: <strong>tasks.json</strong> und <strong>launch.json</strong>.</p>

<p data-loc-id="walkthrough.linux.for.more.complex">Für komplexere Build-und Debugging-Szenarios können Sie Ihre Build-Tasks- und Debugkonfigurationen in <span>tasks.json</span> und <span>launch.json</span> anpassen. Wenn Sie beispielsweise beim Erstellen mithilfe der Befehlszeile Argumente an den Compiler übergeben, können Sie diese Argumente in <span>tasks.json</span> mithilfe der <strong>compilerArgs</strong>-Eigenschaft angeben. Ebenso können Sie Argumente definieren, die zum Debuggen in <span>launch.json</span> an Ihr Programm übergeben werden.</p>
