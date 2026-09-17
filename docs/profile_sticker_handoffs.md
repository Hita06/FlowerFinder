# Profile Sticker Handoffs

Profile owns the generated-sticker handoff point. Other features should connect
through optional callbacks on `UserProfilePage` instead of importing Profile
internals or reading original flower photos.

## Sharing

Use `UserProfilePage.onShareSticker`.

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

The callback receives the same `GeneratedStickerAsset` shape:

- `stickerBytes`: the final generated sticker PNG bytes after background
  removal and transparent-padding crop
- `stickerId`: the selected sticker style ID when available
- `createdAt`: the sticker creation time when available
- `label`: optional display label

Only completed generated stickers are exposed. The original flower photo is not
passed to Diary, and Profile does not create diary entries or own Diary storage.
