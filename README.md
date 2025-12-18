# Beelzebub's Basement

A VR horror/occult experience built with Godot 4.5 and OpenXR.

## Overview

Descend into Beelzebub's Basement - an immersive VR game featuring spell casting, hand tracking, and multiplayer networking. Cast spells using a spell tome, interact with occult objects, and survive the basement's horrors.

## Features

- **VR Support**: Full OpenXR integration with hand tracking
- **Spell Casting System**: Use the spell tome to cast various spells
- **Real Ball Tracking**: Physical balls thrown at a screen are tracked via camera and reflected in-game
- **Multiplayer**: Network support for multiplayer sessions
- **PS1 Aesthetic**: Retro shader effects for that classic horror vibe

## Requirements

- Godot 4.5
- VR headset with OpenXR support (Meta Quest recommended)
- Hand tracking capable device (optional but recommended)

## Project Structure

```
src/
├── ball-detection/          # Camera-based physical ball tracking (Python)
└── beelzebub's-basement/    # Main Godot VR project
    ├── addons/              # XR tools and OpenXR vendors
    ├── audio/               # Sound effects and music
    ├── Materials/           # Shaders and materials
    ├── Models/              # 3D models (GLB format)
    ├── scenes/              # Game scenes
    ├── scripts/             # GDScript game logic
    │   ├── networking/      # Multiplayer state machine
    │   ├── PostProcessing/  # PS1 overlay effects
    │   ├── Shaders/         # Custom shaders
    │   └── XR/              # VR-specific scripts
    └── textures/            # Texture assets
```

## Getting Started

1. Open the project in Godot 4.5
2. Ensure OpenXR is enabled in project settings
3. Connect your VR headset
4. Run the main scene

## Addons Used

- [Godot XR Tools](https://github.com/GodotVR/godot-xr-tools)
- [Godot OpenXR Vendors](https://github.com/GodotVR/godot_openxr_vendors)
- Hand Pose Detector

## License

TBD