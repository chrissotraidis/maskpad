# README capture slots

MaskPad's README follows HarkinianPad's visual sequence:

1. one wide gameplay hero immediately below the badges;
2. one touch-gameplay capture with the complete overlay visible; and
3. one current settings or touch-layout-editor capture.

The committed SVGs are original placeholders. Do not replace them with
copyrighted game imagery unless the maintainer has explicitly approved the
specific captures for publication.

## Final filenames

| Slot | Publish as | Preferred framing |
|---|---|---|
| Hero | `maskpad-gameplay.jpg` | 16:9 iPad gameplay, touch controller visible, uncluttered scene |
| Touch | `maskpad-controls.jpg` | 16:9 gameplay, all controls readable at README width |
| Settings | `maskpad-settings.jpg` | 16:9 Controls page or layout editor from the current build |

When approved captures are ready, add the JPG files here and update the three
image paths in the root `README.md`. Keep local paths, device names, debug
overlays, personal notifications, and user-owned filenames out of the images.

Before committing:

```sh
scripts/check-repo-safety.sh
```
