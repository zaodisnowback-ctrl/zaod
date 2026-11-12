# Zaod OS

Zaod OS is a concept for a lightweight, Chrome-like operating system designed for older laptops and low-end hardware. The goal is a fast, minimal white-themed desktop experience that feels modern without needing heavy resources.

## Target hardware

- Minimum RAM: 2GB
- Minimum storage: 8GB
- CPU: Intel or AMD low-power / old generation laptops
- Graphics: Intel HD / AMD integrated graphics or lower
- Firmware: UEFI + Chromebook-friendly boot compatibility

## Visual direction

- White and soft grey palette
- Clean, Windows 11-inspired layout
- Minimal chrome-style interface
- Lightweight desktop shell and app launcher
- Fast boot and low memory overhead

## Built-in app concept

- Browser
- YouTube
- TikTok
- Facebook Lite
- WhatsApp
- Files
- Settings

## OS goals

- Fast startup on old laptops
- Simple UI for non-technical users
- Low power consumption
- Chromebook-like boot simplicity
- Reliable UEFI support for legacy hardware

## Project status

This repository currently contains a polished UI prototype of the Zaod OS desktop shell. It is not a full kernel-based operating system yet, but it serves as a realistic foundation for the product direction and UX design.

## Run locally

From this folder:

```bash
python3 -m http.server 8000
```

Then open:

```text
http://localhost:8000
```

## Next step

The next major step would be turning this mockup into a real Linux-based thin OS using a lightweight base such as Debian/Xfce or a custom minimal init stack with a custom launcher and app wrappers.
