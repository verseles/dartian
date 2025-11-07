# PLANO DE EXECUÇÃO AUTÔNOMO – DARTIAN MVP

**Status Atual:** 78% Completo | **Meta:** 100% Production-Ready
**Progresso:** Fase 0-11 parcialmente completas | **Restante:** 6 gaps críticos + cobertura de testes

---

## 🎯 OBJETIVO

Completar o Dartian Framework para produção seguindo rigorosamente este plano.
**Para executar:** Diga apenas "Execute o PLAN.md" e o assistente continuará autonomamente.

---

## 🔧 AMBIENTE E FERRAMENTAS

### Detecção de Sistema Operacional

```bash
# Detectar OS
if [ -f /etc/arch-release ]; then
  OS="arch"
  PKG_MANAGER="paru"
elif [ -f /etc/debian_version ]; then
  OS="debian"
  PKG_MANAGER="apt"
else
  echo "⚠️  Sistema não suportado. Use Arch Linux ou Debian/Ubuntu."
  exit 1
fi
```

### Instalação de Dependências por Sistema

#### Arch Linux (paru)
```bash
paru -Syu --noconfirm
paru -S --needed --noconfirm dart podman podman-compose github-cli wasmtime
```

#### Debian/Ubuntu (apt)
```bash
sudo apt update && sudo apt upgrade -y
# Dart SDK
sudo apt install -y apt-transport-https wget
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list
sudo apt update && sudo apt install -y dart

# Podman
sudo apt install -y podman podman-compose

# GitHub CLI
type -p curl >/dev/null || sudo apt install -y curl
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install -y gh

# Wasmtime (opcional)
curl https://wasmtime.dev/install.sh -sSf | bash
```

### Verificação de Instalação
```bash
dart --version    # >= 3.0
podman --version
gh --version
```

### Ferramentas Disponíveis
- **brave-search / WebSearch**: Pesquisa web (genérico → específico)
- **WebFetch**: Download de documentação oficial
- **context7**: Pesquisa especializada em bibliotecas
- **play_notification**: Notificação de conclusão (use ao final de CADA etapa)
- **gh**: GitHub CLI para monitoring de CI/CD
- **podman/podman-compose**: Container runtime (NUNCA docker)

---

## ⚙️ FLUXO DE TRABALHO PADRÃO

### Para CADA Etapa:

1. **Preparação**
   - Crie TODO list com TodoWrite
   - Pesquise (genérico primeiro): brave-search, context7, WebFetch
   - Sincronize sistema: `[paru|sudo apt] -Syu --noconfirm`

2. **Implementação**
   - Implemente o código
   - Instale dependências Dart: `dart pub get`
   - Instale dependências sistema: `[paru -S|sudo apt install] --needed --noconfirm <pacote>`

3. **Validação** (OBRIGATÓRIA)
   ```bash
   dart test        # Se falhar: investigue, pesquise, corrija, REPITA
   dart analyze     # Se falhar: corrija, REPITA
   ```

4. **Commit** (somente após validação passar)
   ```bash
   git add .
   git commit -m "tipo: descrição concisa"
   git push origin main
   ```

5. **CI Monitoring** (se .github/workflows existir)
   ```bash
   sleep 30
   gh run list --limit 1
   gh run view
   # Se rodando: aguarde e verifique novamente
   # Se falhou: investigue logs (gh run view --log-failed), corrija, repita validação
   ```

6. **Conclusão**
   - Execute `play_notification` com mensagem de conclusão
   - Atualize TODO list (TodoWrite)
   - Avance para próxima etapa

### Recuperação de Erros

1. Capture stack trace completo
2. Pesquise brave-search (genérico → específico):
   - Genérico: "dart <conceito> common errors"
   - Específico: "dart <biblioteca> <erro específico>"
3. Baixe docs: WebFetch ou context7
4. Teste solução
5. Se 3 tentativas falharem: brainstorm de alternativa e repita

### Princípios de Autonomia

- ✅ Liberdade total para adaptar conforme necessário
- ✅ Antes de adaptações significativas: brainstorm, documente no commit
- ✅ Use TodoWrite para tracking contínuo
- ✅ Commit frequente após validação
- ✅ Trabalhe direto na branch `main`
- ❌ NUNCA use docker/docker-compose (sempre podman)
- ❌ NUNCA adicione co-autores aos commits

