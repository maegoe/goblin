# AGENTS.md

## Project Context

Before starting implementation or documentation work, read the Atlassian Confluence content in the `maegoe` workspace, `roblox` space, especially the Goblin project pages relevant to the current task.

Use the roadmap and version-specific pages as the source of truth for scope. For V0.2 work, read `V0.2 - 플레이어블 코어` and its linked feature documents before changing code or documents.

Use Jira for execution tracking. Before starting scoped implementation, QA, documentation, or planning work, find or create the relevant Jira issue in the `goblin` project (`KAN`) and link it to the corresponding Confluence roadmap, version, or feature page.

Confluence remains the source of truth for roadmap scope, feature specs, and completion criteria. Jira issues track execution state, ownership, QA, bugs, and follow-up work; they must not expand scope beyond the roadmap or version-specific Confluence pages.

## Scope Discipline

Avoid adding product design beyond the roadmap version plan. If an idea is outside the current version scope, record it as a future-version candidate instead of implementing it or expanding the current spec.

Do not broaden the current version with new systems, test harnesses, automation, balancing features, or product mechanics unless the roadmap or the user explicitly asks for that work in the current version.

If a Jira issue suggests work outside the current Confluence roadmap scope, do not implement it directly. Update or create a future-version candidate in Confluence first, then adjust Jira only after the scope is accepted.

## Design Requests

For UI art, icon, HUD, card, button, panel, or other design asset work, use the Confluence `UI 디자인 산출물 가이드` as the source of truth before creating Jira tickets.

Create Jira design request tickets from that guide instead of inventing ad hoc asset requirements. Each design Jira ticket should include the related Confluence link, target version, screen/component, purpose, requested filename, recommended size, extension, transparency requirement, 9-slice requirement, required states, priority, design token needs, and Roblox asset id handoff expectations.

Do not add design files, original assets, or PNGs to the Git repo unless the roadmap, design guide, or user explicitly asks for repository-managed assets. Track design originals, PNG delivery, Roblox asset ids, applied code/commit, and verification status in Confluence and Jira.

When a delivered design asset is applied in code, update the Jira ticket and the Confluence delivery table with the Roblox asset id, applied code or commit, PC/mobile verification result, and any follow-up issues.

## QA Testing

Use Roblox Studio MCP for QA testing when possible. Prefer opening the built place in Roblox Studio, starting/stopping Play, reading console output, and inspecting runtime state through the MCP tools before asking for manual verification.

Keep QA focused on the current roadmap version's completion criteria. Do not add new test harnesses or automation code unless that work is explicitly in scope for the current version.

Record QA results on the relevant Jira issue as well as in Confluence. Bugs found during QA should be created or linked in Jira and classified against the Confluence bug severity and scope rules before implementation.

## Work Logging

After completing any implementation, QA, documentation, or planning work, always update Confluence before considering the task done.

Record the work in `CHANGELOG`, and also update the relevant roadmap version page or version-specific work page with the result, status, and checklist changes. If the work changes scope, implementation status, QA status, or follow-up tasks, make that explicit in the related Confluence page.

Also update the related Jira issue before considering the task done. Add the result, QA notes, Confluence links, and follow-up issues when relevant; move the issue status only when the Confluence documentation and `CHANGELOG` have already been updated.
