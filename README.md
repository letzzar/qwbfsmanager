# Project Description
QWBFS Manager provides a cross platform Qt GUI for working with hard disk drives that have been formatted to the WBFS file system.
This is a cross platform (Windows, macOS, Linux) alternative to WBFS Manager.

This fork ports the original [pasnox/qwbfsmanager](https://github.com/pasnox/qwbfsmanager) to modern systems:

  * Qt 6 and CMake (the old qmake/Qt 4 build is gone), no more OpenSSL or git submodule dependency.
  * Native **Apple Silicon** build; the released DMG is universal (arm64 + x86_64, macOS 12+).
  * Modern Linux (udev properties and mounted volumes instead of the defunct UDisks 1 D-Bus service).
  * Windows builds with MSVC.
  * Refreshed interface: theme aware line icons (light/dark mode), new application icon and splash screen.
  * Update checker using this fork's [GitHub releases](https://github.com/letzzar/qwbfsmanager/releases).

[Downloads](https://github.com/letzzar/qwbfsmanager/releases) - [Report an issue](https://github.com/letzzar/qwbfsmanager/issues)

# Credits & License
  * Original QWBFS Manager: © 2010-2016 Filipe Azevedo ([pasnox](https://github.com/pasnox)) - https://github.com/pasnox/qwbfsmanager
  * Qt 6 port (1.3.0): © 2026 [letzzar](https://github.com/letzzar) and Claude (Anthropic)
  * Icons: [Lucide](https://lucide.dev) (ISC, see `qwbfs/resources/icons/LICENSE-lucide`)
  * Bundled libraries: libwbfs (kwiirk, GPL v2), PictureFlow (Ariya Hidayat, MIT), subset of [Fresh](https://github.com/pasnox/fresh) (Filipe Azevedo, LGPL v3, see `3rdparty/fresh/LICENSE`)

QWBFS Manager is free software, distributed under the terms of the GNU General Public License version 2 or later (see `GPL-2`).

# Features
  * Build with Qt4 and/or Qt5 (1.2.5)
  * Partitions combobox widget presenting their name, file system and size for a better and easy access to your drives. (1.2.0)
  * Game sorting by id, title, size and region. (1.2.0)
  * New ListView widget providing enhanced list and icon mode. (1.2.0)
  * CoverFlow view. (1.2.0)
  * Worker thread has been rewrited and now support all kind of import/export/convert (ISO to ISO, ISO to WBFS, WBFS to ISO, WBFS to WBFS), opening the door for normal file system disc handling (FAT, NTFS...) in a next version. (1.3.0 ?)
  * Batch convertion of ISOs files to WBFSs files. (1.2.0)
  * Batch convertion of WBFSs files to ISOs files. (1.2.0)
  * Batch renaming of ISOs/WBFSs files using customizable mask. (1.2.0)
  * New application icon by Vasseur Jean-Baptiste (Exilys, exilys@hotmail.fr) (1.2.0)
  * New splashscreen by Nagy Franto (http://code.google.com/u/nagy.franto) (1.2.0)
  * Listing of games with titles, sizes and codes. (1.0.0)
  * Drag-and-drop support for adding multiple files at once to the WBFS drive (ISOs). (1.0.0) - Now support WBFSs files (1.2.0)
  * Easy to use interface which also reports available, total and used disk space at a glance. (1.0.0)
  * Batch processing of multiple ISOs. (1.0.0) - Now supports WBFSs files (1.2.0)
  * Rename discs on the WBFS drive. (1.0.0)
  * Multilingual support
    * en_US. (1.0.0)
    * fr_FR. (1.1.0)
    * es_ES by Frannoe (Ubuntu Cosillas) (frannoe@gmail.com) (1.2.0)
    * ca_ES by Frannoe (Ubuntu Cosillas) (frannoe@gmail.com) (1.2.0)
    * it_IT by Federico Pietta (Darkmagister, f.pietta@gmail.com) (1.2.0)
    * it_IT update by kimotori (kimotori, https://github.com/kimotori) (1.2.5)
    * ru_RU, sl_SI, pl_PL, zh_CN, he_IL, da_DK, sk_SK, ja_JP, uk_UA, cs_CZ, ar_SA, zh_TW, de_DE, pt_PT, sv_SE open for translation. (1.1.0)
  * ~~Homebrew Channel entry creation.~~
  * Direct & Indirect Drive-To-Drive transferring and cloning. (1.0.0)
  * ~~Automatic RAR archive extraction.~~
  * Batch extraction and deletion. (1.0.0)
  * ~~Exporting list of games on drive to a .CSV.~~
  * ~~Ability to use more than one cover directory.~~
  * ~~Channel Creation (NEW).~~
  * Using libwbfs directly to achieve greater flexiblity. (1.0.0)
  * Using libfresh for extending Qt, providing great classes like the update checker, the network cache... (1.2.0)
  * Use a separate worker thread to improve responsiveness when doing IO operations. (1.0.0)
  * Update checker. (1.1.0)
  * Passive error handling. (1.1.0)
  * Translations manager. (1.1.0)
  * Network cache based on max retry per query to avoid over bandwidth traffic. (1.1.0)

# Notes
  * Estimating the size of an ISO file can lead to the creation of a temporary file of 16MB in your system temporary path.
  * Indirect transfer can lead to WBFS convertion to ISO of 4.4GB in a temporary file in you system path.

# Requirements
  * Qt >= 6.2 (Core, Gui, Widgets, Network, Xml, Svg, LinguistTools) - bundled with the macOS & Windows packages
  * CMake >= 3.21 and a C/C++17 compiler
  * Linux only: libudev (`libudev-dev`)

# Building
```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release   # add -DCMAKE_PREFIX_PATH=<qt6 prefix> if needed
cmake --build build
```

  * **macOS**: `brew install qt cmake ninja`, then `packages/macos/make-dmg.sh` builds a self contained, signed (ad-hoc) `QWBFSManager.app` and a `.dmg` in `dist/`.
    Use `ARCHS="arm64;x86_64"` with a universal Qt (e.g. from the Qt online installer) for a universal binary.
  * **Linux**: `sudo cmake --install build` installs the binary, the translations, the desktop file and the icon.
    Ubuntu/Debian packages: `qt6-base-dev qt6-tools-dev qt6-l10n-tools qt6-svg-dev libudev-dev`.
  * **Windows**: build with MSVC, then `windeployqt qwbfsmanager.exe`.

GitHub Actions builds the three platforms on every push, and publishes a release when a `v*` tag is pushed.

# Raw disk access
Reading/writing a WBFS partition needs raw access to the device (`/dev/diskXsY` on macOS, `/dev/sdXN` on Linux, `\\.\X:` on Windows).
Depending on your system you may need to run QWBFS Manager as administrator/root, or give your user access to the device.

# Instructions
  * Install using setup.
  * Plug in the hard drive or USB stick.
  * Run the application.
  * Choose the correct drive letter.
  * Click Load. (If you haven't already formatted the disk to WBFS, you can do that by clicking Format).
  * You should now see any backups on the drive on the right hand side.
  * You can drag and drop ISO files from Windows Explorer onto the left hand side or you can browse the file system in the left hand view.
  * Click the Process the import list button to copy them over to the WBFS drive.
  * Enjoy!

# Remaining Future Plans
  * UnRar functionality to automatically UnRar files and add the iso to the WBFS drive.
  * ~~ISO library.~~
  * ~~Additional info from ISO (Game image shown in Disc Channel,...).~~

# They speak about QWBFS Manager
  * [Ubuntu Cosillas](http://ubuntu-cosillas.blogspot.com/2010/11/qwbfs-manager-gestor-de-particiones.html)
  * [WiiGen](http://www.wiigen.fr/qwbfs-manager-103-gestionnaire-disque-dur-multiplateforme-actualite-4543.html)
  * [WiiHacks](http://www.wiihacks.com/customization-apps/61394-qwbfs-manager-win-os-x-operating-systems.html)
  * [Logic Sunrise](http://www.logic-sunrise.com/news-111351-qwbfs-manager-v110-un-gestionnaire-de-hdd-wbfs.html)
  * [Wii Addict](http://www.wii-addict.fr/forum/QWBFS-Manager-110-t20412.html)
  * [Wii GX Mod](http://wii.gx-mod.com/modules/news/article.php?storyid=2817)
  * [Xav91Wii](http://xav91wii.free.fr/forum/viewtopic.php?f=11&t=2462&start=0&sid=20d4ea529d285f11288084fd6b9c1a6a)
  * [Wii Info](http://www.wii-info.fr/download-637-qwbfs-1-1-0-gestionnaire-wbfs.htm)

DISCLAIMER
THIS APPLICATION COMES WITH NO WARRANTY AT ALL, NEITHER EXPRESS NOR IMPLIED.
I DO NOT TAKE ANY RESPONSIBILITY FOR ANY DAMAGE TO YOUR WII CONSOLE
BECAUSE OF IMPROPER USAGE OF THIS SOFTWARE.

# Screenshots
## Linux
![Linux](https://cloud.githubusercontent.com/assets/858201/2847389/92f77d9e-d0ad-11e3-82a1-90a525104128.png)
## OS X
![OS X](https://cloud.githubusercontent.com/assets/858201/2847390/92f8a9bc-d0ad-11e3-8888-c064975d1ede.png)
## Windows
![Windows](https://cloud.githubusercontent.com/assets/858201/2847391/92f9b91a-d0ad-11e3-9b81-bc2256b30442.png)