---

## 📋 STATUS DO PROJETO (Atualizado: 2025-11-07)

### ✅ FASES COMPLETAS

- ✅ **Fase 0**: Setup Inicial (70%) - Estrutura criada
- ✅ **Fase 1**: CLI Bootstrap (75%) - CLI funcional + 8 geradores
  - ✅ make:controller, model, migration, request, provider, view, lang, test
  - ✅ dartian test command implementado
  - ✅ Migrations CLI (migrate, migrate:rollback) implementados
- ✅ **Fase 8**: Views SSR (85%) - Mustache completo
- ✅ **Fase 9**: I18n (95%) - Production-ready
- ✅ **Fase 10**: Telemetria (75%) - Hooks instrumentados
- ✅ **Fase 11**: Deployment (85%) - AOT, Podman, WASM scripts
- ✅ **Fase 12**: Geradores (80%) - Todos 8 funcionando

### ✅ MELHORIAS RECENTES (Sessão 2025-11-07)

- ✅ Scheduler com CRON real (parser completo)
- ✅ CORS middleware (100% coverage)
- ✅ CSRF middleware (100% coverage + bug fix)
- ✅ Guards abstratos (JwtGuard, SessionGuard)
- ✅ Migration system (MigrationRunner, CLI commands)
- ✅ dartian_http: 31.8% → 96.2% coverage (+19 testes)
- ✅ dartian_router: 100% coverage

---

## 🔴 GAPS CRÍTICOS RESTANTES (Bloqueantes para Produção)

### Gap #1: Redis e Queue SEM TESTES (0% coverage) 🔴 CRÍTICO

**Pacotes:** dartian_redis, dartian_queue
**Status:** Código existe mas 0 testes
**Impacto:** ALTO - Não pode rodar em produção sem validação
**Tempo:** 2-3 dias

**Tarefas:**

1. **dartian_redis**: Criar `test/redis_test.dart`
   - Testes de conexão (com mock)
   - get/set/delete operations
   - increment/decrement
   - publish/subscribe
   - Fallback in-memory quando Redis indisponível
   - Error handling
   - Meta: >= 95% coverage (~20 testes)

2. **dartian_queue**: Criar `test/queue_test.dart`
   - SyncDriver tests
   - IsolateDriver tests
   - RedisDriver tests (com mock)
   - Job serialization/deserialization
   - Retry logic com backoff exponencial
   - Failed job handling
   - Meta: >= 95% coverage (~25 testes)

3. **Implementar Job.handle()**: Padrão executável
   ```dart
   abstract class Job {
     Future<void> handle();
     Future<void> failed(dynamic error);
   }
   ```

4. **Implementar queue:work CLI**:
   ```bash
   dartian queue:work [--driver=redis] [--queue=default]
   ```

**Validação:**
```bash
cd packages/dartian_redis && dart test --coverage=coverage
cd packages/dartian_queue && dart test --coverage=coverage
# Ambos devem ter >= 95% coverage
```

---

### Gap #2: ORM usa SQLite raw ao invés de Drift 🔴 CRÍTICO

**Pacote:** dartian_orm
**Status:** Implementação ERRADA - violação arquitetural do PLAN.md
**Impacto:** ALTO - Off-spec, precisa refatoração completa
**Tempo:** 3-4 dias

**Problema:** Atualmente usa `sqlite3` raw queries. PLAN.md especifica `drift`.

**Tarefas:**

1. **Refatorar para Drift:**
   - Adicionar dependências:
     ```yaml
     dependencies:
       drift: ^2.14.0
       sqlite3: ^3.2.0
       postgres: ^3.0.0
     dev_dependencies:
       drift_dev: ^2.14.0
       build_runner: ^2.4.0
     ```
   - Criar Database base class usando Drift
   - Implementar QueryBuilder usando Drift API

2. **Implementar Model base class:**
   ```dart
   abstract class Model {
     Future<void> save();
     Future<void> delete();
     static Future<List<T>> where<T>(conditions);
     static Future<List<T>> all<T>();
     static Future<T?> find<T>(int id);
   }
   ```

