# Plano Executivo Autônomo Completo – Dartian MVP

## Ambiente: Arch Linux com Paru | Podman | Branch: main


***

## PRINCÍPIOS DE AUTONOMIA

### Ferramentas Disponíveis

- **brave-search**: Busca web (genérico → específico)
- **fetch**: Download de documentação oficial
- **context7**: Pesquisa especializada
- **play_notification**: Marcador de conclusão
- **gh**: GitHub CLI para CI/CD monitoring
- **paru**: Gerenciador de pacotes Arch
- **podman/podman-compose**: Container runtime


### Fluxo de Trabalho Padrão

Para cada etapa:

1. **Preparação**: Monte to-do, pesquise (genérico primeiro), baixe documentação
2. **Sincronização**: `paru -Syu --noconfirm`
3. **Implementação**: Implemente, instale dependências via `paru -S --needed --noconfirm`
4. **Validação**:

```bash
dart test        # Se falhar: investigue, pesquise, corrija, repita
dart analyze     # Se falhar: corrija, repita
```

5. **Commit** (quando ambos passarem):

```bash
git add .
git commit -m "tipo: descrição"
git push origin main
```

6. **CI Monitoring** (se GitHub Actions existir):

```bash
sleep 30
gh run list --limit 1
gh run view
# Se rodando: sleep 30 + verificar novamente
# Se falhou: investigar logs, pesquisar, corrigir, repitar 4-5
```

7. **Conclusão**: Execute `play_notification`, avance para próxima etapa

### Recuperação de Erros

1. Capture stack trace completo
2. Pesquise no brave-search (genérico → específico)
3. Baixe documentação com fetch/context7 se necessário
4. Teste solução proposta
5. Se persistir após 3 abordagens: faça brainstorm de alternativa e pesquise novamente

### Adaptações Permitidas

Você tem liberdade total para adaptar conforme necessário para garantir sucesso. **ANTES de adaptações significativas**: faça brainstorm, pese prós/contras, documente decisão no commit.

***

## FASE PRELIMINAR: Setup Inicial e Validação

### Etapa 0.1: Verificação do ambiente Dart

**To-do:**

- [ ] Sincronizar paru
- [ ] Instalar/verificar Dart
- [ ] Validar versão >= 3.0

**Instruções:**

```bash
paru -Syu --noconfirm
paru -S --needed --noconfirm dart
dart --version  # >= 3.0
dart pub global activate
dart help
```

**Validação:**

```bash
dart --version
dart pub global list
```

**Commit:**

```bash
git add .
git commit -m "chore: verify dart sdk installation"
git push origin main
play_notification
```


***

### Etapa 0.2: Configuração do Git

**To-do:**

- [ ] Verificar status
- [ ] Configurar identidade
- [ ] Verificar branch (deve ser main)

**Instruções:**

```bash
git status
git config user.name "Dartian MVP Builder"
git config user.email "dartian@builder.local"
git branch  # Deve mostrar main
```

**Commit:**

```bash
git add .
git commit -m "chore: setup git configuration"
git push origin main
play_notification
```


***

### Etapa 0.3: Estrutura de diretórios

**To-do:**

- [ ] Criar diretórios de pacotes
- [ ] Criar diretórios auxiliares
- [ ] Validar estrutura

**Instruções:**

```bash
mkdir -p packages/{dartian_cli,dartian_core,dartian_http,dartian_router,dartian_di,dartian_orm,dartian_redis,dartian_queue,dartian_scheduler,dartian_view,dartian_i18n,dartian_auth}
mkdir -p docs examples scripts .github/workflows
ls -la packages/
find packages/ -type d | wc -l  # 13
```

**Commit:**

```bash
git add .
git commit -m "chore: create monorepo directory structure"
git push origin main
play_notification
```


***

### Etapa 0.4: Compilação e targets

**To-do:**

- [ ] Verificar dart compile exe
- [ ] Verificar dart compile aot-snapshot
- [ ] Verificar dart compile wasm
- [ ] Teste prototípico

**Instruções:**

```bash
dart compile exe --help
dart compile aot-snapshot --help
dart help compile wasm

cd /tmp
dart create -t console test_compile_app
cd test_compile_app
dart compile exe bin/test_compile_app.dart -o test_exe
./test_exe
cd -
```

**Commit:**

```bash
git add .
git commit -m "chore: verify dart compilation targets"
git push origin main
play_notification
```


***

## FASE 1: CLI Bootstrap (dartian_cli)

### Etapa 1.1: Inicialização do pacote CLI

**To-do:**

- [ ] Pesquisar CLI em Dart
- [ ] Criar pacote dartian_cli
- [ ] Estruturar diretórios
- [ ] Implementar programa principal

**Instruções:**

```
brave-search: "dart cli best practices"
brave-search: "dart command line parsing package:args"
fetch: https://pub.dev/packages/args
```

```bash
cd packages/dartian_cli
dart create -t console .
```

Edite `pubspec.yaml`:

```yaml
name: dartian_cli
version: 0.0.1
description: Dartian framework CLI

dependencies:
  args: ^2.4.0

dev_dependencies:
  test: ^1.24.0
```

```bash
mkdir -p lib/src/commands lib/src/helpers
dart pub get
```

Implemente `bin/dartian.dart` com:

- Parser de argumentos com `package:args`
- Subcomandos: version, help, new, serve, make:*, migrate, queue:work, schedule:run, test, build
- "version" retorna "Dartian 0.0.1"
- "help" lista subcomandos
- Outros retornam "Not implemented yet"

**Validação:**

```bash
dart test
dart analyze
dart run bin/dartian.dart version
dart run bin/dartian.dart help
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "init: dartian_cli with basic structure"
git push origin main
play_notification
```


***

### Etapa 1.2: Testes unitários do CLI

**To-do:**

- [ ] Pesquisar testes com package:test
- [ ] Criar testes de command parsing
- [ ] Validar 100% cobertura

**Instruções:**

```
brave-search: "dart cli testing package:test"
fetch: https://pub.dev/packages/test
```

Em `packages/dartian_cli/test/command_test.dart`:

- Testes de parsing "version", "help"
- Rejeição de subcomandos desconhecidos
- Ausência de argumentos

```bash
cd packages/dartian_cli
dart test
dart test --coverage=coverage
```

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "test: 100% coverage for CLI command parsing"
git push origin main
play_notification
```


***

### Etapa 1.3: Instalação global da CLI

**To-do:**

- [ ] Ativar CLI globalmente
- [ ] Validar comando
- [ ] Testar de diferentes diretórios

**Instruções:**

```bash
cd packages/dartian_cli
dart pub global activate -s path .

