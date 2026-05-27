# goblin

Rojo-first Roblox game project with GitHub Actions deployment to Roblox Open Cloud.

## Project structure

- `default.project.json`: Rojo project definition
- `src/server`: content synced into `ServerScriptService`
- `src/client`: content synced into `StarterPlayer.StarterPlayerScripts`
- `src/shared`: content synced into `ReplicatedStorage`
- `assets`: repository-managed non-code assets
- `.github/workflows/validate.yml`: pull request build validation
- `.github/workflows/deploy.yml`: automatic deployment on `main`

## Local development

1. Install Rokit.
2. Install project tools:

```powershell
rokit install
```

3. Start the Rojo sync server:

```powershell
rojo serve
```

4. In Roblox Studio, connect with the Rojo plugin.

## Local build

Build a binary place file locally:

```powershell
New-Item -ItemType Directory -Force build | Out-Null
rojo build default.project.json -o build/game.rbxl
```

## Audio asset pipeline

V1.0 sound assets use Asphalt separately from the Tarmac PNG pipeline.

- Source handoff path: `assets/audio/{version}/{category}/{event}_{variant}.{ext}`
- Current input glob: `assets/audio/**/*`
- Generated Luau module: `src/shared/AudioAssets.luau`
- Creator: Roblox group `738487850`
- Required API key env var: `ASPHALT_API_KEY`
- Required Open Cloud permissions: `asset:read`, `asset:write`
- Supported audio formats: `.mp3`, `.ogg`, `.wav`, `.flac`

Install tools:

```powershell
rokit install
```

Inspect processed files without uploading:

```powershell
asphalt sync debug
```

Check whether cloud assets are current without uploading:

```powershell
$env:ASPHALT_API_KEY = "<roblox-open-cloud-api-key>"
asphalt sync cloud --dry-run
```

Upload delivered audio assets and generate `AudioAssets.luau`:

```powershell
$env:ASPHALT_API_KEY = "<roblox-open-cloud-api-key>"
asphalt sync cloud
```

After a successful cloud sync, commit `asphalt.lock.toml` and `src/shared/AudioAssets.luau`. Do not commit `.env`, API keys, or raw handoff audio unless the Confluence sound deliverables guide explicitly says to store that batch in Git. Roblox audio moderation, creator permissions, and monthly quota can block upload even when the local pipeline is valid.

## GitHub Actions setup

Create a GitHub Environment named `production`.

Add these values:

- Secret: `ROBLOX_API_KEY`
- Variable: `ROBLOX_UNIVERSE_ID`
- Variable: `ROBLOX_PLACE_ID`

Recommended Roblox setup:

- Use a dedicated automation Roblox account
- Grant it only the group permissions needed to update the target experience
- Create an Open Cloud API key with:
  - API system: `universe-places`
  - Operation: `Write`
  - Access restricted to the target experience when possible

## Deployment flow

- Pull requests and manual validation runs execute `validate.yml`
- Pushes to `main` execute `deploy.yml`
- Deployment builds `build/game.rbxl` and uploads it through Roblox Open Cloud Place Publishing

## Operational notes

- The Place Publishing API may not fully update `EditableImage`, `EditableMesh`, `PartOperation`, `SurfaceAppearance`, or `BaseWrap`. Use Roblox Studio publish flow when those assets change.
- If an update must reach live players immediately, restart outdated servers after deployment.
- For the first live test, point deployment at a private or test place before promoting the workflow to production traffic.
