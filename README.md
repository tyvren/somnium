<p align="center">
  <img src="https://github.com/user-attachments/assets/66b5b537-8012-4dc3-acbc-162e3d3d2a11" alt="somnium banner" width="100%">
</p>

<p align="center">
  <a href="https://archlinux.org"><img src="https://img.shields.io/badge/OS-Arch_Linux-blue?style=for-the-badge&logo=archlinux&logoColor=white" alt="Arch Linux"></a>
  <a href="https://hyprland.org"><img src="https://img.shields.io/badge/WM-Hyprland-00B4D8?style=for-the-badge&logo=hyprland&logoColor=white" alt="Hyprland"></a>
  <a href="https://git.outfoxxed.me/outfoxxed/quickshell"><img src="https://img.shields.io/badge/Shell-Quickshell-38BDF8?style=for-the-badge&logo=qt&logoColor=white" alt="Quickshell"></a>
  <a href="https://github.com/tyvren/somnium/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-emerald?style=for-the-badge" alt="License"></a>
</p>

<p align="center">
  <b>An automated installation wizard and complete Hyprland desktop environment tailored for Arch Linux.</b>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/5d79ca24-6690-47e2-9392-d9ff535c8bb3" alt="somnium desktop preview" width="100%">
</p>

<p align="center">
  <a href="#-key-features">Key Features</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-quickstart">Quickstart</a> •
  <a href="#-theme-management">Themes</a> •
  <a href="https://github.com/tyvren/somnium/wiki">Wiki & Docs</a>
</p>

---

## Key Features

| Feature | Description |
| :--- | :--- |
| **Quickshell Built** | Fully custom shell components, widgets, and status bars driving the entire desktop UI. |
| **Dynamic Configuration** | Tweak shell layouts, panel behavior, and Hyprland options through an integrated control hub. |
| **Hardware Detection** | Automated installer detects AMD or NVIDIA GPUs and deploys optimal drivers out of the box. |
| **Minimal Footprint** | Curated software selection designed for low idle usage without bloat. |
| **LazyVim Integration** | Preconfigured Neovim environment tuned for rapid workflow and theme consistency. |

---

## Project Architecture

```text
somnium/
├── 📄 boot.sh                 # Lightweight bootstrapper fetched during quickstart
├── 📄 somnium.sh              # Primary interactive installation wizard
│
├── 📂 config/                 # Managed configuration files deployed to ~/.config
│   ├── hypr/                  # Hyprland window manager rules, keybinds, and monitors
│   ├── quickshell/            # QML components, OSDs, panels, and shell widgets
│   └── nvim/                  # LazyVim editor workspace settings
│
├── 📂 core/                   # Sub-installer modules and system provisioners
│   └── packages.sh            # Complete list of core system packages
│
├── 📂 modules/                # Custom shell scripts and IPC utilities for Quickshell
└── 📂 themes/                 # Swappable color profiles and assets

[!NOTE]

Inspect core/packages.sh for a breakdown of all pacman and AUR dependencies installed by default.


Quickstart

[!WARNING]

Clean Installs Recommended: The setup wizard automates package deployment and configuration symlinks. Apply with caution on pre-configured systems to avoid file conflicts.


Prerequisites

Ensure the following system services are enabled prior to execution:

    multilib repository enabled

    pipewire (audio stack)

    NetworkManager (network stack)



Deployment

Boot into your fresh Arch TTY or minimal environment and trigger the bootstrapper:

bash <(curl -sL https://raw.githubusercontent.com/tyvren/somnium/main/boot.sh)

    Enter your sudo elevation credentials when prompted.

    Select your GPU architecture (AMD / NVIDIA / Intel) during hardware configuration.

    Allow the wizard to finish building packages, then reboot into somnium.

Theme Management

somnium includes custom modules for real-time runtime theme switching across Quickshell components, terminal emulators, and Hyprland accents. Color assets and QML schemes are loaded dynamically from the themes/ directory.
