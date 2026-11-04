# my-upstream-merge

This branch is the copy to try in game. It is current upstream (2.10.2) plus the local fixes that were already working on the 2.9.14 running copy.

`my-running-copy` is the untouched snapshot of that 2.9.14 copy, kept so this merge can be dropped.

## Kept from upstream

- Per-character Show, Ignore, and Delete. Ignore still skips storing that character.
- Filter button opens that character page.
- Remote vault scales `WeeklyRewardsRemoteFrame` (2.9.15).
- PvP tooltip returns when tier info is missing.

## Kept from the running copy

- Highest vault ilvl is resolved from LibGearData when the example item link is not cached. The column stays empty when nothing is unlocked, and keeps the last saved ilvl only while a slot is still unlocked.
- `WEEKLY_REWARDS_UPDATE` always registers. A claimable vault sets `skipStore` and does not clear the activity cache. Otherwise the cache is cleared, data is stored, and an open list refreshes. This is the behavior that stayed consistent across claiming a reward and starting a new week. Upstream 2.10.1 (`2028e02`) is not used. It clears the cache during the claim window and does not refresh the list.
- Settings variables are prefixed (`GreatVaultList_floatNumber`, `GreatVaultList_useClassColors`, and the rest). Callbacks use `SetOnValueChangedCallback` on 12.0.
- Column modules set `loaded`, and `checkModules` waits only on those modules, so the login store actually runs.
- `updateData` returns when columns are not loaded yet instead of asserting.
- Options init runs once.

## Not carried over

- The old character-delete dropdown. The character page replaced it.
- The in-list show/hide filter menu.
- Hardcoded addon version and editor settings.
