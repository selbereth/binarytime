# Agent instructions: binarytime

Shared rules (GitHub accounts, no ssh, no Claude attribution in commits, Obsidian vault) are in `../AGENTS.md`. This file only adds what is specific to this project.

## What it is

A Garmin Connect IQ watch face (Monkey C, `type="watchface"`, entry `binarytimeApp`) that shows the time and date in binary as three nested hexagons. Each hexagon has 6 triangular segments, one per bit.

| Hexagon | Radius | Shows |
|---|---|---|
| Outer | `dc.getWidth()` | minutes (weight 1) + hour (weight 2), bits overlaid |
| Middle | `width / 3` | day of week (Monday to Saturday as one lit segment; Sunday = none lit) |
| Inner | `width / 4` | day of month (weight 1) + month (weight 2), bits overlaid |

Segment colour comes from the sum of the overlaid values: 0 black, 1 `FirstColor`, 2 `SecondColor`, 3 `ComboColor`. The outline colour is `AmColor` or `PmColor`.

## Layout

- `source/binarytimeView.mc`: all drawing and time logic (`onUpdate`, `decToBinary`, `addBinaries`, `drawHexagon`).
- `source/binarytimeApp.mc`: `AppBase` subclass, `onSettingsChanged` requests a redraw.
- `resources/settings/properties.xml`: default colour values. `settings.xml`: the user-facing settings UI. A new setting needs an entry in both, plus a string in `resources/strings/strings.xml`.
- `manifest.xml`: target devices and `minApiLevel` (1.4.0). The file says it is generated; prefer the VS Code "Monkey C: Edit ..." commands over hand edits.
- Generated or build output, already in `.gitignore`: `bin/`, `export/`, `mir/`, `internal-mir/`, `gen/`. `source/` also contains `binarytime.prg*` and `binarytime-settings.json` build artefacts; do not edit them.

## Build and run

- There is no CLI build in the repo and the Connect IQ SDK (`monkeyc`) is not on `PATH`. Build and run through the VS Code Monkey C extension using `.vscode/launch.json` ("Run App", currently targeting `fr55`).
- If you cannot run the simulator, say so. Do not claim a change works from reading the code alone.

## Conventions and gotchas

- Code style is clang-format-like with 2-space indent in `binarytimeView.mc`. `binarytimeApp.mc` is the SDK template with 4 spaces. Match the file you are editing; do not reformat whole files.
- Colours are read with `getApp().getProperty(...)` (the old API), consistent across the project. Keep it, since `minApiLevel` is 1.4.0.
- Bit arrays are fixed length 6, least significant bit first, index 0 = segment `c-b-p` (top), going clockwise. Values must stay within 0 to 3 because they index `colorCode`.
- Hour is 0 to 23 in 24-hour mode. In 12-hour mode it is mapped with `(h - 1) % 12 + 1`, so midnight shows as 12 (see commit "0 oclock is now 12").
- `now.day_of_week` is 1 for Sunday in `Gregorian.info`, so the weekday array uses `day_of_week - 2` and Sunday is the "all dark" case.
- `onUpdate` runs often and on a battery-powered device. Avoid allocations and heavy work in the draw path.
- The wider device list in `manifest.xml` includes round and low-memory devices; keep changes cheap on memory and avoid APIs newer than 1.4.0 unless you bump `minApiLevel` deliberately.

## Git

- Remote and identity follow the rules in `../AGENTS.md`. Check `git remote -v` before pushing; none is configured at the time of writing.
- Do not commit `.DS_Store` or build output.
