# KAN-76 ElevenLabs SFX Prompts

These prompts generate QA/draft candidates for the V1.0 combat feedback SFX request. Final release use requires license/commercial-use confirmation.

| Event | Output path | Duration | Prompt |
| --- | --- | ---: | --- |
| `player_hit` | `assets/audio/v1_0/combat/player_hit_01.mp3` | 0.6 | `short fantasy game player damage impact, soft body hit with small armor rattle, urgent but not gory, no voice, no music, clean transient` |
| `enemy_hit` | `assets/audio/v1_0/combat/enemy_hit_01.mp3` | 0.5 | `tiny fantasy creature hit impact, quick squishy thud with light wood snap, satisfying attack feedback, no voice, no music, low fatigue` |
| `enemy_death` | `assets/audio/v1_0/combat/enemy_death_01.mp3` | 0.8 | `small fantasy enemy defeated poof, soft burst and crumble, clear kill confirmation, no voice, no music, not scary` |
| `level_up` | `assets/audio/v1_0/ui/level_up_01.mp3` | 1.2 | `bright fantasy level up chime, short rising magical sparkle, rewarding and clear, no voice, no melody loop, clean mobile game UI` |
| `upgrade_select` | `assets/audio/v1_0/ui/upgrade_select_01.mp3` | 0.5 | `short UI upgrade select confirmation, crisp wooden click with tiny magical sparkle, positive, no voice, no music` |
| `reward_gain` | `assets/audio/v1_0/ui/reward_gain_01.mp3` | 0.8 | `short reward pickup sound, small coins and soft sparkle, satisfying but not loud, no voice, no music, clean transient` |
| `camp_purchase` | `assets/audio/v1_0/camp/camp_purchase_01.mp3` | 1.0 | `fantasy camp upgrade purchase success, warm wooden thunk with small celebratory chime, permanent growth feeling, no voice, no music` |

Notes:

- KAN-76 asks for wav/ogg as preferred handoff formats, but MP3 candidates are acceptable for this ElevenLabs Free workflow because Asphalt and Roblox support `.mp3`.
- ElevenLabs duration override currently has a 0.5-second minimum, so very short events use 0.5 seconds.