3. **Implementar relações:**
   - hasMany()
   - belongsTo()
   - hasOne()
   - belongsToMany()

4. **PostgreSQL support:**
   ```dart
   Database.postgres(host, port, database, user, password)
   ```

5. **Atualizar Migration system** para usar Drift

**Validação:**
```bash
cd packages/dartian_orm
dart pub get
dart run build_runner build
dart test --coverage=coverage
# Meta: >= 95% coverage
```

---

### Gap #3: Hot Reload é PLACEHOLDER 🔴 CRÍTICO

**Pacote:** dartian_cli (serve command)
**Status:** FAKE - apenas simula com delay
**Impacto:** ALTO - Feature core do framework
**Tempo:** 2-3 dias

**Problema:** Atual implementação não inicia servidor real, apenas simula com sleep(100ms).

**Tarefas:**

1. **Pesquisar estratégias:**
   ```
   brave-search: "dart vm service hot reload"
   brave-search: "dart isolate server hot reload"
   context7: "dart vm service protocol"
   ```

2. **Implementar servidor real em Isolate:**
   ```dart
   // packages/dartian_cli/lib/src/commands/serve_command.dart
   Future<void> _startServer() async {
     final receivePort = ReceivePort();
     await Isolate.spawn(_serverIsolate, receivePort.sendPort);
     // ...
   }

   void _serverIsolate(SendPort sendPort) {
     final kernel = HttpKernel();
     // Setup routes, middleware
     kernel.listen(host, port);
   }
   ```

3. **Implementar hot reload via VM Service:**
   - Conectar ao VM Service
   - Detectar mudanças de arquivo
   - Trigger reload via VM Service API
   - Preservar estado onde possível

4. **Teste end-to-end:**
   ```bash
   dartian serve &
   sleep 3
   curl http://localhost:8000  # Deve retornar resposta real
   # Modificar arquivo .dart
   # Aguardar reload
   curl http://localhost:8000  # Deve retornar nova resposta
   kill %1
   ```

**Validação:**
```bash
dart test
dart analyze
dartian serve  # Deve iniciar servidor real
```

---

### Gap #4: SHA-256 para senhas (INSEGURO) 🔴 CRÍTICO

**Pacote:** dartian_auth
**Status:** Vulnerabilidade de segurança
**Impacto:** ALTO - Senhas facilmente crackeadas
**Tempo:** 2-3 horas

**Tarefas:**

1. **Pesquisar bcrypt para Dart:**
   ```
   brave-search: "dart bcrypt password hashing"
   context7: "bcrypt dart package"
   ```

2. **Adicionar dependência:**
   ```yaml
   dependencies:
     bcrypt: ^1.1.3  # ou dbcrypt
   ```

3. **Substituir SHA-256 por bcrypt:**
   ```dart
   // lib/src/auth_manager.dart
   import 'package:bcrypt/bcrypt.dart';

   String _hashPassword(String password) {
     return BCrypt.hashpw(password, BCrypt.gensalt());
   }

   bool _verifyPassword(String password, String hash) {
     return BCrypt.checkpw(password, hash);
   }
   ```

4. **Atualizar testes:**
   - Remover referências a SHA-256
   - Adicionar testes de bcrypt
   - Verificar todos os 30 testes passam

**Validação:**
```bash
cd packages/dartian_auth
dart test
# Todos os 30 testes devem passar
```

---

### Gap #5: CLI Commands são stubs 🟡 IMPORTANTE

**Pacote:** dartian_cli
**Status:** Comandos retornam "Not implemented yet"
**Impacto:** MÉDIO - UX comprometida
**Tempo:** 2-3 dias

**Comandos faltantes:**

1. **dartian new <project>**
   - Criar estrutura de projeto
   - Copiar templates (app/, routes/, resources/)
   - Inicializar pubspec.yaml
   - Criar .env.example

2. **dartian build exe**
   ```bash
   dart compile exe -O2 bin/main.dart -o build/dartian-aot
   ```

3. **dartian build aot-snapshot**
   ```bash
   dart compile aot-snapshot -O2 bin/main.dart
   ```

