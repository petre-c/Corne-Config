# Corne-Config

ZMK firmware config for a 42-key Corne (nice!nano, nice!view displays). The keymap
itself ([config/corne.keymap](config/corne.keymap)) is heavily commented — read its
behavior/combo comments before changing anything; this file only covers what the
keymap cannot say about itself.

## Workflow

- Solo repo: commit and **push directly to master**. No PRs.
- Every push triggers the ZMK build via GitHub Actions ([build.yaml](build.yaml)).
  The user flashes the merged `firmware` artifact — **both halves** — via
  double-tap-reset bootloader.
- The nickcoutsos keymap editor reads **master**; keep master current.
- No local build possible; the Actions run is the only verification.

## Key position matrix (needed for combos / hold-trigger lists)

```
 0  1  2  3  4  5    |    6  7  8  9 10 11
12 13 14 15 16 17    |   18 19 20 21 22 23
24 25 26 27 28 29    |   30 31 32 33 34 35
      36 37 38       |   39 40 41
```

Base layer: Q=1..T=5, A=13..G=17, Z=25..B=29 (left); Y=6..P=10, H=18..;=22,
N=30../=34 (right). Thumbs: 36=Ctrl, 37=Enter/L1, 38=Space/Shift, 39=Space/L2,
40=Enter/L1, 41=L4.

## Conventions (user preferences — follow these)

- **Combos are vertical same-column pairs** (like cut X+S, copy C+D, paste V+F,
  parens K+, and L+.). No horizontal pairs.
- **Homerow-mod misfire fixes use dedicated per-key hold-tap behaviors** with
  positions removed from `hold-trigger-key-positions` (see HMR_L, HML_S, HML_A) —
  never loosen the shared HMR/HML behaviors.
- **No preventative retuning.** Only change keys the user has actually complained
  about. (A well-meaning shift-space "improvement" once broke typing `?`.)
- `require-prior-idle-ms` belongs on letter-position combos only — **never** on
  keys used mid-typing-flow (shift, space, the numbers-latch chord).

## Gotchas the files cannot tell you

- **ZMK Studio overrides live on the board, not in this repo.** The left half is
  built with the `studio-rpc-usb-uart` snippet; keymap edits made in ZMK Studio are
  stored in the settings flash partition and **survive reflashes**, silently beating
  the compiled keymap at those positions. Known instance (2026-08): the Lower-layer
  Z-slot sends bare LSHIFT instead of the compiled `!`. Fix when desired:
  zmk.studio over USB (left half) → Restore Stock Settings. If a key ever ignores
  the keymap, suspect this first.
- **The host PC shapes some bindings.** `Sh+Alt+1/0` keys and `LANG1/LANG2` thumbs
  trigger OS-level language/automation on the user's machine (English/Georgian) —
  their meaning is not in this repo; don't "clean them up".
- **PowerToys on the host remaps `` ` ``→`,` system-wide** (Keyboard Manager). The
  keymap deliberately sends no GRAVE usage anymore: the Lower backtick key is an
  Alt+096 macro (`grave_const`) so it types `` ` `` under any input language —
  requires NumLock ON.
- The Lower layer's "(" slot is **intentionally** a `&trans` dot pass-through
  (decimal point beside the number homerow). Parens live on combos instead.
