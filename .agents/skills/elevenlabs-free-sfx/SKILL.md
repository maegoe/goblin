---
name: elevenlabs-free-sfx
description: Generate short Goblin V1.0/KAN-76 sound-effect candidates with the ElevenLabs Sound Effects API on the Free plan. Use when Codex needs to create QA/draft SFX files for player hit, enemy hit, enemy death, level up, upgrade select, reward gain, or camp purchase before KAN-75 Asphalt upload and KAN-66 runtime hookup.
---

# ElevenLabs Free SFX

## Purpose

Generate KAN-76 SFX candidates with minimum cost using ElevenLabs Sound Effects. Treat Free-plan output as QA/draft material until commercial usage rights are confirmed or a paid plan is used for the final release candidate.

This skill only generates local audio candidates. KAN-75 owns Asphalt upload. KAN-66 owns runtime playback and fallback behavior.

## Workflow

1. Read `references/kan76-prompts.md` when event prompts, durations, or filenames need review.
2. Confirm `ELEVENLABS_API_KEY` is available in the environment or in the project root `.env`.
3. Run `scripts/generate_sfx.py` with `--dry-run` before real generation.
4. Generate one event first, listen/QA it, then generate the rest if the style is acceptable.
5. Record generated outputs as QA/draft candidates. Do not mark KAN-76 complete until final usage rights and delivery metadata are recorded.

## Commands

Dry-run every KAN-76 event without an API key:

```powershell
python .agents/skills/elevenlabs-free-sfx/scripts/generate_sfx.py --all-kan76 --dry-run
```

Generate one candidate:

```powershell
python .agents/skills/elevenlabs-free-sfx/scripts/generate_sfx.py --event player_hit --variant 01
```

Generate all seven KAN-76 candidates:

```powershell
python .agents/skills/elevenlabs-free-sfx/scripts/generate_sfx.py --all-kan76
```

Override the default prompt or duration:

```powershell
python .agents/skills/elevenlabs-free-sfx/scripts/generate_sfx.py --event reward_gain --duration 0.8 --prompt "short bright fantasy coin reward pickup, clean, no voice, no music"
```

## Environment

Use the project root `.env` file:

```env
ELEVENLABS_API_KEY=your_elevenlabs_api_key_here
```

Never commit `.env`. The project `.gitignore` excludes it. Keep `.env.example` as the shareable template.

## Output Contract

- Audio files are written under `assets/audio/v1_0/...`.
- Default generated format is MP3 because ElevenLabs returns MP3 from the Sound Effects endpoint and MP3 is supported by Asphalt/Roblox.
- Each successful generation appends metadata to `_workspace/goblin-dev/sfx-generation-manifest.jsonl`.
- Manifest entries must include `status: "free-plan-qa-candidate"` and must not be treated as final release clearance.

## Guardrails

- Prefer short SFX durations. ElevenLabs duration override costs API credits per second, and the API minimum is 0.5 seconds.
- Avoid prompts that mention existing games, known franchises, copyrighted sounds, voice lines, trademarks, or sampled media.
- If the output will ship publicly, verify commercial-use rights before finalizing KAN-76 delivery.

## References

- ElevenLabs sound generation API: https://elevenlabs.io/docs/api-reference/text-to-sound-effects/convert
- ElevenLabs SFX credit cost: https://help.elevenlabs.io/hc/en-us/articles/25735337678481-How-much-does-it-cost-to-generate-sound-effects
- ElevenLabs pricing and commercial license tiers: https://elevenlabs.io/pricing
