# Zaod OS

Lightweight white-themed Debian live system for old laptops
(2 GB RAM / 8 GB storage class, Intel HD graphics, 2012-2020 machines).

What is inside:

- Debian 12 (bookworm) live system, XFCE desktop, autologin to a live session
- Chromium with YouTube, WhatsApp Web, Instagram, Facebook and TikTok as app windows
- File manager (Thunar), camera (guvcview), Wi-Fi (NetworkManager), Bluetooth (Blueman)
- Non-free firmware for Intel/Realtek/Atheros/Broadcom Wi-Fi, Intel audio and graphics
- White Zaod theme: wallpaper, light Adwaita theme, local animated home screen

## Build the ISO

The build runs `live-build`, which needs root and a real Linux host or VM
(mount and `/dev` inside the chroot). GitHub Actions `ubuntu-24.04` is used here:

1. Open **Actions -> Build Zaod OS ISO -> Run workflow**, or push to `main`.
2. After 20-40 minutes the ISO appears in **Releases** (`zaod-os-<n>`) and as an artifact.

Locally on your own Debian/Ubuntu host with root:

```bash
sudo apt update && sudo apt install -y live-build debootstrap xorriso squashfs-tools \
  isolinux syslinux-common syslinux-efi grub-efi-amd64-bin grub-pc-bin mtools dosfstools
sudo WORK=/var/tmp/zaod-build bash scripts/build-zaod-liveiso.sh
```

## Write the ISO to a USB stick

Use your distro's USB writer (for example GNOME Disks "Restore Disk Image",
balenaEtcher, or Rufus on Windows) and select the downloaded `zaod-os-*.iso`.
Pick the USB stick as the target, not your laptop disk.

## Layout

- `build/live-build/config/` - package list, chroot hooks, syslinux splash
- `build/live-build/includes.chroot/` - everything copied into the live rootfs
- `scripts/build-zaod-liveiso.sh` - build entry point
- `.github/workflows/build-iso.yml` - CI build and release publishing
