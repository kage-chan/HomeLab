<p align="center">
  <a>
    <img src="https://raw.githubusercontent.com/kage-chan/HomeLab/main/TNSH/screenshot.png" alt="TNSH Screenshot" height="250">
    <h1 align="center">TrueNAS SCALE Helper Script</h1>
  </a>
</p>

<p align="center">
  A little helper to customize TrueNAS SCALE installs for resource efficiency.
</p>


## ❓ Why?
TrueNAS SCALE has a few shortcomings for home users with highly efficient, low idle power servers. For example, TrueNAS SCALE will always block all space on the boot drive, it cannot be used for other things. The power management also leaves a lot to be desired of you want to minimize idle power. Contrary to the name (SCALE: ....) TrueNAS SCALE does not use LXC containers, but rather k3s as a container backend. K3s' poor design causes a considerable permanent load on the CPU, preventing it from entering higher c states (it's not a bug, it's a feature....). All these things added up, so I wanted to have a few things changed in my TrueNAS SCALE installation. To document and make things easier for future me, I've made a script to help me. Feel free to use it, but be sure that
YOU ARE OUTSIDE WHAT iX-System DOES SUPPORT, SO YOU WILL BE ON YOUR OWN!

## ✅ Things the script can do
With the disclaimer out of the way, here's what the script can do fo you:
- confine TrueNAS SCALE to certain area of disk and make rest available
- optimize power management (temporarily and permanently)
- (install basic docker environment with portainer to manage containers; not yet implemented coming these days)

## ❌ Things the script can't do
- make system disk's space available when you've already installed TrueNAS SCALE
- Reduce power usage when you want to stick to k3s
- you will not be able to use TrueNAS SCALE's UI to manage Apps/Containers

# ⛏️ Usage

Regardless of the mode your're running the TrueNAS SCALE Helper in, it will show you a menu and guide you through all steps as neccessary. As the script still is in it's very early stages, there might still be rought edges around here and there. Just feel free to open an issue 😊

## 🔨 During TrueNAS SCALE install
To install TrueNAS SCALE on a partition instead of the whole disk, the script offers a convenient "installer mode", which is only active if you start the script from the TrueNAS SCALE environment. To use the script, please choose "Shell" from the installer menu. In the shell, make sure that you have internet access and run the following code:
```
curl -O https://raw.githubusercontent.com/kage-chan/HomeLab/main/TNSH/TNSH.sh
chmod +x TNSH.sh
./TNSH.sh
```
The script will detect the TrueNAS SCALE installer environment and prompt you. After confirming, please choose the size of the partition for TrueNAS SCALE. You'll be guided back into the actual installer, where you can carry on with the install as usual.

NOTE: Please make sure the partition size you choose is smaller than the disk you have, otherwise the install will fail. In that case, just reboot from the installer stick and retry.


## 🏚️ After the install
To use the script, simply download it and make it executable. The script MUST be run as root, since it does work with pretty important system settings.
```
curl -O https://raw.githubusercontent.com/kage-chan/HomeLab/main/TNSH/TNSH.sh
chmod +x TNSH.sh
sudo TNSH.sh
```
