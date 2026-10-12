# Profile Sticker Handoffs

Profile owns the generated-sticker handoff point. Users select a generated
sticker from Profile > Your Stickers, then choose an action from the sticker
action dialog. Other features should connect through optional callbacks on
`UserProfilePage` instead of importing Profile internals or reading original
flower photos.

## Sharing

Use `UserProfilePage.onShareSticker`.

The callback runs only after the user taps `Share Sticker` in the sticker action
dialog.

The callback receives a `GeneratedStickerAsset` with:

- `stickerBytes`: the final generated sticker PNG bytes after background
  removal and transparent-padding crop
- `stickerId`: the selected sticker style ID when available
- `createdAt`: the sticker creation time when available
- `label`: optional display label

Only completed generated stickers are exposed. The original flower photo is not
passed to sharing.

## Diary

Use `UserProfilePage.onAddStickerToDiary`.

The callback runs only after the user taps `Add to Diary` in the sticker action
dialog.

The callback receives the same `GeneratedStickerAsset` shape:

- `stickerBytes`: the final generated sticker PNG bytes after background
  removal and transparent-padding crop
- `stickerId`: the selected sticker style ID when available
- `createdAt`: the sticker creation time when available
- `label`: optional display label

Only completed generated stickers are exposed. The original flower photo is not
passed to Diary, and Profile does not create diary entries or own Diary storage.
