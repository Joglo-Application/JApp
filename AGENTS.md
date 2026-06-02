# Flutter POS Project

Tech Stack:
- Flutter latest stable
- Provider
- Local Database (future migration to API)
- Material 3
- Go Router

Rules:
- No hardcoded colors
- No hardcoded spacing
- No inline TextStyle
- No business logic in UI
- Extract reusable widgets
- Use const whenever possible

Architecture:
lib/
├── core/
│   ├── theme/
│   └── constants/
│
├── features/
│
└── shared/