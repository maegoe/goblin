# goblin

Rojo-first Roblox game project with GitHub Actions deployment to Roblox Open Cloud.

## Project structure

- `default.project.json`: Rojo project definition
- `src/server`: content synced into `ServerScriptService`
- `src/client`: content synced into `StarterPlayer.StarterPlayerScripts`
- `src/shared`: content synced into `ReplicatedStorage`
- `assets`: repository-managed non-code assets
- `.github/workflows/validate.yml`: pull request build validation
- `.github/workflows/deploy.yml`: automatic deployment on `main` and `dev`

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

Create GitHub Environments named `production` and `development`.

For `production`, add these values:

- Secret: `ROBLOX_OPEN_CLOUD_API_KEY`
- Variable: `ROBLOX_UNIVERSE_ID`
- Variable: `ROBLOX_PLACE_ID`

For `development`, add these values:

- Secret: `ROBLOX_OPEN_CLOUD_API_KEY`
- Variable: `ROBLOX_UNIVERSE_ID`
- Variable: `ROBLOX_DEV_PLACE_ID`

Recommended Roblox setup:

- Use a dedicated automation Roblox account
- Grant it only the group permissions needed to update the target experience
- Create an Open Cloud API key with:
  - API system: `universe-places`
  - Operation: `Write`
  - Access restricted to the target experience when possible

Development place setup:

- `ROBLOX_DEV_PLACE_ID` must point to a separate non-production place in the same target universe.
- Roblox Open Cloud Place Publishing publishes a new version to an existing place with `POST /universes/v1/{universeId}/places/{placeId}/versions`.
- A development place can be created by running `AssetService:CreatePlaceAsync(placeName, templatePlaceId, description)` through Open Cloud Luau Execution against an existing place in the universe.
- The Open Cloud key used for creation must include Luau Execution write permission for the universe/place, such as `universe.place.luau-execution-session:write`, in addition to `universe-places` `Write` for deployment.
- After the place is created, store the new place id as `ROBLOX_DEV_PLACE_ID`.

## Deployment flow

- Pull requests and manual validation runs execute `validate.yml`
- Pushes to `dev` execute `deploy.yml` against the development place
- Pushes to `main` execute `deploy.yml` against the production place
- Deployment builds `build/game.rbxl` and uploads it through Roblox Open Cloud Place Publishing

## Operational notes

- The Place Publishing API may not fully update `EditableImage`, `EditableMesh`, `PartOperation`, `SurfaceAppearance`, or `BaseWrap`. Use Roblox Studio publish flow when those assets change.
- If an update must reach live players immediately, restart outdated servers after deployment.
- For the first live test, point deployment at a private or test place before promoting the workflow to production traffic.
