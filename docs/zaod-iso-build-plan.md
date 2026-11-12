# Zaod OS ISO build plan

This document explains how to turn the Zaod OS concept into a real bootable ISO.

## 1. Base OS choice

Use a minimal Debian-based live system as the base because it is stable and supports older x86 laptops.

Recommended base:

- Debian 12 (Bookworm)
- XFCE desktop
- Minimal system services
- Chrome-like launcher and white UI

## 2. System target

- CPU: x86_64, Intel/AMD
- RAM: 2GB minimum
- Storage: 8GB minimum
- Graphics: Intel HD / AMD integrated / lower
- Firmware: UEFI compatibility, Chromebook-friendly boot support

## 3. Build method

Use Debian `live-build` tools:

```bash
sudo apt update
sudo apt install -y live-build xorriso syslinux squashfs-tools
```

Then run:

```bash
cd /workspaces/zaod
bash scripts/build-zaod-liveiso.sh
```

## 4. Post-build steps

After the ISO is built:

1. Test under QEMU for boot validation
2. Boot from USB or virtual machine
3. Verify Wi-Fi, audio, brightness, and display
4. Validate the custom launcher and app layout
5. Confirm compatibility with 2GB RAM devices

## 5. Production path

For a true product, the next phase is:

- Replace browser tabs with real app wrappers
- Add a lightweight launcher
- Tune XfCE for low memory usage
- Add hardware support and driver checks
- Deliver a tested ISO to flash drives for legacy laptops

## 6. Important note

The current workspace contains a polished desktop prototype and ISO build recipe, not a full compiled kernel-based operating system. A complete bootable ISO requires a live-build environment and real packaging work on target hardware.
