# AGENTS.md

## Project Context

Before starting implementation or documentation work, read the Atlassian Confluence content in the `maegoe` workspace, `roblox` space, especially the Goblin project pages relevant to the current task.

Use the roadmap and version-specific pages as the source of truth for scope. For V0.2 work, read `V0.2 - 플레이어블 코어` and its linked feature documents before changing code or documents.

## Scope Discipline

Avoid adding product design beyond the roadmap version plan. If an idea is outside the current version scope, record it as a future-version candidate instead of implementing it or expanding the current spec.

Do not broaden the current version with new systems, test harnesses, automation, balancing features, or product mechanics unless the roadmap or the user explicitly asks for that work in the current version.

## QA Testing

Use Roblox Studio MCP for QA testing when possible. Prefer opening the built place in Roblox Studio, starting/stopping Play, reading console output, and inspecting runtime state through the MCP tools before asking for manual verification.

Keep QA focused on the current roadmap version's completion criteria. Do not add new test harnesses or automation code unless that work is explicitly in scope for the current version.
