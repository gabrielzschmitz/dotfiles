<h1 data-loc-id="walkthrough.linux.install.compiler">Instalace kompilátoru jazyka C++ na Linuxu</h1>
<p data-loc-id="walkthrough.linux.text1">Pokud provádíte vývoj v jazyce C++ pro systém Linux, doporučujeme nainstalovat kompilátor GCC. Instalace GCC je jednoduchá, postupujte podle těchto tří kroků:</p>
<ol>
<li><p data-loc-id="walkthrough.linux.text2">Pokud chcete aktualizovat seznamy balíčků Ubuntu, spusťte v okně terminálu následující příkaz. Zastaralá distribuce operačního systému Linux může někdy kolidovat s pokusy o instalaci nových balíčků.</p>
<pre><code class="lang-bash">sudo apt update</code></pre>
</li>
<li><p data-loc-id="walkthrough.linux.text3">Nainstalujte nástroje kompilátoru GNU a ladicího programu GDB s tímto příkazem:</p>
<pre><code class="lang-bash">sudo apt install build-essential gdb
</code></pre>
</li>
<li><p data-loc-id="walkthrough.linux.text4">Spuštěním následujícího příkazu ověřte, zda je nainstalován GCC. Měli byste vidět zprávu o autorských právech a informace o verzi GCC, kterou používáte.</p>
<pre><code class="lang-bash">gcc --version</code></pre>
</li>
</ol>
