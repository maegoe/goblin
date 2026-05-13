# Goblin Dev Orchestrator Trigger Tests

## Should Trigger

- `KAN-7 구현해줘`
- `KAN-13 버그 수정 진행해줘`
- `이 Jira 티켓 기준으로 코드 변경하고 QA까지 해줘`
- `V0.3 범위 폭발 공격 성장 구현 이어서 해줘`
- `이전 KAN-7 작업 QA만 다시 돌려줘`
- `현재 브랜치 변경사항을 Confluence/Jira에 반영해줘`
- `KAN-5 리뷰 결과 반영해서 다시 수정해줘`
- `Roblox Studio MCP로 이번 티켓 검증해줘`
- `KAN-12에서 Roblox UI 버튼 상태 문서 확인하고 구현 방향 잡아줘`
- `KAN-16 구현 전에 용어랑 acceptance criteria 정리하고 plan grill 해줘`
- `V0.4 camp 시스템 구현 task contract까지 잡고 시작해줘`
- `이 티켓 모듈 구조가 애매하니 architecture design 먼저 해줘`
- `레벨업 UI UX 리뷰와 이미지 목업까지 포함해서 KAN-8 진행해줘`
- `KAN-8 레벨업 UI 디자인 brief부터 잡고 구현 가이드까지 정리해줘`
- `캠프 UI 세트 디자인 spec 산출물 만든 뒤 KAN-16 구현 방향 잡아줘`
- `Rojo 최신 build 옵션 찾아보고 이 티켓 구현해줘`
- `HUD 모바일 가독성 디자인 검토하고 목업 이미지 생성해줘`
- `이전 design-brief.md 기반으로 UI UX만 partial rerun 해줘`
- `이전 artifact 기반으로 partial rerun 해줘`
- `이번 KAN-13 수정에서 배운 점 compound learning으로 남겨줘`
- `QA 반복 실패 원인과 재사용 가능한 검증 패턴을 close the loop 해줘`
- `ticket 기반 개발 harness로 진행해줘`

## Should Not Trigger

- `새 Jira 티켓 하나 만들어줘` unless the user explicitly asks to use the harness for ticket creation.
- `V0.5 아이디어 문서 초안 작성해줘` unless code-development execution is requested.
- `Confluence에 새 피처 스펙 만들어줘` unless explicitly requested as documentation work.
- `일반 agent-team planning grill 사용법 알려줘`
- `이 Lua 문법이 뭐야?`
- `README만 요약해줘`
- `이미지 asset 만들어줘`
- `디자인 인터뷰만 하고 코드 작업은 하지 말자`
- `로블록스 API 최신 문서 찾아줘`
- `일반적인 게임 UI 트렌드 조사해줘`
- `새 HUD 아트 asset 요청 티켓 만들어줘`
- `git status 보여줘`
- `게임 아이디어 브레인스토밍하자`
- `아직 구현 중인데 배운 점 문서화부터 해줘`
- `AGENTS.md 규칙 설명해줘`

## Boundary Notes

- Existing-ticket implementation triggers this orchestrator.
- Planner persona usage is inside scoped Goblin ticket planning; generic planning advice does not trigger this orchestrator.
- Compound learning triggers only after completed non-trivial work or when the user asks to capture lessons from a completed run.
- Ticket creation and initial Confluence spec work are outside the default route.
- Delivery recording after code and QA is inside the route.
