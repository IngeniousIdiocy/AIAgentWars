# AIAgentWars

Isometric 2D browser-friendly strategy prototype built with Godot 4.5. Choose a Big 4 faction, spawn analyst waves, deploy an auditor hero, and push rival HQs while Accenture neutral mobs guard the center.

## Repo layout

- `scenes/` and `scripts/`: Main, world, units, UI, economy, and AI logic.
- `assets/`: Curated CC0 art used in-game (tile sheet + UI icons). The massive `assets_cc0/` dump is ignored by Godot via `.gdignore` so imports stay fast.
- `tests/`: Lightweight headless tests run through Godot.

## Quickstart

```bash
# run headless tests (Makefile shortcut)
make test

# or without make on Windows PowerShell:
godot --headless --path . --run res://tests/TestRunner.tscn

# open the game in Godot
make run

# export HTML5 build into build/web/
make build-web   # requires Godot export templates installed

# serve the exported build locally (after build-web)
make serve
```

If `make` is not available, run the underlying commands directly (as shown above for tests). Godot CLI (`godot`) is already on the PATH. The export preset `Web` is configured to avoid pulling the unused `assets_cc0/` tree into builds; install export templates to complete the web build.