4. **dartian queue:work**
   - Conectar a Queue com driver (via .env)
   - Dequeue jobs continuamente
   - Processar com retry
   - Graceful shutdown (SIGTERM)

5. **dartian schedule:run**
   - Inicializar Scheduler
   - Carregar tarefas agendadas
   - Executar runAsync()
   - Graceful shutdown

**Validação:**
```bash
dartian new test_project
cd test_project && ls -la
dartian build exe
./build/dartian-aot version
```

---

### Gap #6: Test Coverage < 95% 🟡 IMPORTANTE

**Status Atual (após melhorias):**
- ✅ dartian_http: 96.2% (meta atingida!)
- ✅ dartian_router: 100% (meta atingida!)
- ✅ dartian_i18n: 95% (meta atingida!)
- ✅ dartian_core: 95% (meta atingida!)
- ⚠️  dartian_cli: 21% → precisa 95%
- ⚠️  dartian_di: 70% → precisa 95%
- ⚠️  dartian_orm: 60% → precisa 95%
- ❌ dartian_redis: 0% → precisa 95%
- ❌ dartian_queue: 0% → precisa 95%
- ⚠️  dartian_scheduler: 0% → precisa 95%
- ⚠️  dartian_auth: 80% → precisa 95%
- ⚠️  dartian_view: 90% → precisa 95%

**Tempo:** 3-4 dias para atingir 95% em todos

**Tarefas:**

Para cada pacote abaixo de 95%:

1. **Gerar relatório de coverage:**
   ```bash
   cd packages/<package>
   dart test --coverage=coverage
   dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib
   ```

2. **Identificar linhas não cobertas:**
   ```bash
   cat coverage/lcov.info | grep "DA:.*,0$"
   ```

3. **Adicionar testes para cobrir gaps:**
   - Edge cases
   - Error handling
   - Branches não testados

4. **Validar >= 95%:**
   ```bash
   # Calcular percentual
   grep -E "^(LF|LH):" coverage/lcov.info | paste -d: - - | awk -F: '{print ($2/$4)*100"%"}'
   ```

**Script consolidado:**
```bash
# scripts/test-coverage.sh
for dir in packages/*/; do
  cd "$dir"
  echo "Testing $dir..."
  dart test --coverage=coverage || exit 1
  dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib
  cd ../..
done

# Validar threshold
echo "Validating coverage >= 95%..."
for dir in packages/*/; do
  if [ -f "$dir/coverage/lcov.info" ]; then
    pct=$(grep -E "^(LF|LH):" "$dir/coverage/lcov.info" | paste -d: - - | awk -F: '{printf "%.1f", ($2/$4)*100}')
    echo "$dir: $pct%"
    if (( $(echo "$pct < 95" | bc -l) )); then
      echo "❌ Coverage below 95%: $dir ($pct%)"
      exit 1
    fi
  fi
done
echo "✅ All packages >= 95% coverage"
```

---

## 🟢 MELHORIAS DESEJÁVEIS (Não-bloqueantes)

### Gap #7: CI/CD Pipeline

**Arquivo:** `.github/workflows/ci.yml`
**Tempo:** 4-6 horas

```yaml
name: Dartian CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        dart-version: ['3.0', 'latest']
    steps:
      - uses: actions/checkout@v3
      - uses: dart-lang/setup-dart@v1
        with:
          sdk: ${{ matrix.dart-version }}

      - name: Install CLI
        run: |
          cd packages/dartian_cli
          dart pub global activate -s path .

      - name: Test all packages
        run: |
          for dir in packages/*/; do
            cd "$dir"
            dart pub get
            dart analyze || exit 1
            dart test --coverage=coverage || exit 1
            cd ../..
          done

      - name: Validate coverage
        run: |
          chmod +x scripts/test-coverage.sh
          ./scripts/test-coverage.sh
```

---

### Gap #8: Documentação Completa

**Arquivos:**
- `README.md` - Overview, quick start, features
- `CONTRIBUTING.md` - Processo de contribuição
- `examples/hello_world/` - Projeto exemplo funcional
- `docs/` - Documentação detalhada

**Tempo:** 1-2 dias

---

### Gap #9: DI Auto-discovery (Fase 3.2)

