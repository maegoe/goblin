#!/usr/bin/env python3
"""Generate KAN-76 SFX candidates with ElevenLabs Sound Effects."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
from urllib import error, request

EVENTS = {
    "player_hit": {
        "category": "combat",
        "duration": 0.6,
        "prompt": "short fantasy game player damage impact, soft body hit with small armor rattle, urgent but not gory, no voice, no music, clean transient",
    },
    "enemy_hit": {
        "category": "combat",
        "duration": 0.5,
        "prompt": "tiny fantasy creature hit impact, quick squishy thud with light wood snap, satisfying attack feedback, no voice, no music, low fatigue",
    },
    "enemy_death": {
        "category": "combat",
        "duration": 0.8,
        "prompt": "small fantasy enemy defeated poof, soft burst and crumble, clear kill confirmation, no voice, no music, not scary",
    },
    "level_up": {
        "category": "ui",
        "duration": 1.2,
        "prompt": "bright fantasy level up chime, short rising magical sparkle, rewarding and clear, no voice, no melody loop, clean mobile game UI",
    },
    "upgrade_select": {
        "category": "ui",
        "duration": 0.5,
        "prompt": "short UI upgrade select confirmation, crisp wooden click with tiny magical sparkle, positive, no voice, no music",
    },
    "reward_gain": {
        "category": "ui",
        "duration": 0.8,
        "prompt": "short reward pickup sound, small coins and soft sparkle, satisfying but not loud, no voice, no music, clean transient",
    },
    "camp_purchase": {
        "category": "camp",
        "duration": 1.0,
        "prompt": "fantasy camp upgrade purchase success, warm wooden thunk with small celebratory chime, permanent growth feeling, no voice, no music",
    },
}


def find_project_root(start: Path) -> Path:
    for directory in [start, *start.parents]:
        if (directory / "default.project.json").exists() or (directory / "asphalt.toml").exists():
            return directory
    raise SystemExit("Could not find project root containing default.project.json or asphalt.toml.")


def load_env_file(project_root: Path) -> None:
    env_path = project_root / ".env"
    if not env_path.exists():
        return

    for raw_line in env_path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def output_path(project_root: Path, event: str, variant: str) -> Path:
    category = EVENTS[event]["category"]
    filename = f"{event}_{variant}.mp3"
    return project_root / "assets" / "audio" / "v1_0" / category / filename


def build_payload(event: str, duration: float, prompt: str, prompt_influence: float) -> bytes:
    payload = {
        "text": prompt,
        "duration_seconds": duration,
        "prompt_influence": prompt_influence,
        "model_id": "eleven_text_to_sound_v2",
    }
    return json.dumps(payload).encode("utf-8")


def call_elevenlabs(api_key: str, payload: bytes) -> bytes:
    req = request.Request(
        "https://api.elevenlabs.io/v1/sound-generation",
        data=payload,
        headers={
            "xi-api-key": api_key,
            "Content-Type": "application/json",
            "Accept": "audio/mpeg",
        },
        method="POST",
    )

    try:
        with request.urlopen(req, timeout=120) as response:
            return response.read()
    except error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise SystemExit(f"ElevenLabs API error {exc.code}: {body}") from exc
    except error.URLError as exc:
        raise SystemExit(f"ElevenLabs request failed: {exc}") from exc


def append_manifest(project_root: Path, record: dict[str, object]) -> None:
    manifest_path = project_root / "_workspace" / "goblin-dev" / "sfx-generation-manifest.jsonl"
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    with manifest_path.open("a", encoding="utf-8") as manifest:
        manifest.write(json.dumps(record, ensure_ascii=False, sort_keys=True) + "\n")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate KAN-76 SFX candidates with ElevenLabs.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--event", choices=sorted(EVENTS), help="Single KAN-76 event to generate.")
    group.add_argument("--all-kan76", action="store_true", help="Generate all seven KAN-76 events.")
    parser.add_argument("--variant", default="01", help="Two-digit variant suffix. Default: 01.")
    parser.add_argument("--duration", type=float, help="Override duration in seconds. ElevenLabs minimum is 0.5.")
    parser.add_argument("--prompt", help="Override the default event prompt.")
    parser.add_argument("--prompt-influence", type=float, default=0.3, help="Prompt influence from 0 to 1. Default: 0.3.")
    parser.add_argument("--dry-run", action="store_true", help="Print planned outputs without calling the API.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project_root = find_project_root(Path(__file__).resolve())
    events = list(EVENTS) if args.all_kan76 else [args.event]

    if not args.dry_run:
        load_env_file(project_root)
        api_key = os.environ.get("ELEVENLABS_API_KEY", "").strip()
        if not api_key or api_key == "your_elevenlabs_api_key_here":
            raise SystemExit(
                "Missing ELEVENLABS_API_KEY. Add it to the environment or to "
                f"{project_root / '.env'} as ELEVENLABS_API_KEY=your_key."
            )
    else:
        api_key = ""

    for event in events:
        prompt = args.prompt or EVENTS[event]["prompt"]
        duration = args.duration if args.duration is not None else EVENTS[event]["duration"]
        if duration < 0.5:
            raise SystemExit("duration must be at least 0.5 seconds for the ElevenLabs API.")

        target = output_path(project_root, event, args.variant)
        print(f"{event}: {duration}s -> {target}")
        print(f"prompt: {prompt}")

        if args.dry_run:
            continue

        audio = call_elevenlabs(api_key, build_payload(event, duration, prompt, args.prompt_influence))
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(audio)
        append_manifest(
            project_root,
            {
                "event": event,
                "variant": args.variant,
                "duration_seconds": duration,
                "prompt": prompt,
                "output_path": str(target.relative_to(project_root)).replace("\\", "/"),
                "format": "mp3",
                "status": "free-plan-qa-candidate",
                "commercial_use": "not-cleared",
                "created_at": datetime.now(timezone.utc).isoformat(),
                "source": "ElevenLabs Sound Effects API",
            },
        )


if __name__ == "__main__":
    main()
