# TrueNAS SCALE Helper Script

A little helper to customize TrueNAS SCALE installs for resource efficiency.

## ❓ Why?
TrueNAS SCALE has a few shortcomings for home users with highly efficient, low idle power servers. For example, TrueNAS SCALE will always block all space on the boot drive, it cannot be used for other things. The power management also leaves a lot to be desired of you want to minimize idle power. Contrary to the name (SCALE: ....) TrueNAS SCALE does not use LXC containers, but rather k3s as a container backend. K3s' poor design causes a considerable permanent load on the CPU, preventing it from entering higher c states (it's not a bug, it's a feature....). All these things added up, so I wanted to have a few things changed in my TrueNAS SCALE installation. To document and make things easier for future me, I've made a script to help me. Feel free to use it, but be sure that
YOU ARE OUTSIDE WHAT iX-System DOES SUPPORT, SO YOU WILL BE ON YOUR OWN!

## ✅ Things the script can do
With the disclaimer out of the way, here's what the script can do fo you:
- confine TrueNAS SCALE to certain area of disk and make rest available
- optimize power management (temporarily and permanently)
- install basic docker environment with portainer to manage containers

## ❌ Things the script can't do
- make system disk's space available when you've already installed TrueNAS SCALE
- Reduce power usage when you want to stick to k3s
- you will not be able to use TrueNAS SCALE's UI to manage Apps/Containers