dartian version  # "Dartian 0.0.1"
dartian help     # Lista subcomandos
```

**Validação:**

```bash
cd /tmp
dartian version
cd -
dart test
dart analyze
```

**Commit:**

```bash
git add .
git commit -m "feat: CLI global activation"
git push origin main
play_notification
```


***

## FASE 2: HTTP Kernel e Roteamento

### Etapa 2.1: Integração com shelf

**To-do:**

- [ ] Pesquisar shelf package
- [ ] Criar pacote dartian_http
- [ ] Implementar HttpKernel
- [ ] Implementar wrappers

**Instruções:**

```
brave-search: "dart shelf http server"
brave-search: "shelf middleware pipeline"
fetch: https://pub.dev/packages/shelf
context7: "shelf http server examples"
```

```bash
cd packages/dartian_http
dart create -t package .
```

Edite `pubspec.yaml`:

```yaml
name: dartian_http
version: 0.0.1
description: Dartian HTTP kernel

dependencies:
  shelf: ^1.4.1

dev_dependencies:
  test: ^1.24.0
```

```bash
mkdir -p lib/src
dart pub get
```

Crie `lib/src/kernel.dart`:

- Classe HttpKernel com método `listen(host, port)`
- Método `handle(request)` que retorna Response
- Pipeline de middlewares

Crie `lib/src/response.dart`:

- Helper `json(data, status)`
- Helper `html(content, status)`
- Helper `text(content, status)`

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "init: dartian_http with shelf integration"
git push origin main
play_notification
```


***

### Etapa 2.2: Roteador com shelf_router

**To-do:**

- [ ] Pesquisar shelf_router
- [ ] Criar pacote dartian_router
- [ ] Implementar DSL fluente
- [ ] Implementar suporte a grupos

**Instruções:**

```
brave-search: "dart shelf_router examples"
fetch: https://pub.dev/packages/shelf_router
```

```bash
cd packages/dartian_router
dart create -t package .
```

Edite `pubspec.yaml`:

```yaml
name: dartian_router
version: 0.0.1
description: Dartian router with fluent DSL

dependencies:
  shelf_router: ^1.2.0
  shelf: ^1.4.1

dev_dependencies:
  test: ^1.24.0
```

```bash
mkdir -p lib/src
dart pub get
```

Implemente `lib/src/router.dart`:

- Métodos: `get()`, `post()`, `put()`, `delete()`
- Método `group()` para grupos
- Método `name()` para rotas nomeadas
- Suporte a parâmetros de rota (ex: `/users/:id`)

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "init: dartian_router with fluent DSL"
git push origin main
play_notification
```


***

### Etapa 2.3: Hot reload em "dartian serve"

**To-do:**

- [ ] Pesquisar hot reload strategies
- [ ] Implementar subcomando serve
- [ ] Implementar watch de arquivos

**Instruções:**

```
brave-search: "dart hot reload server"
fetch: https://pub.dev/packages/watcher
```

Em `packages/dartian_cli/pubspec.yaml`, adicione:

```yaml
dependencies:
  watcher: ^1.1.0
```

Implemente "serve" em `packages/dartian_cli/`:

- Flags `--host` (padrão localhost), `--port` (padrão 8000)
- Iniciar HttpKernel com Router
- Watch de arquivos `.dart`
- Reload automático
- Mensagem "Server listening on http://localhost:8000"

```bash
dart pub get
```

**Validação:**

```bash
dart test
dart analyze
dartian serve  # Deve iniciar
# Em outro terminal, modificar arquivo e observar reload
```

**Commit:**

```bash
git add .
git commit -m "feat: dartian serve with hot reload"
git push origin main
play_notification
```


***

### Etapa 2.4: Testes 100% HTTP + Router

**To-do:**

- [ ] Pesquisar estratégias de teste
- [ ] Testes de kernel HTTP
- [ ] Testes de router
- [ ] Validar 100% cobertura

**Instruções:**

```
brave-search: "dart shelf testing best practices"
brave-search: "dart http server integration tests"
```

Em `packages/dartian_http/test/kernel_test.dart`:

- Inicialização de kernel
- Requisição GET com 200
- Middleware pipeline
- Negociação de conteúdo
- Error handler (404, 500)

Em `packages/dartian_router/test/router_test.dart`:

- Matching de rota
- Parâmetros de rota
- Grupos de rotas
- Rotas nomeadas
- 404 quando não encontrada

```bash
cd packages/dartian_http
dart test --coverage=coverage
cd ../dartian_router
dart test --coverage=coverage
```

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "test: 100% coverage for HTTP and router"
git push origin main
play_notification
```


***

## FASE 3: Injeção de Dependências (dartian_di)

### Etapa 3.1: Service Container com get_it

**To-do:**

- [ ] Pesquisar get_it
- [ ] Criar pacote dartian_di
- [ ] Implementar Container
- [ ] Implementar ServiceProvider base

**Instruções:**

```
brave-search: "dart get_it service locator"
fetch: https://pub.dev/packages/get_it
```

```bash
cd packages/dartian_di
dart create -t package .
```

Edite `pubspec.yaml`:

```yaml
name: dartian_di
version: 0.0.1
description: Dartian DI with get_it

dependencies:
  get_it: ^8.0.0

dev_dependencies:
  test: ^1.24.0
```

```bash
mkdir -p lib/src
dart pub get
```

Implemente:

- Classe `Container` como facade sobre get_it

```
- Métodos: `register<T>()`, `singleton<T>()`, `resolve<T>()`
```

- Classe `ServiceProvider` base
- Detecção de ciclos de dependência

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "init: dartian_di with get_it"
git push origin main
play_notification
```


***

### Etapa 3.2: Auto-discovery e geração estática

**To-do:**

- [ ] Pesquisar build_runner e source_gen
- [ ] Implementar anotações
- [ ] Implementar builder customizado
- [ ] Gerar arquivo de providers

**Instruções:**

```
brave-search: "dart build_runner code generation"
fetch: https://pub.dev/packages/build_runner
```

Em `packages/dartian_di/pubspec.yaml`:

```yaml
dev_dependencies:
  build_runner: ^2.4.0
  source_gen: ^1.4.0
