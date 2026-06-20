# Eye of the Beholder – Quality-of-Life Enhancements (KYRA engine)

Non-original additions to the ScummVM **KYRA** engine that make
*Eye of the Beholder I* and *II* more comfortable to play with a keyboard and
add a real automap with note-taking and auto-collected dungeon info.

These features are **not** part of the original games. They are layered on top
of the existing EOB engine and persist inside ScummVM save games.

---

## What you get

### Automap overlay
A north-up minimap of the current level, drawn as a crisp high-resolution
overlay on top of the dungeon view. Toggle it with **Tab**.

- **Explored cells** are drawn solid with bright walls.
- **Glimpsed cells** (seen down a corridor but never walked) are drawn dimmer,
  so "saw it" reads differently from "walked it".
- **Doors** are drawn as a green leaf cutting across the middle of the cell,
  along the passage axis – distinct from solid walls.
- **Interactive walls** are flagged with a pip on the side that holds them:
  magenta for a switch / lever / button, amber for a niche / alcove (item stash).
- The title shows the **level and the selected cell's coordinates**, and a
  **legend** along the bottom keys the symbols (Door / Stairs / Tele / Switch / Note).
- The party is shown as an arrow pointing the way it faces.
- The game keeps running underneath; you can keep moving with the map open
  (see shortcuts below) and the map updates live.

### Per-cell map notes (manual)
Attach your own free text to any explored cell.

- **Click** an explored cell on the map to open a small text editor for it.
- Or press **N** to edit the note of the currently selected cell.
- Enter saves (an empty note deletes it); Esc cancels.
- A small marker dot appears on cells that carry a note.
- The selected cell's note is shown in the panel footer.

### Auto-collected cell info (automatic)
Kept separate from your manual notes; the game fills this in by itself.

- **Stairs / level exits** are learned by observation: when a script moves the
  party to another level, the cell you left is tagged. Deeper level number =
  **down (▼)**, lower = **up (▲)**, same level = **teleport (◌)**, with a
  description like `Down to level 3`.
- **Teleporter pads** are detected from the level data and marked with ◌.
- **Items on the floor** of the selected cell are listed live in the footer
  (always accurate – an item you pick up disappears from the list).
- Glyphs are drawn in the cell; the footer's second line shows the auto-info
  plus any items, e.g. `Down to level 3 - Long Sword, Potion`.

> The engine has no human-readable level names, so destinations are shown as
> `level N`. If you want a name like "Castle", add it yourself as a manual note.

### Keyboard / mouseless play
Movement, turning and common actions are bound to the keyboard (see the table).
Extras added here:

- **WASD + Q/E** mirror the arrow/turn keys.
- **F** – use / interact with the wall ahead.
- **G** – pick up the item ahead.
- **1–6** – quick-attack with the matching party member's primary hand.
- **Shift + 1–6** – attack with that member's **off hand**.

### Spellbook keyboard control
With a spellbook open:

- **Arrow keys** select a spell (↑/← previous, ↓/→ next). They navigate the
  book instead of walking the party.
- **1–6** switch spell level (as in the original).
- **Enter** casts the highlighted spell and closes the book. If nothing is
  castable (empty level or the slot is on cooldown) the book stays open.

---

## Building

Easiest – use the bundled helper from the repository root:

```sh
./build.sh          # configure (if needed) + build everything
./build.sh kyra     # fast build: only the KYRA engine (Eye of the Beholder)
./build.sh run      # launch the built scummvm
```

Or the standard ScummVM build by hand – nothing special is required:

```sh
./configure                 # first time only (add --enable-engine-static=kyra etc. if needed)
make -j$(nproc)
```

The KYRA engine (which contains EOB) is built by default. The resulting
`scummvm` binary is produced in the repository root.

To rebuild only the touched objects while iterating:

```sh
make engines/kyra/engine/eobcommon.o \
     engines/kyra/engine/scene_eob.o \
     engines/kyra/gui/gui_eob.o \
     engines/kyra/gui/saveload_eob.o \
     engines/kyra/gui/saveload.o
make -j$(nproc)             # relink
```

---

## Using it

1. Add and start an *Eye of the Beholder I* or *II* game in ScummVM as usual.
2. The keyboard actions live in the game's keymap. They are enabled by default;
   you can review or rebind them in **ScummVM ▸ Options ▸ Keymaps** (or the
   per-game keymap settings) under names like *Toggle automap*, *Edit map note*,
   *Attack N (off hand)*, etc.
3. In game, press **Tab** to open the automap. Click a cell or press **N** to
   take notes. Walk around with the map open to fill it in.

---

## Shortcuts

| Key | Action |
| --- | --- |
| **Tab** | Toggle automap overlay |
| Arrow keys / **W A S D** | Move (forward / back / strafe) |
| **Home** / **PageUp**, or **Q** / **E** | Turn left / right |
| **F** | Use / interact with wall ahead |
| **G** | Pick up item ahead |
| **I** | Open / close inventory |
| **P** | Switch inventory / character screen |
| **C** | Camp |
| **Space** | Cast spell (open spellbook) |
| **1–6** | Quick-attack with party member N (primary hand) |
| **Shift + 1–6** | Attack with party member N's off hand |

### While the automap is open
| Key / input | Action |
| --- | --- |
| Arrow keys / **W A S D** | Move the party (map updates live) |
| **Home/PageUp**, **Q/E** | Turn |
| **Shift + arrows** | Move the selection cursor cell by cell |
| **Mouse click** on an explored cell | Select it and edit its note |
| **N** | Edit the selected cell's note |
| **Enter** / **Esc** (in editor) | Save / cancel the note |
| **Tab** | Close the map |

### While a spellbook is open
| Key | Action |
| --- | --- |
| Arrow keys | Select spell (↑/← previous, ↓/→ next) |
| **1–6** | Switch spell level |
| **Enter** | Cast highlighted spell and close the book |

---

## Save compatibility

The automap data is stored inside ScummVM EOB save games:

- v25 – explored ("visited") cells
- v26 – glimpsed ("seen") cells
- v27 – manual per-cell notes
- v28 – auto-collected glyphs and descriptions

(`CURRENT_SAVE_VERSION` in `engines/kyra/gui/saveload.cpp`.) Older saves load
fine – missing fields are simply treated as empty. Saves written by this build
**cannot** be loaded by an older ScummVM that doesn't know version 28.

---

## Where the code lives

| Area | Files |
| --- | --- |
| Main loop, keymaps, input dispatch | `engines/kyra/engine/eobcommon.cpp`, `eobcommon.h` |
| Automap drawing, notes, auto-info, spellbook nav | `engines/kyra/gui/gui_eob.cpp` |
| Transition tagging hook (`moveParty`) | `engines/kyra/engine/scene_eob.cpp` |
| Save / load of automap data | `engines/kyra/gui/saveload_eob.cpp`, `saveload.cpp` |

Most functions are named `automap*` (overlay, notes, seen/visited bitfields,
auto-info) or `gui_spellbook*` (keyboard spell navigation). Off-hand attacks
reuse the existing attack path with a `0x100` shift flag set in
`KyraEngine_v1::checkInput`.
