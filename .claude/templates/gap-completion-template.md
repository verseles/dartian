# Gap Completion Template

Use this template when marking a gap as complete in PLAN.md.

## Status Update

```markdown
### Gap #X: [Title] ✅ COMPLETO

**Pacote:** [package_name]
**Status:** ✅ COMPLETO - [Brief completion description]
**Impacto:** RESOLVIDO - [How it improves the project]
**Tempo gasto:** ~X horas (sessão YYYY-MM-DD)

**Tarefas:**

1. ✅ **[Main Task 1]:**
   - ✅ [Subtask 1.1]
   - ✅ [Subtask 1.2]
   - ✅ [Subtask 1.3]

2. ✅ **[Main Task 2]:**
   - ✅ [Subtask 2.1]
   - ✅ [Subtask 2.2]

**Validação:**
```bash
cd packages/[package_name]
dart pub get                      # ✅ PASSOU
dart test                         # ✅ X testes passando
dart analyze                      # ✅ PASSOU
```

**Cobertura de testes:** ~X%
**Commit:** `[hash]` - "[commit message]"
```

## Learnings Entry

Add to "LIÇÕES APRENDIDAS" section:

```markdown
**X. [Topic] (Gap #X - YYYY-MM-DD)**

[Key learning description]

[Example code or pattern]

**Solução**: [How to handle this in future]
```

## Progress Update

Update the progress section:

```markdown
**Sprint X:** ✅ 100% COMPLETO!
  - ✅ Gap #X: [Title] COMPLETO
    - ✅ [Key achievement 1]
    - ✅ [Key achievement 2]
    - ✅ [Key achievement 3]
    - ✅ Commit [hash] pushed
```

## Checklist Before Marking Complete

- [ ] All tests passing (dart test)
- [ ] Static analysis clean (dart analyze)
- [ ] Coverage >= 95% (or documented exception)
- [ ] Code formatted (dart format)
- [ ] Commit created with descriptive message
- [ ] Commit pushed to remote
- [ ] PLAN.md status updated to ✅ COMPLETO
- [ ] Progress percentage updated
- [ ] Sprint status updated
- [ ] Learnings documented (if applicable)
- [ ] Time spent recorded