```

Implemente:

- Anotações `@Service()` e `@Singleton()`
- Builder customizado com source_gen
- Geração de `lib/src/generated_providers.dart`

```bash
dart pub get
dart run build_runner build
```

**Validação:**

```bash
dart test
dart analyze
dart run build_runner build
```

**Commit:**

```bash
git add .
git commit -m "feat: auto-discovery with code generation"
git push origin main
play_notification
```


***

### Etapa 3.3: Integração com HTTP kernel

**To-do:**

- [ ] Modificar HttpKernel
- [ ] Adicionar middleware que injeta Container
- [ ] Implementar resolução automática
- [ ] Testar integração

**Instruções:**

Modifique `dartian_http/lib/src/kernel.dart`:

- Aceitar instância de Container
- Adicionar middleware que popula Request com Container
- Implementar resolução automática em handlers

**Validação:**

```bash
cd packages/dartian_http
dart test
cd ../dartian_di
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "feat: HTTP kernel DI integration"
git push origin main
play_notification
```


***

### Etapa 3.4: Testes 100% de DI

**To-do:**

- [ ] Testes de registro/resolução
- [ ] Testes de lazy initialization
- [ ] Testes de ciclos
- [ ] Testes de integração HTTP
- [ ] Validar 100%

**Instruções:**

Em `packages/dartian_di/test/container_test.dart`:

- Registro e resolução singleton
- Factory
- Lazy initialization
- Detecção de ciclo
- Auto-discovery
- Integração HTTP

```bash
cd packages/dartian_di
dart test --coverage=coverage
```

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "test: 100% coverage for DI module"
git push origin main
play_notification
```


***

## FASE 4: ORM e Data Layer (dartian_orm)

### Etapa 4.1: Integração com Drift

**To-do:**

- [ ] Pesquisar Drift extensivamente
- [ ] Criar pacote dartian_orm
- [ ] Implementar Database base
- [ ] Implementar Model com API Eloquent-like

**Instruções:**

```
brave-search: "dart drift orm"
brave-search: "drift orm relationships"
fetch: https://drift.simonbinder.eu/
context7: "drift orm complete guide"
```

```bash
cd packages/dartian_orm
dart create -t package .
```

Edite `pubspec.yaml`:

```yaml
name: dartian_orm
version: 0.0.1
description: Dartian ORM with Drift

dependencies:
  drift: ^2.14.0
  sqlite3: ^3.2.0
  postgres: ^3.0.0

dev_dependencies:
  drift_dev: ^2.14.0
  build_runner: ^2.4.0
  test: ^1.24.0
```

```bash
mkdir -p lib/src
dart pub get
```

Implemente:

```
- Classe `Database` wrappando Drift com métodos: `table<T>()`, `query<T>()`, `migrate()`, `seed()`
```

- Classe `Model` base com helpers: `save()`, `delete()`, `where()`, `all()`, `find(id)`, relações
- `QueryBuilder` com métodos fluentes: `where()`, `select()`, `join()`, `limit()`, `order()`

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "init: dartian_orm with Drift and Eloquent-like API"
git push origin main
play_notification
```


***

### Etapa 4.2: Migrations

**To-do:**

- [ ] Pesquisar migrations em Drift
- [ ] Implementar Migration abstrata
- [ ] Implementar executor
- [ ] Integrar com CLI

**Instruções:**

```
brave-search: "drift migrations"
brave-search: "drift schema versioning"
```

Em `packages/dartian_orm/lib/src/migration.dart`:

- Classe abstrata `Migration` com `up()` e `down()`
- Executor que lê migrações de `database/migrations/`
- Registra versão em tabela `migrations`
- Suporta rollback com `down()`

Em `packages/dartian_cli/`, implemente `dartian migrate` e `dartian migrate:rollback`

**Validação:**

```bash
dart test
dart analyze
dartian migrate
dartian migrate:rollback
```

**Commit:**

```bash
git add .
git commit -m "feat: migration system with versioning"
git push origin main
play_notification
```


***

### Etapa 4.3: SQLite e PostgreSQL drivers

**To-do:**

- [ ] Pesquisar Drift com SQLite e PostgreSQL
- [ ] Implementar ambos drivers
- [ ] Configurar seleção por .env

**Instruções:**

```
brave-search: "drift sqlite setup"
brave-search: "drift postgres setup"
fetch: https://pub.dev/packages/postgres
```

Modifique `Database`:

- Método `Database.sqlite(path)` para SQLite
- Método `Database.postgres(host, port, database, user, password)` para PostgreSQL
- Ler .env para determinar driver padrão

Implemente DI Service para `Database` que lê .env

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
git add .
git commit -m "feat: SQLite and PostgreSQL driver support"
git push origin main
play_notification
```


***

### Etapa 4.4: Testes 100% de ORM

**To-do:**

- [ ] Testes de CRUD
- [ ] Testes de query builder
- [ ] Testes de migrations
- [ ] Testes de relações
- [ ] Marcar testes Postgres com @Tag('integration')
- [ ] Validar 100%

**Instruções:**

Em `packages/dartian_orm/test/orm_test.dart`:

- CRUD com SQLite in-memory
- Query builder: where, select, join, limit, order
- Migrações: up, down
- Relações: one-to-many, many-to-one
- Marcar Postgres com `@Tag('integration')`

```bash
cd packages/dartian_orm
dart test --coverage=coverage
```

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "test: 100% coverage for ORM module"
git push origin main
play_notification
```


***

## FASE 5: Cache e Filas (dartian_redis, dartian_queue)

### Etapa 5.1: Redis client integration

**To-do:**

- [ ] Pesquisar clientes Redis para Dart
- [ ] Criar pacote dartian_redis
- [ ] Implementar RedisManager
- [ ] Implementar abstração de cache

**Instruções:**

```
brave-search: "dart redis client"
fetch: https://pub.dev/packages/redis
```

```bash
cd packages/dartian_redis
dart create -t package .
```

Edite `pubspec.yaml`:

```yaml
name: dartian_redis
version: 0.0.1
description: Dartian Redis integration

dependencies:
  redis: ^4.8.0

dev_dependencies:
  test: ^1.24.0
```

```bash
mkdir -p lib/src
dart pub get
```

Implemente:

- Classe `RedisManager` que conecta a Redis
- Métodos: `get()`, `set()`, `delete()`, `increment()`, `publish()`, `subscribe()`
- Classe `CacheDriver` com in-memory fallback

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "init: dartian_redis with client integration"
git push origin main
play_notification
```


***

### Etapa 5.2: Filas (sync, isolates, Redis)

**To-do:**