**Pacote:** dartian_di
**Tempo:** 1 dia

**Tarefas:**
- Anotações @Service() e @Singleton()
- Builder com source_gen
- Geração de generated_providers.dart

---

### Gap #10: Cycle Detection em DI

**Pacote:** dartian_di
**Tempo:** 4-6 horas

**Tarefas:**
- Detectar dependências circulares
- Lançar exception clara
- Adicionar testes

---

## 🚀 ORDEM DE EXECUÇÃO RECOMENDADA

Execute nesta ordem para máximo impacto:

### Sprint 1: Segurança e Testes Críticos (3-4 dias)
1. ✅ **Gap #4**: SHA-256 → bcrypt (2-3h) 🔴
2. ✅ **Gap #1**: Redis + Queue testes (2-3 dias) 🔴
3. ✅ **Gap #6**: Coverage para 95% (paralelo)

### Sprint 2: ORM Refactor (3-4 dias)
4. ✅ **Gap #2**: ORM → Drift (3-4 dias) 🔴

### Sprint 3: Hot Reload (2-3 dias)
5. ✅ **Gap #3**: Hot Reload real (2-3 dias) 🔴

### Sprint 4: CLI Commands (2-3 dias)
6. ✅ **Gap #5**: CLI commands (2-3 dias) 🟡

### Sprint 5: Polimento (2-3 dias)
7. ✅ **Gap #7**: CI/CD (4-6h) 🟢
8. ✅ **Gap #8**: Documentação (1-2 dias) 🟢
9. ✅ **Gap #9**: DI auto-discovery (1 dia) 🟢
10. ✅ **Gap #10**: Cycle detection (4-6h) 🟢

**Tempo Total Estimado:** 15-20 dias de trabalho

---

## 📊 CRITÉRIOS DE CONCLUSÃO

O projeto estará **COMPLETO** quando:

- ✅ Todos os 13 packages com >= 95% test coverage
- ✅ `dart analyze` passa em todos os packages (0 errors, 0 warnings)
- ✅ Todos os comandos CLI funcionais
- ✅ ORM usando Drift (não sqlite3 raw)
- ✅ Hot reload funcional
- ✅ Senhas com bcrypt (não SHA-256)
- ✅ CORS e CSRF implementados e testados
- ✅ Redis e Queue 100% testados
- ✅ CI/CD verde
- ✅ README.md completo
- ✅ Tag v1.0.0 criada

---

## 🎯 COMO EXECUTAR ESTE PLANO

### Opção 1: Execução Completa Autônoma
```
"Execute o PLAN.md do início ao fim de forma autônoma. Use play_notification ao completar cada Gap."
```

### Opção 2: Execução Gap Específico
```
"Execute o Gap #1 do PLAN.md (Redis e Queue testes)"
```

### Opção 3: Execução Sprint Específica
```
"Execute o Sprint 1 do PLAN.md (Segurança e Testes Críticos)"
```

### Opção 4: Continue de onde parou
```
"Continue o PLAN.md de onde parou"
```

---

## 📝 NOTAS IMPORTANTES

- **Branch:** Trabalhe sempre na `main` (sem feature branches)
- **Commits:** Frequentes, após cada validação passar
- **Podman:** NUNCA use docker/docker-compose
- **CI:** Monitor com `gh run view` após cada push
- **Notificações:** Use `play_notification` ao completar CADA etapa
- **Autonomia:** Liberdade total para adaptar conforme necessário
- **Pesquisa:** Sempre genérico → específico
- **Validação:** NUNCA commite sem `dart test` e `dart analyze` passarem

---

**PLANO ATUALIZADO:** 2025-11-07
**PRÓXIMA REVISÃO:** Após completar Sprint 1
**VERSÃO:** 2.0 (Atualizado com progresso real e suporte Debian/Ubuntu)

---

## 🎉 PROGRESSO

**Completo:** 78%
**Fases Completas:** 7/18 (Fases 0, 1-parcial, 8, 9, 10, 11, 12)
**Gaps Críticos:** 6 restantes
**Estimativa de Conclusão:** 15-20 dias úteis

**Para continuar, basta dizer:** "Execute o PLAN.md"
