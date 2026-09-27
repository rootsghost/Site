/* Faw Builder sitesi — ortak betik */
(function(){
  "use strict";
  /* ── Editör demosu ── */
  var demos = {
    c: {
      proj:"hello-gtk", path:"~/Projeler/hello-gtk",
      tree:[["d0","▾ hello-gtk"],["d1","▾ src"],["d2 on","main.c"],["d2","meson.build"],["d1","meson.build"],["d1","README.md"]],
      code:[
        '<span class="m">#include</span> <span class="s">&lt;adwaita.h&gt;</span>',
        '',
        '<span class="k">static void</span>',
        '<span class="f">on_activate</span> (<span class="t">AdwApplication</span> *app)',
        '{',
        '  <span class="t">GtkWidget</span> *win = <span class="f">adw_application_window_new</span> (<span class="m">GTK_APPLICATION</span> (app));',
        '  <span class="f">gtk_window_set_title</span> (<span class="m">GTK_WINDOW</span> (win), <span class="s">"Merhaba"</span>);',
        '  <span class="f hl">gtk_window_present</span> (<span class="m">GTK_WINDOW</span> (win));',
        '}',
        '',
        '<span class="k">int</span>',
        '<span class="f">main</span> (<span class="k">int</span> argc, <span class="k">char</span> *argv[])',
        '{',
        '  <span class="m">g_autoptr</span> (<span class="t">AdwApplication</span>) app =',
        '    <span class="f">adw_application_new</span> (<span class="s">"org.example.Hello"</span>, <span class="m">G_APPLICATION_DEFAULT_FLAGS</span>);',
        '  <span class="f">g_signal_connect</span> (app, <span class="s">"activate"</span>, <span class="m">G_CALLBACK</span> (on_activate), <span class="m">NULL</span>);',
        '  <span class="k">return</span> <span class="f">g_application_run</span> (<span class="m">G_APPLICATION</span> (app), argc, argv);',
        '}'
      ],
      folds:[4,12],
      pop:'<b>void</b> gtk_window_present (<b>GtkWindow</b> *window)<p data-i18n="ide.popDoc">Pencereyi kullanıcıya gösterir ve öne getirir.</p><span class="uses" data-i18n="ide.uses">3 kullanım</span>',
      panelTabs:["Derleme","Sorunlar","Terminal"],
      out:'<span class="dim">$ meson compile -C build</span>\n[1/3] Compiling C object src/hello.p/main.c.o\n[2/3] Linking target src/hello\n<span class="ok">✓ Derleme başarılı · 0 hata · 0 uyarı</span>'
    },
    kt: {
      proj:"MyApp", path:"~/Projeler/MyApp · Pixel 7 (USB)",
      tree:[["d0","▾ MyApp"],["d1","▾ app/src/main"],["d2 on","MainActivity.kt"],["d2","AndroidManifest.xml"],["d1","build.gradle.kts"],["d1","gradle/libs.versions.toml"]],
      code:[
        '<span class="k">package</span> org.example.myapp',
        '',
        '<span class="k">import</span> android.os.<span class="t">Bundle</span>',
        '<span class="k">import</span> androidx.activity.<span class="t">ComponentActivity</span>',
        '<span class="k">import</span> androidx.activity.compose.<span class="f">setContent</span>',
        '<span class="k">import</span> androidx.compose.material3.<span class="f">Text</span>',
        '',
        '<span class="k">class</span> <span class="t">MainActivity</span> : <span class="t">ComponentActivity</span>() {',
        '    <span class="k">override fun</span> <span class="f">onCreate</span>(savedInstanceState: <span class="t">Bundle</span>?) {',
        '        <span class="k">super</span>.<span class="f">onCreate</span>(savedInstanceState)',
        '        <span class="f">setContent</span> {',
        '            <span class="f">Text</span>(<span class="s">"Merhaba, Faw!"</span>)',
        '        }',
        '    }',
        '}'
      ],
      folds:[8,9,11],
      pop:null,
      panelTabs:["Logcat","Cihazlar","Gradle"],
      out:'<span class="dim">$ ./gradlew assembleDebug · adb install -r · am start</span>\n<span class="info">I</span>/ActivityManager: Start proc org.example.myapp\n<span class="info">D</span>/MainActivity: onCreate()\n<span class="ok">✓ Pixel 7 üzerinde çalışıyor</span>'
    }
  };
  var EN = {
    "meta.description":"Faw Builder is a native Linux C/C++ IDE built with GTK4/libadwaita, with LSP editing, Git, debuggers, a visual UI designer and Android development.",
    "theme.label":"Site theme","theme.default":"Default","theme.ide":"Dark IDE",
    "nav.menu":"Menu","nav.features":"Features","nav.languages":"Languages","nav.compare":"Compare","nav.install":"Install","nav.faq":"FAQ",
    "nav.shortcuts":"Shortcuts","nav.philosophy":"Philosophy","nav.support":"Support",
    "hero.eyebrow":"Open source · Linux native","hero.tagline":"A native <strong>C/C++ and Android</strong> development environment for Linux. Not Electron: GTK4 and libadwaita.",
    "hero.download":"Download","hero.source":"Source code","hero.ideLabel":"Illustration of the Faw Builder editor window",
    "ide.build":"▶ Build","ide.debug":"Debug","ide.popDoc":"Shows the window to the user and brings it to the front.","ide.uses":"3 usages",
    "features.title":"Everything you need to write code","features.intro":"Built for C and GTK projects. An editor that understands your code through clangd and opens fast with GtkSourceView.",
    "features.lsp.title":"LSP-powered editing","features.lsp.body":"Go to definition (F12), rename (F2), a hover window with docs and \"N usages\", call hierarchy, symbol browser. Completion draws on three sources: the GIR catalog, words in the file and LSP.",
    "features.folding.title":"Code folding","features.folding.body":"Brace-based folding for C/C++, indentation-based folding for Python, Kotlin, Vala and YAML.",
    "features.search.title":"Project-wide search","features.search.body":"Regex search and an undoable \"replace all\". Quick Open (Ctrl+P) and a command palette (Ctrl+Shift+P) that lists every registered command.",
    "features.debug.title":"Git, GDB and LLDB","features.debug.body":"Git status, diff and blame panel, a patch review tool. Separate debugger panels for GDB (MI) and LLDB, plus a VTE terminal.",
    "features.editor.title":"Split view, Vim mode, snippets","features.editor.body":"Multiple cursors, Vim mode, minimap, TODO scanner, struct inventory, a snippet editor, custom keybindings, a Custom Tools menu, print/PDF, session management. Native file I/O and theme picker.",
    "features.build.title":"Meson, Make, CMake, Flatpak","features.build.body":"Named run targets, a test command and an AddressSanitizer switch through <code>.faw-project</code> v2. Build on save, a clickable Problems panel, Sysprof, a GModule-based plugin API.",
    "languages.title":"Supported languages and tools","languages.lsp":"Full LSP support","languages.edit":"Highlighting and folding","languages.ui":"UI files",
    "android.title":"Kotlin without installing Android Studio","android.intro":"The whole chain from template to phone lives inside the IDE. If <code>adb</code>, <code>java</code> or the SDK is missing, the panel stays inactive and tells you what is missing.",
    "android.p1":"Template","android.p1c":"XML View or Compose","android.p2":"SDK check","android.p3":"Build","android.p4":"Install","android.p5":"Launch","android.p6c":"package and level filters",
    "android.c1.title":"Gradle, SDK, devices","android.c1.body":"Gradle Wrapper, an SDK Manager window, USB and wireless ADB, AVDs and the emulator, Maven Central library search.",
    "android.c2.title":"Debugging and packaging","android.c2.body":"A JDWP debugger with gutter breakpoints, Gradle sync errors in the Problems panel, release signing with a keystore wizard, .aab and APK analysis.",
    "android.c3.title":"Inspection tools","android.c3.body":"CPU/memory profiler, Layout Inspector with bounds overlay, Database Inspector, Lint, Resource Manager, Vector Asset Studio, screen mirroring with scrcpy.",
    "android.c4.body":"HTTP traffic inspection through mitmdump, with automatic <code>adb reverse</code> and device proxy. Not yet tested end to end with a real mitmproxy.",
    "badge.exp":"Experimental",
    "designer.title":"Drag and drop your UI, save it as .ui and .blp","designer.intro":"A separate GTK4 and Android UI designer, opened from Faw Builder with <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>U</kbd>.",
    "designer.f1":"<b>Palette generated from GIR.</b> 151 classes from Gtk4 and Adwaita, with a search box. No hand-picked list.",
    "designer.f2":"<b>Canvas with placeholders.</b> Drop into GtkBox and GtkGrid, place freely in GtkFixed, snap to edges.",
    "designer.f3":"<b>Inspector.</b> Properties, layout, signals, accessibility labels, translatable flags and reset.",
    "designer.f4":"<b>Modern libadwaita.</b> Template widgets, a GMenu editor, Adw.Breakpoint, deprecation warnings for your target GTK version.",
    "designer.f5":"<b>Live preview.</b> The design opens in a separate process through the real GtkBuilder and can be tried with theme, right-to-left (RTL), scale and locale variants. 100 steps of undo/redo.",
    "designer.f6":"<b>Android side.</b> Layout XML tree and attribute editor, a Compose designer (one-way code generation).",
    "designer.canon":"canonical","designer.auto":"generated on every save","designer.cmpCap":"Faw Designer compared with Cambalache and Glade","designer.cmpFeature":"Feature",
    "designer.r1":"Palette generated from GIR","designer.r2":"Filling containers with placeholders","designer.r3":"Blueprint (.blp) output","designer.r4":"Adw.Breakpoint editing","designer.r5":"Android layout XML","designer.r6":"Sandboxed render process",
    "compare.eyebrow":"Why Faw Builder","compare.title":"Against the alternatives","compare.filterLabel":"Compare with","compare.all":"All",
    "compare.r1":"Native (not Electron)","compare.r2":"C/C++ LSP (go to definition, rename, hover)","compare.r3":"Android build, debug and profiler","compare.r4":"Visual GTK4 UI designer","compare.r5":"C/C++ and Android in one app","compare.r6":"Play Console integration","compare.r7":"Open source",
    "compare.note":"◐ partial or through extensions. Android Studio supports C/C++ through the NDK, but its focus is Android. VS Code's core is MIT licensed; the distributed build includes closed-source components.",
    "shortcuts.title":"Keep your hands on the keyboard",
    "sc.save":"Save","sc.palette":"Command palette","sc.quick":"Quick open","sc.search":"Search the project","sc.goto":"Go to definition","sc.rename":"Rename symbol","sc.format":"Format document","sc.doc":"Show documentation","sc.next":"Select next match","sc.designer":"Open Faw Designer",
    "install.title":"Build from source or package it","install.req":"System requirements","install.meson":"Meson ≥ 1.3.0, Ninja and blueprint-compiler","install.cc":"A C11 compiler","install.opt":"Optional: clangd, VTE, gdb, lldb, adb, java, jdb",
    "install.check":"Run <code>packaging/check-env.sh</code> first to see what your machine can build.","install.build":"Build from source","install.copy":"Copy","install.pkg":"Package formats",
    "install.deb":"For Debian and Ubuntu. Needs meson, ninja, dpkg-deb and the GTK4/libadwaita/libpanel development packages. Timestamps are pinned for reproducible builds.",
    "install.app":"A single distro-independent file. <code>linuxdeploy</code> and <code>appimagetool</code> must be on PATH; the script never downloads them. <code>linuxdeploy-plugin-gtk</code> is recommended.",
    "install.flat":"Needs the GNOME 46 runtime and SDK. The manifest builds blueprint-compiler, libpanel and faw-builder in that order.",
    "install.win":"Cross-compiled with MinGW-w64. All 417 targets build and the .exe runs under Wine. You still need to place the GTK DLLs next to it by hand.",
    "install.note":"The scripts build packages from source and none of them download anything implicitly. The download links are examples for now.","install.sample":"sample version","install.all":"All releases",
    "faq.title":"Frequently asked questions",
    "faq.q1":"Why GTK4 instead of Electron?","faq.a1":"Native GTK4 and libadwaita use less memory and CPU and fit the GNOME desktop visually and functionally. No bundled Chromium.",
    "faq.q2":"Is there Windows or macOS support?","faq.a2":"The target platform is Linux. There is no macOS support. An experimental MinGW-w64 cross-build script exists for Windows; the resulting .exe needs the GTK DLLs added by hand.",
    "faq.q3":"Do I need Android Studio for Android work?","faq.a3":"No. Gradle, SDK/AVD management, ADB, the JDWP debugger and the profiler are built in. If you have no SDK, \"Install SDK\" downloads cmdline-tools and the essential packages.",
    "faq.q4":"What license is it released under?","faq.a4":"Faw Builder is free software distributed under the <a href=\"https://www.gnu.org/licenses/gpl-3.0.html\" rel=\"license noopener\">GNU General Public License version 3</a> or (at your option) any later version (GPL-3.0-or-later). You can use it, study its source code, modify and share it; if you distribute a modified version, you must share its source code under the same license.",
    "faq.q5":"How can I contribute?","faq.a5":"Open an issue or send a pull request on GitHub. The links below take you there.",
    "changelog.eyebrow":"Changelog","changelog.title":"Recently added",
    "log.5":"SDK Manager window: install and remove any sdkmanager package. The Windows cross-build was verified with 417 targets.",
    "log.4":"Experimental Network Inspector panel (mitmdump).","log.3":"A separate LLDB panel next to GDB.",
    "log.2":"Android toolset expanded: Compose Preview, Profiler, Layout Inspector, Resource Manager, Vector Asset Studio, screen mirroring. Android XML and Compose designers in Faw Designer.",
    "log.1":"Faw Designer: template widgets, translatable flags, Adw.Breakpoint and target version warnings.",
    "log.0":"Code folding, hover window, native file I/O and project-wide regex search.",
    "philo.title":"Why open source?","philo.body":"Developer tools should be transparent. You should be able to see how they work, change them to fit your needs and decide for yourself whether to trust them. All of Faw Builder's source code is open, and it runs locally with no cloud account required.",
    "a11y.eyebrow":"Accessibility","a11y.title":"Screen reader support at the toolkit level","a11y.body":"Standard GTK4 widgets inherit AT-SPI support. Faw Designer's accessibility section lets you add labels and descriptions to your own interfaces. Custom-drawn parts such as the folding gutter have not been audited separately yet.",
    "gh.title":"Contribute to the project","gh.body":"Report a bug, suggest a feature or send code. No new command counts as done until it shows up in the command palette, a menu or the preferences.",
    "gh.star":"Star on GitHub","gh.issue":"Report an issue",
    "donate.title":"Support the project","donate.intro":"Faw Builder is built by volunteers. Donations make the time spent on development sustainable.",
    "donate.gh":"Monthly or one-time support.","donate.oc":"Transparent budget, suited to company donations.","donate.kofi":"A small one-time tip.","donate.cta":"Donate",
    "footer.product":"Product","footer.res":"Resources","footer.legal":"Legal","footer.license":"License: GPL-3.0-or-later","footer.privacy":"Privacy policy","footer.contact":"Contact","footer.made":"Made with GTK4, for Linux."
  };  Object.assign(EN, {
    "theme.mode":"Appearance","theme.system":"System","theme.light":"Light","theme.dark":"Dark",
    "hero.tests":"103/103 tests passing (GLib GTest, 2026-09-26)",
    "nav.audience":"Who it's for","aud.title":"Who is it for?",
    "aud.c.t":"Linux C/C++ developers","aud.c.b":"People tired of Electron-based editors who want native performance, less memory and system integration.",
    "aud.a.t":"Android developers","aud.a.b":"People escaping Android Studio's weight who want Gradle, ADB, JDWP and a profiler in a lighter IDE.",
    "aud.x.t":"People who do both","aud.x.b":"Work that spans C/C++ and Android: embedded systems, JNI, native libraries.",
    "aud.o.t":"Open-source advocates","aud.o.b":"People who value transparency, hackability and tools that run locally.",
    "install.ci":"Every change is built and tested on Linux in GitHub Actions and cross-compiled for Windows with MSYS2. <code>packaging/</code> also has a Docker script.",
    "log.6":"Faw Designer: focus order editor, preview variants (theme/RTL/scale/locale), GResource generation, CSS classes and zoom.",
    "footer.terms":"Terms of use","footer.eco":"Ecosystem","footer.circuit":"· PCB and schematics","footer.voice":"· offline voice assistant",
    "nav.guide":"Guide","nav.releases":"Releases","nav.gallery":"Gallery","nav.fit":"Which one?","nav.perf":"Performance","nav.contribute":"Contribute","nav.debugger":"Debugging",
    "hero.flathubSmall":"Get it on","hero.other":"Other options",
    "more.debugger":"Debugging details","more.android":"All Android features","more.designer":"Faw Designer details and known limits","more.releases":"All release notes",
    "gallery.title":"Screenshots and short demos","gallery.t1":"Editor","gallery.t4":"Debugging","gallery.pending":"Image coming soon",
    "gallery.c1":"A GTK project with split view, code folding and the hover window open.",
    "gallery.c2":"Build, install on the phone and filter Logcat: one 10-second recording.",
    "gallery.c3":"Drag from the palette into a GtkGrid, then the live preview window.",
    "gallery.c4":"A GDB session stopped at a gutter breakpoint, with the variables panel.",
    "gallery.c5":"The Git status panel and a line-by-line diff view.",
    "compare.intro":"Three tables, depending on what you compare it with. Click a competitor to keep only that column.",
    "fit.title":"Which tool fits you?","fit.intro":"Faw Builder is not the best choice for every job. Here is what we suggest for each case:",
    "fit.us":"C/GTK desktop apps and Kotlin Android apps in one place, with a designer that outputs Blueprint",
    "fit.builder":"You only write GNOME/Flatpak apps and don't need Android","fit.qt":"You build Qt or KDE applications",
    "fit.as":"You only do Android and need Play Console integration","fit.clion":"You want a commercially supported C++ IDE that also runs on Windows and macOS",
    "fit.light":"You want a fast, lightweight editor rather than an IDE",
    "perf.title":"Startup time and memory","perf.intro":"Only measured numbers will appear here. The table stays empty until we measure; we don't publish estimates.",
    "perf.m1":"Same machine, same Linux distribution, cold start after dropping caches.","perf.m2":"Startup time is the median of 10 runs with <code>hyperfine</code>.",
    "perf.m3":"Each IDE has the same Meson project open with one <code>.c</code> file being edited.","perf.m4":"Memory: VmRSS from <code>/proc/&lt;pid&gt;/status</code> after 60 seconds, child processes included.",
    "perf.m5":"The script and raw results are published in the repository so anyone can repeat them.",
    "perf.r1":"Cold start","perf.r2":"Memory (RSS)","perf.na":"not measured",
    "faq.q6":"How is it different from Zed or Geany?","faq.a6":"Zed and Geany are fast, lightweight editors. Faw Builder is an IDE: build systems, debuggers, the Android toolchain and a visual UI designer come built in. If you only edit files, they stay lighter.",
    "contrib.intro":"You can help even if you don't write code. Four ways:",
    "contrib.code.t":"Code","contrib.code.b":"Send a pull request. Every new command must be reachable from the command palette, a menu or the preferences.","contrib.code.a":"Open tasks",
    "contrib.tr.t":"Translation","contrib.tr.b":"The UI is in Turkish and English. Add a new language or fix existing translations.","contrib.tr.a":"Join translation",
    "contrib.bug.t":"Report bugs","contrib.bug.b":"Crashes, wrong behavior or missing docs. Include the steps and the version.",
    "contrib.test.t":"Test on real hardware","contrib.test.b":"Network Inspector, Flatpak builds and some mouse interactions have only been tested programmatically so far. Try them on your machine and report back.","contrib.test.a":"Test list"
  });
  var lang = "tr";
  var root = document.documentElement;
  function store(k,v){try{ if(v===undefined) return localStorage.getItem(k); localStorage.setItem(k,v);}catch(e){return null}}
  function t(tr,en){ return lang==="en" ? en : tr; }
  Object.keys(window.FAW_PAGE_EN||{}).forEach(function(k){ EN[k] = window.FAW_PAGE_EN[k]; });

  /* ── Sekmeler (genel) ── */
  function setupTabs(tabs, onSelect){
    tabs.forEach(function(tab,i){
      tab.addEventListener("click", function(){ select(i); });
      tab.addEventListener("keydown", function(e){
        var n = e.key==="ArrowRight" ? 1 : e.key==="ArrowLeft" ? -1 : 0;
        if(!n) return; e.preventDefault(); var j=(i+n+tabs.length)%tabs.length; select(j); tabs[j].focus();
      });
    });
    function select(i){
      tabs.forEach(function(x,k){ x.setAttribute("aria-selected", k===i); x.tabIndex = k===i?0:-1; });
      onSelect(tabs[i], i);
    }
    return select;
  }
  document.querySelectorAll(".tablist[data-panels]").forEach(function(list){
    var tabs = [].slice.call(list.querySelectorAll("[role=tab]"));
    setupTabs(tabs, function(sel){
      tabs.forEach(function(x){ var p=document.getElementById(x.getAttribute("aria-controls")); if(p) p.hidden = x!==sel; });
    });
  });

  /* ── Editör demosu (yalnız ana sayfa) ── */
  var editor = document.getElementById("ide-editor");
  function renderDemo(key){
    var d = demos[key];
    document.getElementById("ide-proj").textContent = d.proj;
    document.getElementById("ide-path").textContent = d.path;
    document.getElementById("ide-tree").innerHTML = d.tree.map(function(r){return '<div class="'+r[0]+'">'+r[1]+'</div>'}).join("");
    editor.innerHTML = '<pre>' + d.code.map(function(l,i){
      return '<span class="l'+(d.folds.indexOf(i+1)>-1?' fold':'')+'">'+(l||' ')+'</span>';
    }).join("") + '</pre>' + (d.pop ? '<div class="hover-pop" role="note">'+d.pop+'</div>' : '');
    document.getElementById("ide-panel-tabs").innerHTML = d.panelTabs.map(function(x,i){return '<span'+(i===0?' class="on"':'')+'>'+x+'</span>'}).join("");
    document.getElementById("ide-panel-out").innerHTML = d.out;
    editor.setAttribute("aria-labelledby","demo-tab-"+key);
    applyLang(editor);
  }
  if(editor){
    setupTabs([].slice.call(document.querySelectorAll(".ide-tab")), function(x){ renderDemo(x.dataset.demo); });
  }

  /* ── Karşılaştırma tabloları (data/compare.json → #compare-data) ── */
  var cmpData = null, cmpTable = 0, cmpFocus = "all";
  var SYM = { yes:"✓", no:"✗", part:"◐", unknown:"?" };
  function renderCompare(){
    if(!cmpData) return;
    var tb = cmpData.tables[cmpTable], host = document.getElementById("cmp-host");
    var cols = tb.columns;
    var filter = document.getElementById("cmp-filter");
    filter.innerHTML = '<button type="button" data-cmp="all" aria-pressed="'+(cmpFocus==="all")+'">'+t("Hepsi","All")+'</button>' +
      cols.slice(1).map(function(c){ return '<button type="button" data-cmp="'+c.id+'" aria-pressed="'+(cmpFocus===c.id)+'">'+c.name+'</button>'; }).join("");
    var visible = cols.filter(function(c,i){ return i===0 || cmpFocus==="all" || c.id===cmpFocus; });
    var head = '<tr><th scope="col">'+t("Özellik","Feature")+'</th>' + visible.map(function(c,i){
      var flag = c.checked ? '<span class="chk ok-chk" title="'+t("Kontrol: ","Checked: ")+c.checked+'">✓ '+c.checked+'</span>'
               : (c.self ? '<span class="chk">'+t("proje dokümanları","project docs")+'</span>'
               : '<span class="chk warn-chk">'+t("doğrulanmadı","unverified")+'</span>');
      var name = c.url ? '<a href="'+c.url+'">'+c.name+'</a>' : c.name;
      return '<th scope="col" class="v'+(c.self?' col-us':'')+'">'+name+flag+'</th>';
    }).join("") + '</tr>';
    var body = tb.rows.map(function(r){
      var label = lang==="en" ? r.en : r.tr;
      var note = r.note ? '<span class="row-note">'+(lang==="en"?r.note.en:r.note.tr)+'</span>' : '';
      return '<tr><th scope="row">'+label+note+'</th>' + visible.map(function(c){
        var v = r.values[c.id] || "unknown";
        return '<td class="v '+v+(c.self?' col-us':'')+'"><span aria-hidden="true">'+SYM[v]+'</span><span class="sr-only">'+
          ({yes:t("var","yes"),no:t("yok","no"),part:t("kısmi","partial"),unknown:t("bilinmiyor","unknown")})[v]+'</span></td>';
      }).join("") + '</tr>';
    }).join("");
    host.innerHTML = '<table><caption class="sr-only">'+(lang==="en"?tb.en:tb.tr)+'</caption><thead>'+head+'</thead><tbody>'+body+'</tbody></table>';
    filter.querySelectorAll("[data-cmp]").forEach(function(b){
      b.addEventListener("click", function(){ cmpFocus = b.dataset.cmp; renderCompare(); });
    });
    var note = document.getElementById("cmp-note");
    if(note) note.innerHTML = lang==="en" ? tb.noteEn : tb.noteTr;
  }
  function initCompare(data){
    cmpData = data;
    var cmpTabs = document.getElementById("cmp-tabs");
    cmpTabs.innerHTML = cmpData.tables.map(function(tb,i){
      return '<button role="tab" aria-selected="'+(i===0)+'" aria-controls="cmp-host" tabindex="'+(i===0?0:-1)+'">'+(lang==="en"?tb.en:tb.tr)+'</button>';
    }).join("");
    setupTabs([].slice.call(cmpTabs.querySelectorAll("[role=tab]")), function(x,i){ cmpTable = i; cmpFocus = "all"; renderCompare(); });
    renderCompare();
  }
  var cmpHost = document.getElementById("cmp-host");
  if(cmpHost){
    fetch(cmpHost.dataset.src).then(function(r){ if(!r.ok) throw new Error(r.status); return r.json(); })
      .then(initCompare)
      .catch(function(){ cmpHost.innerHTML = '<p class="cmp-error">'+t("Karşılaştırma verisi yüklenemedi. Sayfayı bir web sunucusundan aç (dosyayı doğrudan açınca tarayıcı JSON okumaya izin vermez).","Comparison data could not be loaded. Serve the page from a web server (browsers block reading JSON from a local file).")+'</p>'; });
  }

  /* ── İşletim sistemine göre indirme butonu ── */
  var osBtn = document.getElementById("os-download");
  if(osBtn){
    var plat = ((navigator.userAgentData && navigator.userAgentData.platform) || navigator.platform || navigator.userAgent || "").toLowerCase();
    var os = /win/.test(plat) ? "win" : /mac|iphone|ipad/.test(plat) ? "mac" : /android/.test(navigator.userAgent.toLowerCase()) ? "android" : "linux";
    osBtn.dataset.os = os;
  }
  function renderOs(){
    if(!osBtn) return;
    var os = osBtn.dataset.os, hint = document.getElementById("os-hint");
    var map = {
      linux:  { href:"https://fawlibs.org/download/FawBuilder-0.1.0-x86_64.AppImage", label:t("Linux için indir","Download for Linux"), hint:t("AppImage · x86_64 · örnek sürüm 0.1.0","AppImage · x86_64 · sample version 0.1.0") },
      win:    { href:"https://fawlibs.org/download/faw-builder-0.1.0-win64.zip", label:t("Windows için indir","Download for Windows"), hint:t("Deneysel · GTK DLL'leri elle eklenmeli","Experimental · GTK DLLs must be added by hand") },
      mac:    { href:"#kurulum", label:t("Kurulum seçenekleri","Install options"), hint:t("macOS desteklenmiyor. Linux makinede kullanabilirsin.","macOS is not supported. Use it on a Linux machine.") },
      android:{ href:"#kurulum", label:t("Kurulum seçenekleri","Install options"), hint:t("Faw Builder masaüstü uygulamasıdır. Linux bilgisayarda kur.","Faw Builder is a desktop app. Install it on a Linux computer.") }
    }[os];
    osBtn.href = map.href; osBtn.textContent = map.label; if(hint) hint.textContent = map.hint;
  }

  /* ── Kopyala ── */
  document.querySelectorAll("[data-copy]").forEach(function(btn){
    btn.addEventListener("click", function(){
      var el = document.getElementById(btn.dataset.copy);
      var text = el.innerText.split("\n").filter(function(l){return l.trim().charAt(0)!=="#"}).join("\n").trim();
      var done = function(){ var o=btn.textContent; btn.textContent = t("Kopyalandı","Copied"); setTimeout(function(){btn.textContent=o},1500); };
      var fallback = function(){ var r=document.createRange(); r.selectNodeContents(el); var s=getSelection(); s.removeAllRanges(); s.addRange(r); };
      if(navigator.clipboard && navigator.clipboard.writeText){ navigator.clipboard.writeText(text).then(done, fallback); } else fallback();
    });
  });

  /* ── Mobil menü ── */
  var menuBtn = document.getElementById("menu-toggle"), nav = document.getElementById("site-nav");
  if(menuBtn && nav){
    menuBtn.addEventListener("click", function(){ var o = nav.classList.toggle("open"); menuBtn.setAttribute("aria-expanded", o); });
    nav.addEventListener("click", function(e){ if(e.target.closest("a")){ nav.classList.remove("open"); menuBtn.setAttribute("aria-expanded", false);} });
  }

  /* Site teması ve dil tercihi: assets/ayarlar.js (her sayfanın <head> bölümünde) */

  /* ── Yan içindekiler ── */
  var tocLinks = [].slice.call(document.querySelectorAll(".side-toc a"));
  if("IntersectionObserver" in window && tocLinks.length){
    var io = new IntersectionObserver(function(entries){
      entries.forEach(function(en){ if(en.isIntersecting){
        tocLinks.forEach(function(a){ a.classList.toggle("active", a.getAttribute("href")==="#"+en.target.id); });
      }});
    }, {rootMargin:"-45% 0px -50% 0px"});
    tocLinks.forEach(function(a){ var h=a.getAttribute("href"); if(h.charAt(0)!=="#") return; var x=document.querySelector(h); if(x) io.observe(x); });
  }

  /* ── Dil (TR/EN) ── */
  function applyLang(scope){
    (scope||document).querySelectorAll("[data-i18n]").forEach(function(el){
      if(el.dataset.tr === undefined) el.dataset.tr = el.innerHTML;
      var k = el.dataset.i18n;
      el.innerHTML = (lang==="en" && EN[k]) ? EN[k] : el.dataset.tr;
    });
    (scope||document).querySelectorAll("[data-i18n-attr]").forEach(function(el){
      var parts = el.dataset.i18nAttr.split(":"), attr = parts[0], k = parts[1];
      if(el.dataset.trAttr === undefined) el.dataset.trAttr = el.getAttribute(attr) || "";
      el.setAttribute(attr, (lang==="en" && EN[k]) ? EN[k] : el.dataset.trAttr);
    });
  }
  function setLang(l){
    lang = l; root.lang = l; applyLang();
    document.querySelectorAll("[data-lang-toggle]").forEach(function(b){ b.textContent = l==="en" ? "TR" : "EN"; });
    if(cmpData){
      document.querySelectorAll("#cmp-tabs [role=tab]").forEach(function(b,i){ b.textContent = lang==="en"?cmpData.tables[i].en:cmpData.tables[i].tr; });
      renderCompare();
    }
    renderOs();
  }
  /* Dil tercihi assets/ayarlar.js'te saklanır; tüm sayfalar ve açık sekmeler aynı dili kullanır. */
  document.querySelectorAll("[data-lang-toggle]").forEach(function(b){ b.addEventListener("click", function(){
    var yeni = lang==="en" ? "tr" : "en";
    if(window.FawAyar) window.FawAyar.dilSec(yeni); else setLang(yeni);
  }); });
  if(window.FawAyar) window.FawAyar.dilDinle(function(l){ if(l !== lang) setLang(l); });

  if(editor) renderDemo("c");
  renderOs();
  var ilkDil = window.FawAyar ? window.FawAyar.dil() : (location.hash === "#en" ? "en" : store("faw-lang"));
  if(ilkDil === "en") setLang("en");
  if(window.FawAyar) window.FawAyar.ceviriHazir();
})();