- [ ] Pesquisar padrões de filas
- [ ] Pesquisar isolates
- [ ] Criar pacote dartian_queue
- [ ] Implementar drivers

**Instruções:**

```
brave-search: "dart queue system"
brave-search: "dart isolates parallel processing"
brave-search: "dart job queue redis"
```

```bash
cd packages/dartian_queue
dart create -t package .
```

Edite `pubspec.yaml`:

```yaml
name: dartian_queue
version: 0.0.1
description: Dartian queue system

dependencies:
  dartian_redis:
    path: ../dartian_redis

dev_dependencies:
  test: ^1.24.0
```

```bash
mkdir -p lib/src/drivers
dart pub get
```

Implemente:

- Classe abstrata `Queue`
- Classe abstrata `Job` com método `handle()` e `failed()`
- Driver `SyncDriver` - executa imediatamente
- Driver `IsolateDriver` - spawna isolate
- Driver `RedisDriver` - persiste em Redis com retry

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "init: dartian_queue with multiple drivers"
git push origin main
play_notification
```


***

### Etapa 5.3: Worker CLI

**To-do:**

- [ ] Implementar subcomando queue:work
- [ ] Conectar a Queue
- [ ] Implementar retry e backoff
- [ ] Graceful shutdown

**Instruções:**

Em `packages/dartian_cli/`, implemente "queue:work" que:

- Conecta a Queue com driver (via .env)
- Dequeue jobs continuamente
- Processa com erro handling
- Retry com backoff exponencial
- Responde a SIGTERM

**Validação:**

```bash
dart test
dart analyze
dartian queue:work
```

**Commit:**

```bash
git add .
git commit -m "feat: dartian queue:work command with retry"
git push origin main
play_notification
```


***

### Etapa 5.4: Testes 100% de Redis e Queue

**To-do:**

- [ ] Testes com mocks Redis
- [ ] Testes de enqueue/dequeue
- [ ] Testes de retry
- [ ] Marcar testes integração com @Tag
- [ ] Validar 100%

**Instruções:**

Em `packages/dartian_redis/test/` e `packages/dartian_queue/test/`:

- Use mocks para Redis
- Testes de enqueue/dequeue
- Retry logic com backoff
- Marque testes Redis/Isolate com `@Tag('integration')`

```bash
dart test --coverage=coverage
```

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
git add .
git commit -m "test: 100% coverage for Redis and Queue"
git push origin main
play_notification
```


***

## FASE 6: Scheduler (dartian_scheduler)

### Etapa 6.1: Integração com cron

**To-do:**

- [ ] Pesquisar package:cron
- [ ] Criar pacote dartian_scheduler
- [ ] Implementar Scheduler com DSL
- [ ] Implementar Task abstrata

**Instruções:**

```
brave-search: "dart cron package"
fetch: https://pub.dev/packages/cron
```

```bash
cd packages/dartian_scheduler
dart create -t package .
```

Edite `pubspec.yaml`:

```yaml
name: dartian_scheduler
version: 0.0.1
description: Dartian scheduler

dependencies:
  cron: ^0.7.0

dev_dependencies:
  test: ^1.24.0
```

```bash
mkdir -p lib/src
dart pub get
```

Implemente:

- Classe `Scheduler` com método `add(expression, callback)`
- Método `every(duration, callback)` para intervalos
- Método `runAsync()` que executa indefinidamente
- Classe `Task` abstrata com hook `run()`

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "init: dartian_scheduler with cron"
git push origin main
play_notification
```


***

### Etapa 6.2: CLI e integração com filas

**To-do:**

- [ ] Implementar subcomando schedule:run
- [ ] Inicializar Scheduler
- [ ] Integrar com Queue opcionalmente
- [ ] Graceful shutdown

**Instruções:**

Em `packages/dartian_cli/`, implemente "schedule:run" que:

- Inicializa Scheduler
- Carrega tarefas agendadas
- Executa `runAsync()`
- Responde a SIGTERM
- Opcionalmente despacha jobs em Queue

**Validação:**

```bash
dart test
dart analyze
dartian schedule:run
```

**Commit:**

```bash
git add .
git commit -m "feat: dartian schedule:run command"
git push origin main
play_notification
```


***

### Etapa 6.3: Testes 100% de Scheduler

**To-do:**

- [ ] Testes de parsing cron
- [ ] Testes de execução
- [ ] Testes de pausa/resumo
- [ ] Validar 100%

**Instruções:**

Em `packages/dartian_scheduler/test/scheduler_test.dart`:

- Parsing de expressões cron
- Execução de task no tempo esperado
- `every()` com durações pequenas
- Pausa e resumo
- Erros em tasks

```bash
dart test --coverage=coverage
```

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
git add .
git commit -m "test: 100% coverage for Scheduler"
git push origin main
play_notification
```


***

## FASE 7: Autenticação e Segurança (dartian_auth)

### Etapa 7.1: Autenticação com sessão e JWT

**To-do:**

- [ ] Pesquisar autenticação em Dart
- [ ] Pesquisar JWT em Dart
- [ ] Criar pacote dartian_auth
- [ ] Implementar Guards
- [ ] Implementar hashing

**Instruções:**

```
brave-search: "dart jwt authentication"
brave-search: "dart password hashing"
```

```bash
cd packages/dartian_auth
dart create -t package .
```

Edite `pubspec.yaml`:

```yaml
name: dartian_auth
version: 0.0.1
description: Dartian authentication

dependencies:
  crypto: ^3.0.0

dev_dependencies:
  test: ^1.24.0
```

```bash
mkdir -p lib/src
dart pub get
```

Implemente:

- Classe abstrata `Guard` com métodos: `attempt()`, `login()`, `logout()`, `user()`, `check()`
- Classe `SessionGuard` - armazena user ID em sessão
- Classe `JwtGuard` - emite/valida tokens JWT
- Hashing de senha com argon2 ou bcrypt

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "init: dartian_auth with session and JWT guards"
git push origin main
play_notification
```


***

### Etapa 7.2: CORS e CSRF

**To-do:**

- [ ] Pesquisar CORS em shelf
- [ ] Pesquisar CSRF protection
- [ ] Implementar middlewares
- [ ] Integrar ao kernel HTTP

**Instruções:**

```
brave-search: "dart shelf cors middleware"
brave-search: "csrf protection dart"
```

Em `packages/dartian_http/`:

- Middleware `CorsMiddleware` que valida origins (allowlist em prod)
- Middleware `CsrfMiddleware` que gera/valida tokens
- Integrar ao kernel HTTP default

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
git add .
git commit -m "feat: CORS and CSRF middleware"
git push origin main
play_notification
```


