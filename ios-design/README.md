# iOS Design & Architecture

## Purpose

This directory contains comprehensive documentation for AWAVE's iOS native application design and architecture, following industry best practices and software engineering principles.

---

## Document Index

### Core Architecture

| Document | Description |
|----------|-------------|
| [01-architecture-patterns.md](./01-architecture-patterns.md) | Comparison of iOS architecture patterns (MVC, MVVM, TCA, VIPER, Clean) |
| [02-recommended-architecture.md](./02-recommended-architecture.md) | AWAVE's chosen architecture with justification |
| [03-module-structure.md](./03-module-structure.md) | Swift Package organization and dependencies |
| [04-dependency-injection.md](./04-dependency-injection.md) | DI strategies and implementation |

### Design Patterns & Practices

| Document | Description |
|----------|-------------|
| [05-design-patterns.md](./05-design-patterns.md) | GoF and iOS-specific patterns applied to AWAVE |
| [06-state-management.md](./06-state-management.md) | State management approaches comparison |
| [07-concurrency-patterns.md](./07-concurrency-patterns.md) | Swift concurrency and async patterns |
| [08-error-handling.md](./08-error-handling.md) | Error handling strategies |

### Quality & Standards

| Document | Description |
|----------|-------------|
| [09-testing-strategy.md](./09-testing-strategy.md) | Testing pyramid, strategies, and coverage |
| [10-code-standards.md](./10-code-standards.md) | Swift style guide and conventions |
| [11-performance-guidelines.md](./11-performance-guidelines.md) | Performance optimization principles |

### Minibook (LLM Verification)

| Document | Description |
|----------|-------------|
| [minibook/](./minibook/) | Context, prompts, and matrices for LLM verification |

---

## Architecture Decision Summary

### Chosen Architecture: **Modular MVVM + Clean Architecture Hybrid**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        AWAVE iOS Architecture                                │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      Presentation Layer                              │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────┐  │   │
│  │  │  SwiftUI    │  │ @Observable │  │     Coordinator            │  │   │
│  │  │   Views     │◄─│  ViewModels │◄─│     (Navigation)           │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                      │                                      │
│                                      ▼                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Domain Layer                                  │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────┐  │   │
│  │  │   Entities  │  │  Use Cases  │  │  Repository Protocols       │  │   │
│  │  │   (Models)  │  │  (Business) │  │  (Interfaces)               │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                      │                                      │
│                                      ▼                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         Data Layer                                   │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────┐  │   │
│  │  │  SwiftData  │  │  Firestore  │  │  Audio File Manager         │  │   │
│  │  │   (Local)   │  │  (Remote)   │  │  (Cache)                    │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Why This Architecture?

| Principle | How Architecture Supports It |
|-----------|------------------------------|
| **Separation of Concerns** | Clear layer boundaries, single responsibility |
| **Testability** | Protocol-based DI, mockable dependencies |
| **Scalability** | Modular packages, independent feature development |
| **Maintainability** | Consistent patterns, clear data flow |
| **Flexibility** | Repository pattern abstracts data sources |

---

## Key Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| UI Framework | SwiftUI | Modern, declarative, native iOS integration |
| State Management | @Observable | Simpler than Combine, SwiftUI native |
| Architecture | MVVM + Clean | Balance of simplicity and scalability |
| DI Approach | Environment + Factory | SwiftUI native, testable |
| Navigation | Coordinator Pattern | Centralized, testable navigation |
| Persistence | SwiftData | Modern, Swift-native, automatic sync |
| Networking | Async/Await | Modern Swift concurrency |
| Modularity | Swift Packages | Fast builds, clear boundaries |

---

## Software Engineering Principles Applied

### SOLID Principles

| Principle | Application in AWAVE |
|-----------|---------------------|
| **S**ingle Responsibility | Each ViewModel handles one screen's logic |
| **O**pen/Closed | Protocol extensions for default behavior |
| **L**iskov Substitution | Repository protocols with interchangeable implementations |
| **I**nterface Segregation | Small, focused protocols (SoundFetching, SoundCaching) |
| **D**ependency Inversion | Domain depends on abstractions, not concretions |

### Additional Principles

| Principle | Application |
|-----------|-------------|
| **DRY** | Shared components, design system |
| **KISS** | Avoid over-engineering, pragmatic choices |
| **YAGNI** | Build for current needs, not hypothetical futures |
| **Composition over Inheritance** | Protocol composition, value types |
| **Fail Fast** | Early validation, clear error handling |

---

## Quick Reference

### Layer Dependencies

```
Views → ViewModels → Use Cases → Repositories → Data Sources
  ↓         ↓            ↓             ↓              ↓
Display   State      Business      Data Access    External
  UI     Logic        Rules        Abstraction    Systems
```

### File Organization

```
AWAVE/
├── App/                    # App entry, configuration
├── Features/               # Feature modules
│   ├── Home/
│   ├── Player/
│   └── ...
├── Core/                   # Shared utilities
├── Domain/                 # Business logic
├── Data/                   # Data layer
└── DesignSystem/          # UI components
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Views | `{Feature}View` | `PlayerView` |
| ViewModels | `{Feature}ViewModel` | `PlayerViewModel` |
| Use Cases | `{Action}{Entity}UseCase` | `PlaySoundMixUseCase` |
| Repositories | `{Entity}Repository` | `SoundRepository` |
| Protocols | `{Capability}Protocol` or just capability | `SoundFetching` |

---

## Getting Started

1. Read [01-architecture-patterns.md](./01-architecture-patterns.md) for context
2. Study [02-recommended-architecture.md](./02-recommended-architecture.md) for AWAVE specifics
3. Review [minibook/](./minibook/) to verify understanding with LLM prompts
