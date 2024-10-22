#!/bin/sh

install_dependencies() {
    su -l root -c 'pkg install -y wine-devel wine-proton'
    sh -c "/usr/local/share/wine/pkg32.sh install wine-proton wine-devel mesa-dri"
}

if zenity --question --text="Would you like to install wine-devel and wine-proton? Both are dependencies needed."; then
    install_dependencies
else
    zenity --info --text="Installation canceled."
    exit 0
fi

zenity --info --text="Steam will be downloaded to /tmp."

fetch -o /tmp/SteamSetup.exe https://cdn.fastly.steamstatic.com/client/installer/SteamSetup.exe

zenity --info --text="This next step will create the ~/.proton prefix."

mkdir -p ~/.steam

zenity --info --text="Let's install DXVK and corefonts for Steam and video games to function properly."

WINEPREFIX=~/.proton WINE=/usr/local/bin/wine winetricks dxvk

zenity --info --text="The next step will install Steam."

WINEPREFIX=~/.proton /usr/local/bin/wine /tmp/SteamSetup.exe

while pgrep -f "SteamSetup.exe" > /dev/null; do
    sleep 1
done

zenity --info --text="Please click OK 5-10 seconds after the Updating Steam window closes!"

pkill -f "wineserver"
pkill -f "system32"
pkill -f "Steam.exe"
pkill -f "steam.exe"
pkill -f "steamwebhelper.exe"

zenity --info --text="Now, let's add a shortcut for Steam."
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/icons/steambsdruntime
fetch https://i.ibb.co/MM1H2hY/icon.png && cp icon.png ~/.local/share/icons/steambsdruntime/icon.png && rm -rf icon.png
xdg-icon-resource install --size 256 ~/.local/share/icons/steambsdruntime/icon.png steambsdruntime --novendor
su -l root -c 'touch /usr/local/bin/steam-bsd-runtime'
su -l root -c 'echo "WINEPREFIX=~/.proton /usr/local/wine-proton/bin/wine ~/.proton/drive_c/Program\ Files\ \(x86\)/Steam/steam.exe -cef-disable-sandbox -cef-disable-gpu-compositing -cef-in-process-gpu" > /usr/local/bin/steam-bsd-runtime'
su -l root -c 'chmod +x /usr/local/bin/steam-bsd-runtime'
touch ~/.local/share/applications/Steam-BSD-Runtime.desktop
chmod +x ~/.local/share/applications/Steam-BSD-Runtime.desktop
sh -c 'echo "[Desktop Entry]
Comment=BSD Runtime for Steam Client
Exec=steam-bsd-runtime
Icon=steambsdruntime
Categories=Game;
Name=Steam BSD Runtime
StartupNotify=false
Terminal=false
TerminalOptions=
Type=Application" > ~/.local/share/applications/Steam-BSD-Runtime.desktop'

zenity --info --text="Hopefully, this next click will show the Steam login prompt! After that, everything should already be installed, so enjoy :)"

WINEPREFIX=~/.proton WINE=/usr/local/wine-proton/bin/wine winetricks sound=pulse
WINEPREFIX=~/.proton WINE=/usr/local/wine-proton/bin/wine winetricks corefonts
WINEPREFIX=~/.proton /usr/local/wine-proton/bin/wine $WINEBIN reg.exe ADD "HKEY_CURRENT_USER\Software\Wine\DllOverrides" /v "gameoverlayrenderer" /t "REG_SZ" /d "" /f
WINEPREFIX=~/.proton /usr/local/wine-proton/bin/wine $WINEBIN reg.exe ADD "HKEY_CURRENT_USER\Software\Wine\DllOverrides" /v "gameoverlayrenderer64" /t "REG_SZ" /d "" /f

rm -rf ~/.local/share/applications/wine/Programs/Steam/
WINEPREFIX=~/.proton /usr/local/wine-proton/bin/wine ~/.proton/drive_c/Program\ Files\ \(x86\)/Steam/steam.exe -cef-disable-sandbox -cef-disable-gpu-compositing -cef-in-process-gpu 