***

### Etapa 7.3: Testes 100% de Autenticação

**To-do:**

- [ ] Testes de login/logout
- [ ] Testes de JWT
- [ ] Testes de hashing
- [ ] Testes de CORS/CSRF
- [ ] Validar 100%

**Instruções:**

Em `packages/dartian_auth/test/` e `packages/dartian_http/test/`:

- Login com credenciais válidas/inválidas
- Geração e validação de JWT
- Logout
- Hashing de senha
- CORS preflight e validação
- CSRF geração e validação

```bash
dart test --coverage=coverage
```

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
git add .
git commit -m "test: 100% coverage for Auth, CORS, CSRF"
git push origin main
play_notification
```


***

## FASE 8: Views SSR com Mustache (dartian_view)

### Etapa 8.1: Engine de templates com mustache

**To-do:**

- [ ] Pesquisar mustache_template
- [ ] Criar pacote dartian_view
- [ ] Implementar View class
- [ ] Implementar layouts e includes

**Instruções:**

```
brave-search: "dart mustache template"
fetch: https://pub.dev/packages/mustache_template
```

```bash
cd packages/dartian_view
dart create -t package .
```

Edite `pubspec.yaml`:

```yaml
name: dartian_view
version: 0.0.1
description: Dartian SSR views

dependencies:
  mustache_template: ^2.0.0

dev_dependencies:
  test: ^1.24.0
```

```bash
mkdir -p lib/src
dart pub get
```

Implemente:

- Classe `View` que aceita caminho de template e dados
- Método que renderiza com mustache (escape por padrão)
- Suporte a layouts (master envolvendo view)
- Suporte a includes de sub-templates
- Integre ao kernel HTTP: helper `render(view, data)` que retorna Response HTML

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "init: dartian_view with mustache SSR"
git push origin main
play_notification
```


***

### Etapa 8.2: Gerador "dartian make:view"

**To-do:**

- [ ] Implementar subcomando make:view
- [ ] Criar template boilerplate
- [ ] Testar geração

**Instruções:**

Em `packages/dartian_cli/`, implemente "make:view" que:

- Aceita nome de view (ex: `dartian make:view users/list`)
- Cria arquivo `resources/views/users/list.mustache`
- Fornece template boilerplate

**Validação:**

```bash
dart test
dart analyze
dartian make:view test/sample
```

**Commit:**

```bash
git add .
git commit -m "feat: dartian make:view generator"
git push origin main
play_notification
```


***

### Etapa 8.3: Testes 100% de Views

**To-do:**

- [ ] Testes de renderização
- [ ] Testes de escape
- [ ] Testes de includes/layouts
- [ ] Validar 100%

**Instruções:**

Em `packages/dartian_view/test/view_test.dart`:

- Renderização básica com variáveis
- Escape de HTML
- Includes e layouts
- Erros quando template não existe

```bash
dart test --coverage=coverage
```

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
git add .
git commit -m "test: 100% coverage for View module"
git push origin main
play_notification
```


***

## FASE 9: Internacionalização (dartian_i18n)

### Etapa 9.1: i18n básico

**To-do:**

- [ ] Pesquisar i18n patterns
- [ ] Criar pacote dartian_i18n
- [ ] Implementar Translator
- [ ] Implementar fallback

**Instruções:**

```
brave-search: "dart internationalization i18n"
brave-search: "dart locale fallback"
```

```bash
cd packages/dartian_i18n
dart create -t package .
```

Edite `pubspec.yaml`:

```yaml
name: dartian_i18n
version: 0.0.1
description: Dartian i18n

dev_dependencies:
  test: ^1.24.0
```

```bash
mkdir -p lib/src
dart pub get
```

Implemente:

- Classe `Translator` com método `translate(key)` ou `__(key)`
- Carregamento de mensagens de `resources/lang/`
- Fallback: se não encontrado em locale, tenta fallback (pt_BR → pt → en)
- Suporte a substituições: `__('greeting', {'name': 'John'})`

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "init: dartian_i18n with translation and fallback"
git push origin main
play_notification
```


***

### Etapa 9.2: Middleware e integração com views

**To-do:**

- [ ] Implementar I18nMiddleware
- [ ] Detectar locale de Accept-Language
- [ ] Integrar com Translator em views

**Instruções:**

Em `packages/dartian_http/`:

- Middleware `I18nMiddleware` que detecta locale de header Accept-Language
- Define locale current no contexto de requisição
- Integre Translator ao contexto de template mustache

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
git add .
git commit -m "feat: i18n middleware and view integration"
git push origin main
play_notification
```


***

### Etapa 9.3: Gerador "dartian make:lang"

**To-do:**

- [ ] Implementar subcomando make:lang
- [ ] Testar geração

**Instruções:**

Em `packages/dartian_cli/`, implemente "make:lang" que:

- Aceita código de locale (ex: `dartian make:lang pt_BR`)
- Cria arquivo `resources/lang/pt_BR/messages.dart`
- Fornece estrutura boilerplate

**Validação:**

```bash
dart test
dart analyze
dartian make:lang es
```

**Commit:**

```bash
git add .
git commit -m "feat: dartian make:lang generator"
git push origin main
play_notification
```


***

### Etapa 9.4: Testes 100% de i18n

**To-do:**

- [ ] Testes de tradução
- [ ] Testes de fallback
- [ ] Testes de substituições
- [ ] Testes de middleware
- [ ] Validar 100%

**Instruções:**

Em `packages/dartian_i18n/test/i18n_test.dart`:

- Carregar e traduzir chaves
- Fallback entre locales
- Substituições de parâmetros
- Middleware detecta locale
- Integração com templates

```bash
dart test --coverage=coverage
```

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
git add .
git commit -m "test: 100% coverage for i18n module"
git push origin main
play_notification
```


***

## FASE 10: Telemetria via Hooks (dartian_core)

### Etapa 10.1: Hooks de telemetria

**To-do:**

- [ ] Pesquisar observability patterns
- [ ] Criar pacote dartian_core
- [ ] Implementar TelemetryHooks
- [ ] Documentar integração OpenTelemetry

**Instruções:**

```
brave-search: "dart observability patterns"
brave-search: "opentelemetry dart"
```

```bash
cd packages/dartian_core
dart create -t package .
```

Edite `pubspec.yaml`:

```yaml
name: dartian_core
version: 0.0.1
description: Dartian core utilities

dev_dependencies:
  test: ^1.24.0
```

```bash
mkdir -p lib/src
dart pub get
```

Implemente:

- Classe `TelemetryHooks` com métodos estáticos:
    - `onRequest(request)` - requisição inicia
    - `onResponse(response, duration)` - requisição conclui
    - `onQueryExecuted(sql, duration)` - query ORM
    - `onJobQueued(job)` - job enfileirado
    - `onJobProcessed(job, duration)` - job processado
- Cada hook é lista de callbacks

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "init: dartian_core with telemetry hooks"
git push origin main
play_notification
```


***

### Etapa 10.2: Instrumentação do core

**To-do:**

- [ ] Adicionar hooks em HTTP kernel
- [ ] Adicionar hooks em ORM
- [ ] Adicionar hooks em Queue
- [ ] Testar chamadas

**Instruções:**

Modifique:

- `dartian_http/lib/src/kernel.dart`: Chamar `onRequest()` e `onResponse()`
- `dartian_orm/lib/src/database.dart`: Chamar `onQueryExecuted()`
- `dartian_queue/`: Chamar `onJobQueued()` e `onJobProcessed()`

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
git add .
git commit -m "feat: instrument core with telemetry hooks"
git push origin main
play_notification
```


***

### Etapa 10.3: Testes 100% de Telemetria

**To-do:**

- [ ] Testes de callbacks
- [ ] Testes de execução
- [ ] Validar 100%

**Instruções:**

Em `packages/dartian_core/test/telemetry_test.dart`:

- Registrar mock callbacks
- Verificar execução quando hooks são acionados
- Validar payload dos callbacks

```bash
dart test --coverage=coverage
```

**Validação:**

```bash
dart test
dart analyze
```

**Commit:**

```bash
git add .
git commit -m "test: 100% coverage for Telemetry module"
git push origin main
play_notification
```


***

## FASE 11: Deployment – AOT, Podman e WASI

### Etapa 11.1: Compilação AOT para produção

**To-do:**

- [ ] Pesquisar dart compile exe
- [ ] Implementar subcomando build exe
- [ ] Implementar subcomando build aot-snapshot
- [ ] Criar script de build
- [ ] Testar compilação

**Instruções:**

```
brave-search: "dart compile exe production"
brave-search: "dart aot compilation"
```

Em `packages/dartian_cli/`, implemente "build" que:

- `dartian build exe` executa `dart compile exe -O2 bin/main.dart -o dartian-aot`
- `dartian build aot-snapshot` gera AOT snapshot
- Ambos salvam artefatos em `build/` com timestamp

Crie `scripts/build.sh`:

- Limpa `build/`
- Executa `dart pub get` em todos
- Compila monorepo
- Gera relatório de tamanho

**Validação:**

```bash
dart test
dart analyze
dartian build exe
./build/dartian-aot version
```

**Commit:**

```bash
git add .
git commit -m "feat: AOT build for production"
git push origin main
play_notification
```


***

### Etapa 11.2: Podman multi-stage

**To-do:**

- [ ] Pesquisar Podman multi-stage builds
- [ ] Pesquisar Dart em Podman
- [ ] Criar Dockerfile
- [ ] Criar podman-compose.yml
- [ ] Testar build e execução

**Instruções:**

```
brave-search: "podman multi-stage build"
brave-search: "dart podman container"
brave-search: "podman-compose"
```

Crie `Dockerfile` na raiz:

```dockerfile
FROM archlinux:latest AS builder
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm dart base-devel
WORKDIR /app
COPY . .
RUN dart pub get && \
    for dir in packages/*/; do cd "$dir" && dart pub get && cd ../..; done && \
    dart compile exe -O2 bin/main.dart -o dartian-aot

FROM archlinux:latest AS runtime
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm ca-certificates
WORKDIR /app
COPY --from=builder /app/dartian-aot /app/dartian-aot
ENV PORT=8000
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD /app/dartian-aot health || exit 1
ENTRYPOINT ["/app/dartian-aot"]
```

Crie `podman-compose.yml`:

```yaml
version: '3.8'
services:
  dartian:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DB_DRIVER=sqlite
      - PORT=8000
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: dartian_dev
    ports:
      - "5432:5432"
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
```

Instale podman (já deve estar em Arch):

```bash
paru -S --needed --noconfirm podman podman-compose
```

Teste:

```bash
podman build -t dartian:test .
podman run --rm dartian:test version
```

**Validação:**

```bash
podman build -t dartian:test .
podman run --rm dartian:test version
```

**Commit:**

```bash
git add .
git commit -m "feat: Podman multi-stage build with compose"
git push origin main
play_notification
```


***

### Etapa 11.3: WASI suportado e testado

**To-do:**

- [ ] Pesquisar dart compile wasm
- [ ] Pesquisar wasmtime
- [ ] Criar script build-wasi.sh
- [ ] Criar testes WASI
- [ ] Documentar limitações

**Instruções:**

```
brave-search: "dart wasm wasi compilation"
brave-search: "wasmtime dart"
fetch: https://dart.dev/web/wasm
```

Instale wasmtime:

```bash
paru -S --needed --noconfirm wasmtime
```

Crie `scripts/build-wasi.sh`:

```bash
#!/bin/bash
mkdir -p build
dart compile wasm bin/main.dart -O2 -o build/dartian.wasm
if [ -f build/dartian.wasm ]; then
  echo "✅ WASM build successful"
  if command -v wasmtime &> /dev/null; then
    echo "Testing with wasmtime..."
    wasmtime build/dartian.wasm version || echo "⚠️ WASI test failed"
  fi
fi
```

```bash
chmod +x scripts/build-wasi.sh
./scripts/build-wasi.sh
```

Crie testes WASI com `@Tag('wasm')` para skip em CI simples

**Validação:**

```bash
./scripts/build-wasi.sh
```

**Commit:**

```bash
git add .
git commit -m "feat: WASI build and testing (experimental)"
git push origin main
play_notification
```


***

## FASE 12: Gerador de Código – Geradores "make:*"

### Etapa 12.1: Geradores de controller, model, migration

**To-do:**

- [ ] Pesquisar code generation patterns
- [ ] Implementar make:controller
- [ ] Implementar make:model
- [ ] Implementar make:migration
- [ ] Implementar make:request
- [ ] Implementar make:provider

**Instruções:**

```
brave-search: "cli code generation templates dart"
```

Em `packages/dartian_cli/`, implemente geradores que:

- `dartian make:controller UserController` → `app/Http/Controllers/UserController.dart`
- `dartian make:model User` → `app/Models/User.dart`
- `dartian make:migration create_users_table` → `database/migrations/YYYY_MM_DD_HHMM_SS_create_users_table.dart`
- `dartian make:request UserRequest` → `app/Http/Requests/UserRequest.dart`
- `dartian make:provider UserServiceProvider` → `app/Providers/UserServiceProvider.dart`

Use templates com placeholders (`{CLASS_NAME}`, `{TABLE_NAME}`, etc.)

**Validação:**

```bash
dart test
dart analyze
dartian make:controller TestController
```

**Commit:**

```bash
git add .
git commit -m "feat: make:* generators for scaffolding"
git push origin main
play_notification
```


***

### Etapa 12.2: Gerador de testes

**To-do:**

- [ ] Implementar make:test
- [ ] Testar geração

**Instruções:**

Estenda CLI para `dartian make:test` que:

- Aceita nome de teste
- Cria arquivo em `test/`
- Fornece template com imports e stubs

**Validação:**

```bash
dart test
dart analyze
dartian make:test SampleTest
```

**Commit:**

```bash
git add .
git commit -m "feat: make:test generator"
git push origin main
play_notification
```


***

## FASE 13: Hot Reload Completo

### Etapa 13.1: Watch e reload de arquivos

**To-do:**

- [ ] Pesquisar advanced hot reload strategies
- [ ] Refinar dartian serve
- [ ] Implementar watch de múltiplos diretórios
- [ ] Implementar preservação de estado
- [ ] Testar com mudanças reais

**Instruções:**

```
brave-search: "dart hot reload server state"
```

Refine "serve" em `packages/dartian_cli/`:

- Watch em `lib/`, `app/`, `routes/`, `resources/`
- Reload automático ao detectar mudança
- Preserve estado onde possível
- Exiba mensagens claras

**Validação:**

```bash
dart test
dart analyze
dartian serve
# Mudar arquivo e observar reload
```

**Commit:**

```bash
git add .
git commit -m "feat: complete hot reload with state preservation"
git push origin main
play_notification
```


***

## FASE 14: Qualidade de Código

### Etapa 14.1: Análise estática e linting

**To-do:**

- [ ] Pesquisar analysis_options best practices
- [ ] Configurar em todos os pacotes
- [ ] Criar script lint.sh
- [ ] Executar e corrigir warnings

**Instruções:**

```
brave-search: "dart analysis_options best practices"
```

Crie `analysis_options.yaml` em cada pacote com regras rígidas

Crie `scripts/lint.sh`:

```bash
#!/bin/bash
for dir in packages/*/; do
  cd "$dir"
  dart analyze
  cd ../..
done
```

```bash
chmod +x scripts/lint.sh
./scripts/lint.sh
```

**Validação:**

```bash
./scripts/lint.sh
```

**Commit:**

```bash
git add .
git commit -m "feat: strict analysis_options and lint scripts"
git push origin main
play_notification
```


***

### Etapa 14.2: Cobertura de testes consolidada

**To-do:**

- [ ] Criar script test-coverage.sh
- [ ] Executar em todos
- [ ] Consolidar relatórios
- [ ] Gerar HTML
- [ ] Validar >= 95%

**Instruções:**

Crie `scripts/test-coverage.sh`:

```bash
#!/bin/bash
for dir in packages/*/; do
  cd "$dir"
  dart test --coverage=coverage
  cd ../..
done

dart pub global activate coverage
format_coverage --lcov --in=coverage --out=coverage/lcov.info || true

# Validar threshold
coverage_percent=$(grep "LF:" coverage/lcov.info | awk '{sum+=$2} END {print int(sum)}')
if [ $coverage_percent -lt 95 ]; then
  echo "❌ Coverage below 95%: $coverage_percent%"
  exit 1
fi
```

```bash
chmod +x scripts/test-coverage.sh
./scripts/test-coverage.sh
```

**Validação:**

```bash
./scripts/test-coverage.sh
```

**Commit:**

```bash
git add .
git commit -m "feat: consolidated test coverage (>= 95%)"
git push origin main
play_notification
```


***

## FASE 15: Documentação e README

### Etapa 15.1: README principal

**To-do:**

- [ ] Pesquisar bons READMEs
- [ ] Criar README.md completo
- [ ] Adicionar badges
- [ ] Validar links

**Instruções:**

```
brave-search: "open source project readme best practices"
```

Crie `README.md` na raiz com seções:

- Visão geral
- Requisitos (Arch Linux, paru, podman)
- Instalação (Dart)
- Quick start
- Recursos principais
- Arquitetura
- Deployment (AOT, Podman, WASI)
- Contributing
- Licença (AGPLv3 + comercial)
- Links

Adicione badges: CI, cobertura, versão

**Commit:**

```bash
git add .
git commit -m "docs: comprehensive README with badges"
git push origin main
play_notification
```


***

### Etapa 15.2: CONTRIBUTING.md

**To-do:**

- [ ] Criar CONTRIBUTING.md
- [ ] Documentar processo
- [ ] Documentar padrões

**Instruções:**

Crie `CONTRIBUTING.md` com:

- Processo de fork e PR
- Padrões de código (analysis_options)
- Testes obrigatórios (100%)
- Commits semânticos
- Setup local

**Commit:**

```bash
git add .
git commit -m "docs: contributing guidelines"
git push origin main
play_notification
```


***

### Etapa 15.3: Exemplos de projeto

**To-do:**

- [ ] Criar examples/hello_world/
- [ ] Implementar projeto
- [ ] Testar execução
- [ ] Documentar

**Instruções:**

Crie `examples/hello_world/` com projeto Dartian funcional:

- pubspec.yaml dependendo de pacotes via path
- routes/web.dart com rotas simples
- app/Http/Controllers/WelcomeController.dart
- resources/views/welcome.mustache
- .env.example
- README com instruções

**Validação:**

```bash
cd examples/hello_world
dartian serve
curl http://localhost:8000
```

**Commit:**

```bash
cd ../..
git add .
git commit -m "docs: hello_world example project"
git push origin main
play_notification
```


***

## FASE 16: Projeto de Teste Integrado

### Etapa 16.1: Projeto integrado

**To-do:**

- [ ] Criar testing-project/
- [ ] Implementar app completo
- [ ] Testar end-to-end
- [ ] Documentar

**Instruções:**

