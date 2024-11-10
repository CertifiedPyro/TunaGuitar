## 0.2.0

### Added
- Allow guitar string keybinds to be rebinded via the "Settings" button when using the guitar.
  - The keybinds for switching chord presets (number keys 1-9) cannot be used when rebinding the guitar strings.
  - The keybinds are stored in `tunaguitar_keybinds.json`.

### Fixes
- Remove logic for deselecting item if selected again.
  - This fixes a bug where an item is repeatedly selected and deselected when searching for an item.
- Keep item selected in UI when focus is lost (e.g. entering the name for a preset when saving).

## 0.1.1

### Fixes
- Fix bug where ok button is sometimes disabled incorrectly when overwrite/delete dialog is opened.
- Fix incorrect text for delete dialog.

## 0.1.0

### Added
- Allow user to save custom chord presets with a given name.
  - The chord presets are stored in `tunaguitar.json`.
- Allow user to load chord presets.
- Allow user to overwrite, rename, and delete chord presets.