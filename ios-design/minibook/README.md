# Minibook: LLM Verification Guide

## Purpose

This minibook provides structured context and prompts for verifying AWAVE's iOS architecture decisions using Large Language Models. It enables:

1. **Architecture validation** - Verify patterns are correctly applied
2. **Trade-off analysis** - Explore alternatives and their implications
3. **Best practice checking** - Ensure alignment with industry standards
4. **Knowledge transfer** - Onboard team members via Q&A

---

## Document Index

| Document | Purpose |
|----------|---------|
| [01-context.md](./01-context.md) | Complete project context for LLM |
| [02-architecture-matrix.md](./02-architecture-matrix.md) | Detailed pattern comparisons |
| [03-verification-prompts.md](./03-verification-prompts.md) | Ready-to-use verification prompts |
| [04-trade-off-analysis.md](./04-trade-off-analysis.md) | Deep dive on architectural trade-offs |
| [05-principles-checklist.md](./05-principles-checklist.md) | Software engineering principles verification |
| [06-decision-records.md](./06-decision-records.md) | Architecture Decision Records (ADRs) |

---

## How to Use This Minibook

### Step 1: Load Context

Copy the contents of `01-context.md` as the first message to the LLM. This provides full project background.

### Step 2: Ask Verification Questions

Use prompts from `03-verification-prompts.md` to verify specific aspects:

```
[Paste context from 01-context.md]

Now, please verify: [Paste specific prompt]
```

### Step 3: Explore Trade-offs

Use `04-trade-off-analysis.md` to understand why certain decisions were made and what alternatives exist.

### Step 4: Check Principles

Use `05-principles-checklist.md` to verify alignment with SOLID, DRY, and other engineering principles.

---

## Quick Verification Prompts

### Architecture Validation
```
Given the AWAVE context, verify that the MVVM + Clean Architecture hybrid
is appropriate for a multi-track audio mixing app. Consider:
1. Testability requirements for audio logic
2. SwiftUI integration patterns
3. Offline-first data synchronization
4. Real-time waveform visualization
```

### Pattern Correctness
```
Review the Repository pattern implementation in AWAVE. Check:
1. Does it properly abstract data sources?
2. Is the protocol design appropriate?
3. Are there any dependency inversions violated?
4. How should sync strategies be integrated?
```

### Performance Considerations
```
Analyze the audio engine architecture for potential performance issues:
1. Actor isolation for thread safety
2. Memory management for 7 simultaneous tracks
3. Latency in the playback pipeline
4. Background audio handling
```

---

## Model Recommendations

| LLM | Best For |
|-----|----------|
| Claude (Opus/Sonnet) | Deep architecture analysis, trade-off reasoning |
| GPT-4 | Code review, pattern validation |
| Gemini | Swift-specific best practices |

---

## Example Verification Session

```markdown
# Session: Verify Repository Pattern

## Context Provided
[Contents of 01-context.md]

## Question Asked
"Verify the Repository pattern implementation. Is SyncedRepository
a good approach for combining local SwiftData and remote Firestore?"

## LLM Response Analysis
- Confirms pattern is appropriate ✓
- Suggests adding conflict resolution strategy ✓
- Recommends async stream for sync status updates ✓
- Identifies potential race condition in merge logic ⚠️

## Action Items
1. Add ConflictResolutionStrategy protocol
2. Implement AsyncStream<SyncStatus> in SyncEngine
3. Review merge logic for thread safety
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024-01 | Initial minibook creation |