Crie `testing-project/` na raiz com projeto que usa:

- Todos os módulos do Dartian
- Roteamento completo
- ORM com migrations
- Filas e scheduler
- Autenticação
- Views com i18n
- Hooks de telemetria

Teste todos:

```bash
cd testing-project
dart test
dart analyze
dartian serve
# Testar endpoints
dartian queue:work
dartian schedule:run
```

**Commit:**

```bash
cd ..
git add .
git commit -m "test: full integration testing project"
git push origin main
play_notification
```


***

## FASE 17: CI/CD Básico

### Etapa 17.1: GitHub Actions workflow

**To-do:**

- [ ] Pesquisar GitHub Actions for Dart
- [ ] Criar .github/workflows/ci.yml
- [ ] Configurar para main
- [ ] Testar workflow

**Instruções:**

```
brave-search: "github actions dart workflow"
```

Instale gh:

```bash
paru -S --needed --noconfirm github-cli
```

Crie `.github/workflows/ci.yml`:

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
      - run: dart pub global activate -s path ./packages/dartian_cli
      - run: dartian --version
      - run: |
          for dir in packages/*/; do
            cd "$dir"
            dart pub get
            dart analyze
            dart test --coverage=coverage
            cd ../..
          done
      - run: dart pub global activate coverage
      - run: format_coverage --lcov --in=coverage --out=coverage/lcov.info || true
```

Teste:

```bash
git add .
git commit -m "ci: GitHub Actions workflow for main branch"
git push origin main
sleep 30
gh run list --limit 1
gh run view
```

**Commit após CI passar:**

```bash
play_notification
```


***

## FASE 18: Verificações Finais e Release

### Etapa 18.1: Smoke tests finais

**To-do:**

- [ ] Testar CLI completo
- [ ] Testar servidor
- [ ] Testar deployment
- [ ] Testar cobertura
- [ ] Documentar

**Instruções:**

Execute lista completa:

```bash
dartian version
dartian help
dartian new test_app
dartian make:controller TestController
dartian make:model TestModel
dartian make:migration create_tests_table
dartian make:request TestRequest
dartian make:provider TestServiceProvider
dartian make:view test
dartian make:lang es
dartian make:test TestTest

cd testing-project
dartian serve &
sleep 3
curl http://localhost:8000
kill %1

dartian build exe
./build/dartian-aot version

podman build -t dartian:final .
podman run --rm dartian:final version

./scripts/build-wasi.sh
```

**Commit:**

```bash
cd ..
git add .
git commit -m "test: comprehensive smoke tests validation"
git push origin main
sleep 30
gh run list --limit 1
gh run view
play_notification
```


***

### Etapa 18.2: Limpeza final

**To-do:**

- [ ] Executar dart format
- [ ] Verificar .gitignore
- [ ] Remover temporários
- [ ] Bateria final
- [ ] Validar histórico

**Instruções:**

```bash
for dir in packages/*/; do
  cd "$dir"
  dart format --set-exit-if-changed lib/ bin/ test/ || true
  cd ../..
done

for dir in packages/*/; do
  cd "$dir"
  dart test
  dart analyze
  cd ../..
done

git status
git log --oneline | head -30
```

**Commit:**

```bash
git add .
git commit -m "chore: final cleanup and formatting"
git push origin main
sleep 30
gh run list --limit 1
gh run view
play_notification
```


***

### Etapa 18.3: Tag de release v1.0.0

**To-do:**

- [ ] Validar CI verde
- [ ] Criar tag
- [ ] Push tag
- [ ] Criar release
- [ ] Notificar conclusão

**Instruções:**

Validar CI:

```bash
gh run list --limit 1
gh run view
```

Criar tag:

```bash
git tag -a v1.0.0 -m "Dartian MVP v1.0.0 - Initial Release

Core Modules Completed:
- dartian_cli: CLI with subcommands
- dartian_http: HTTP kernel with shelf
- dartian_router: Router with fluent DSL
- dartian_di: DI with get_it and auto-discovery
- dartian_orm: ORM with Drift (SQLite + PostgreSQL)
- dartian_redis: Redis cache and pub/sub
- dartian_queue: Job queues (sync, isolate, Redis)
- dartian_scheduler: Task scheduling with cron
- dartian_auth: Session and JWT authentication
- dartian_view: SSR with mustache
- dartian_i18n: Internationalization
- dartian_core: Telemetry hooks

Features:
- 100% test coverage per module
- AOT compilation for production
- Podman containerization
- WASI support (experimental)
- Hot reload in development
- GitHub Actions CI/CD
- Comprehensive documentation

License: AGPLv3 with commercial option
Platform: Arch Linux, Dart 3.x+
Container: Podman + podman-compose"

git push origin v1.0.0

gh release create v1.0.0 \
  --title "Dartian MVP v1.0.0" \
  --notes "Dartian framework MVP completo. Consulte README.md para instruções de uso." \
  --latest
```

Final notification:

```bash
play_notification
echo "🎉🎉🎉 DARTIAN MVP COMPLETO! 🎉🎉🎉"
echo ""
echo "✅ Todos os módulos implementados"
echo "✅ Cobertura >= 95%"
echo "✅ CI/CD verde na main"
echo "✅ Documentação completa"
echo "✅ Tag v1.0.0 criada"
echo "✅ GitHub Release publicado"
echo ""
echo "Status: PRODUCTION READY"
```


***

## RESUMO EXECUTIVO

**Plano Final Optimizado:**

- Arch Linux com paru (pré-instalado)
- Podman + podman-compose
- Branch: main (única, sem branching)
- Commits diretos após validação
- CI/CD: GitHub Actions dispara em push main
- Finalização: Tag v1.0.0 + GitHub Release
- Objetivo: MVP production-ready

**Estrutura: 18 Fases, 65+ Etapas**

- Fase 0: Setup
- Fases 1-10: Módulos Core
- Fase 11: Deployment
- Fases 12-14: Geradores e Qualidade
- Fases 15-16: Documentação
- Fases 17-18: CI/CD e Release

**Princípios:**

1. Pesquise sempre (genérico → específico)
2. Teste continuamente (dart test + analyze)
3. Commit frequentemente após sucesso
4. Monitore CI (gh + sleep 30s)
5. Execute play_notification por etapa
6. Adapte dinamicamente conforme necessário
7. Use paru para dependências do sistema
8. Use podman para containers
9. Trabalhe direto na main

***

**PLANO PRONTO PARA EXECUÇÃO AUTÔNOMA** 🚀

