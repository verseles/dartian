# Plano Executivo Detalhado para o Jules – Dartian MVP Autônomo

Este plano é orientado para execução durante repouso do desenvolvedor. O Jules deve seguir cada etapa, executar verificações rigorosas, pesquisar soluções na internet quando preso, e reportar via commits e logs até o PR final.

***

## FASE PRELIMINAR: Setup Inicial e Validação

### Etapa 0.1: Verificação do ambiente Dart
**Objetivo:** Garantir que o Dart SDK esteja instalado, atualizado e funcional antes de qualquer ação.

**Instruções:**
- Execute `dart --version` e capture a saída; deve exibir versão 3.x ou superior.[1]
- Se não instalado, siga o guia oficial em https://dart.dev/get-dart para instalação no Linux/macOS/Windows conforme o SO da VM.
- Após instalar, execute `dart --version` novamente e valide sucesso.
- Execute `dart pub global activate` para garantir que a ativação de pacotes globais funciona (necessário para a CLI "dartian").
- Se qualquer passo falhar, pesquise no GitHub Dart (https://github.com/dart-lang/sdk/issues) ou no site oficial por "Dart installation" + SO, aplique patch necessário e tente novamente.

**Verificações esperadas:**
- Saída de versão deve conter "Dart SDK" e versão >= 3.0.
- Comando `dart help` deve listar opções de subcomandos.
- `dart pub global list` (mesmo que vazio) deve executar sem erro.

---

### Etapa 0.2: Configuração do Git e repositório local
**Objetivo:** Preparar o repositório Git local para trabalho iterativo e commits frequentes.

**Instruções:**
- Verifique se o repositório Git "dartian" já existe localmente com `git status` na raiz do projeto.
- Se não, clone-o ou crie com `git init` (o Jules já deve estar dentro do diretório correto do projeto, conforme informado).
- Configure identidade local com `git config user.name "Dartian MVP Builder"` e `git config user.email "dartian@builder.local"`.
- Crie uma branch de desenvolvimento com `git checkout -b feat/dartian-mvp` (ou use branch já existente se confirmada).
- Verifique o status com `git status` e confirme que a árvore está limpa ou em estado consistente.

**Verificações esperadas:**
- `git log` deve exibir histórico, mesmo que vazio em novo repo.
- `git branch` deve mostrar a branch atual como "feat/dartian-mvp".
- Não deve haver conflitos ou árvore suja antes de iniciar.

***

### Etapa 0.3: Estrutura de diretórios do monorepo
**Objetivo:** Estabelecer a estrutura de pastas esperada para o monorepo de pacotes.

**Instruções:**
- Na raiz do projeto (onde `.git/` existe), crie a estrutura de pastas:
  ```
  ./packages/
    dartian_cli/
    dartian_core/
    dartian_http/
    dartian_router/
    dartian_di/
    dartian_orm/
    dartian_redis/
    dartian_queue/
    dartian_scheduler/
    dartian_view/
    dartian_i18n/
  ```
- Execute `mkdir -p packages/{dartian_cli,dartian_core,dartian_http,dartian_router,dartian_di,dartian_orm,dartian_redis,dartian_queue,dartian_scheduler,dartian_view,dartian_i18n}` em um único comando.
- Crie também diretórios de raiz: `./docs`, `./examples`, `./scripts`, `./.github/workflows`.
- Execute `ls -la packages/` e verifique que todas as pastas foram criadas.

**Verificações esperadas:**
- Cada pasta em `packages/` deve ser um diretório vazio.
- Comando `find packages/ -type d | wc -l` deve retornar 12 (11 pacotes + 1 "packages" pai).

***

### Etapa 0.4: Compilação e targets verificados
**Objetivo:** Validar que todos os targets de compilação (exe, aot-snapshot, wasm) estão funcionais.

**Instruções:**
- Execute `dart compile exe --help` para confirmar que a compilação para executável nativo está disponível.
- Execute `dart compile aot-snapshot --help` para confirmar AOT snapshot.
- Execute `dart help compile wasm` para confirmar suporte a WASM (mesmo que experimental).
- Se qualquer comando falhar, pesquise no blog oficial (https://dart.dev/tools/dart-compile) ou no GitHub (https://github.com/dart-lang/sdk/releases) pela release notes do Dart para confirmação de suporte e aplique workaround se necessário.
- Crie um teste prototípico: execute `dart create -t console test_app` em pasta temporária, compile com `dart compile exe`, e execute o binário para confirmar pipeline completo.

**Verificações esperadas:**
- Todos os comandos "dart compile" devem exibir ajuda ou opções sem erro.
- O teste prototípico deve gerar um binário executável.

***

## FASE 1: CLI Bootstrap (dartian_cli)

### Etapa 1.1: Inicialização do pacote CLI
**Objetivo:** Criar a estrutura inicial do pacote dartian_cli com o comando executável "dartian".

**Instruções:**
- Dentro de `packages/dartian_cli/`, execute `dart create -t console .` (note o ponto final para criar no diretório atual).
- Edite `pubspec.yaml` para adicionar nome `name: dartian_cli`, versão inicial `version: 0.0.1` e descrição "Dartian framework CLI".
- Crie a estrutura de diretórios internos:
  ```
  bin/
    dartian.dart          # Ponto de entrada executável
  lib/
    src/
      commands/           # Subcomandos (new, serve, make:*, etc.)
      helpers/            # Utilitários e funções auxiliares
    dartian_cli.dart      # Exporta API pública da CLI
  test/
    command_test.dart     # Testes dos subcomandos
  ```
- No `bin/dartian.dart`, crie um programa que:
  - Parse argumentos de linha de comando com `dart:io` e `package:args` (adicione ao pubspec.yaml).
  - Reconheça subcomandos: `version`, `help`, `new`, `serve`, `make:*`, `migrate`, `queue:work`, `schedule:run`, `test`, `build` (listar apenas, implementação em etapas posteriores).
  - Para "version", retorne "Dartian 0.0.1".
  - Para "help", liste subcomandos disponíveis.
  - Para outros, exiba "Not implemented yet" com placeholder.
- Commit com mensagem "init: dartian_cli with basic CLI structure".

**Verificações esperadas:**
- `dart run bin/dartian.dart version` deve exibir "Dartian 0.0.1".
- `dart run bin/dartian.dart help` deve listar subcomandos.
- `dart run bin/dartian.dart new` deve exibir "Not implemented yet".
- Sem erros de compilação ou análise.

***

### Etapa 1.2: Testes unitários do CLI
**Objetivo:** Cobrir 100% da lógica de parsing e roteamento de subcomandos com testes.

**Instruções:**
- Em `test/command_test.dart`, crie testes para:
  - Parsing correto de "version" com esperado "Dartian 0.0.1".
  - Parsing correto de "help" com lista de subcomandos.
  - Rejeição de subcomandos desconhecidos com mensagem de erro apropriada.
  - Tratamento de ausência de argumentos (deve exibir ajuda por padrão).
- Use `package:test` para framework de testes (adicione ao pubspec.yaml em dev_dependencies).
- Execute `dart test` e confirme que todos os testes passam.
- Se falhar, revise a lógica de parsing no `bin/dartian.dart` ou adicione debugging com logs.
- Capture cobertura com `dart pub global activate coverage` e `dart test --coverage=coverage`, depois execute `format_coverage --lcov --in=coverage/coverage.json --out=coverage/lcov.info` e verifique que cobertura de comando está acima de 90%.

**Verificações esperadas:**
- Todos os testes em `test/command_test.dart` devem passar.
- Cobertura de linhas do CLI deve estar acima de 90% (idealmente 100%).
- Sem avisos de análise estática (execute `dart analyze`).

***

### Etapa 1.3: Instalação global da CLI
**Objetivo:** Tornar "dartian" disponível como comando global na VM.

**Instruções:**
- Execute `dart pub global activate -s path .` dentro do diretório `packages/dartian_cli/` para ativar o pacote como comando global a partir do caminho local.
- Verifique se o comando está disponível: `dartian version` deve retornar "Dartian 0.0.1".
- Se não funcionar, pesquise no GitHub (https://github.com/dart-lang/pub/issues) por "dart pub global activate path" e aplique workaround sugerido.
- Commit com mensagem "feat: CLI global activation and smoke tests".

**Verificações esperadas:**
- Comando `dartian version` (sem prefixo `dart run`) deve funcionar de qualquer diretório.
- `dartian help` deve listar subcomandos.

***

## FASE 2: HTTP Kernel e Roteamento (dartian_http + dartian_router)

### Etapa 2.1: Inicialização e integração de shelf
**Objetivo:** Criar kernel HTTP baseado em shelf com suporte a Request/Response e middlewares.

**Instruções:**
- Em `packages/dartian_http/`, execute `dart create -t package .`.
- Edite `pubspec.yaml`: adicione `name: dartian_http`, versão 0.0.1, e dependência `shelf: ^1.4.1`.
- Crie estrutura de diretórios:
  ```
  lib/
    src/
      kernel.dart         # Classe principal HttpKernel
      request.dart        # Extensão/wrapper de Request de shelf
      response.dart       # Extensão/wrapper de Response de shelf
      middleware.dart     # Definição de contrato de middleware
    dartian_http.dart     # Exporta API pública
  test/
    kernel_test.dart      # Testes do kernel
    middleware_test.dart  # Testes de middleware
  ```
- Implemente `HttpKernel` com métodos: `listen(host, port)` que inicia servidor shelf, `handle(request)` que retorna Response, e integração de middleware pipeline conforme shelf.
- Adicione helpers básicos em `response.dart` para retornar JSON, HTML, texto com status codes apropriados (200, 404, 500).
- Commit com "init: dartian_http kernel with shelf integration".

**Verificações esperadas:**
- `dart analyze` sem erros em `dartian_http/`.
- Imports de shelf funcionam sem erro.

***

### Etapa 2.2: Roteador com shelf_router
**Objetivo:** Criar DSL fluente de roteamento sobre shelf_router.

**Instruções:**
- Em `packages/dartian_router/`, execute `dart create -t package .`.
- Adicione ao `pubspec.yaml`: `shelf_router: ^1.2.0`.
- Crie estrutura:
  ```
  lib/
    src/
      router.dart         # Classe Router com DSL fluente
      route.dart          # Classe Route para representar uma rota
      group.dart          # Suporte a grupos de rotas
    dartian_router.dart   # Exporta API pública
  test/
    router_test.dart      # Testes de roteamento
  ```
- Implemente `Router` com métodos fluentes: `get(path, handler)`, `post(path, handler)`, `put(path, handler)`, `delete(path, handler)`, `group(prefix, callback)`, `name(name)` para rotas nomeadas.
- Suporte parâmetros de rota (ex.: `/users/:id`) com type-safe extraction.
- Integre com shelf_router internamente mas exponha apenas a API do Dartian.
- Commit com "init: dartian_router with fluent DSL".

**Verificações esperadas:**
- `dart analyze` sem erros em `dartian_router/`.
- Imports de shelf_router funcionam.

***

### Etapa 2.3: Hot reload em "dartian serve"
**Objetivo:** Implementar servidor de desenvolvimento com hot reload para rotas e handlers.

**Instruções:**
- Em `packages/dartian_cli/`, estenda o subcomando "serve" para:
  - Aceitar opcionalmenteargumentos `--host` (padrão localhost) e `--port` (padrão 8000).
  - Carregar arquivo de rotas (presumidamente `routes/web.dart` em estrutura de projeto futuro, por agora fake).
  - Iniciar HttpKernel com Router e ouvir por mudanças em arquivos `.dart` usando `package:watcher` (adicione ao pubspec).
  - Ao detectar mudança, recarregar o arquivo de rotas e reiniciar o servidor sem perder estado de middleware.
- Exiba mensagem "Server listening on http://localhost:8000" quando pronto.
- Commit com "feat: dartian serve with hot reload support".

**Verificações esperadas:**
- `dartian serve` inicia um servidor na porta 8000 e exibe mensagem.
- Simule mudança em arquivo e verifique que hot reload é detectado (via logs).

***

### Etapa 2.4: Testes completos HTTP + Router
**Objetivo:** Cobertura 100% de HTTP kernel, router e hot reload com testes de integração.

**Instruções:**
- Em `packages/dartian_http/test/`, adicione `kernel_test.dart` com testes para:
  - Inicializar kernel, receber requisição GET, retornar Response 200 com body esperado.
  - Testar middleware pipeline (adicionar middleware que modifica header, verificar presença).
  - Testar negociação de conteúdo (Accept: application/json vs text/html).
  - Testar erro handler (rota 404, erro 500).
- Em `packages/dartian_router/test/`, adicione `router_test.dart` com testes para:
  - Matching simples de rota (GET /users).
  - Parâmetros de rota (GET /users/:id com id=123).
  - Grupos de rotas (POST /api/v1/users com prefixo e grupo).
  - Rotas nomeadas e resolução reversa.
  - 404 quando rota não encontrada.
- Execute `dart test` em ambos os pacotes e confirme 100% de cobertura.
- Commit com "test: 100% coverage for http and router modules".

**Verificações esperadas:**
- `dart test` em `dartian_http/` e `dartian_router/` deve exibir todos os testes passando.
- `dart test --coverage=coverage` deve mostrar cobertura >= 100% (ou próxima).

***

## FASE 3: Injeção de Dependências (dartian_di)

### Etapa 3.1: Service Container com get_it
**Objetivo:** Implementar DI e Service Locator usando get_it como base.

**Instruções:**
- Em `packages/dartian_di/`, execute `dart create -t package .`.
- Adicione ao `pubspec.yaml`: `get_it: ^8.0.0`.
- Crie estrutura:
  ```
  lib/
    src/
      container.dart      # Wrapper e API do Dartian sobre get_it
      provider.dart       # Classe ServiceProvider base
      resolver.dart       # Resolução e registro de dependências
    dartian_di.dart       # Exporta API pública
  test/
    container_test.dart   # Testes de DI
  ```
- Implemente `Container` como facade que:
  - Expõe métodos: `register<T>(factory)`, `singleton<T>(instance)`, `resolve<T>()`.
  - Suporta lazy initialization com `lazyFactory`.
  - Detecta ciclos de dependência e exibe erro descritivo.
- Implemente `ServiceProvider` base para que aplicações definam providers customizados.
- Commit com "init: dartian_di with get_it integration".

**Verificações esperadas:**
- `dart analyze` sem erros.
- Imports de get_it funcionam.

***

### Etapa 3.2: Auto-discovery e geração estática
**Objetivo:** Habilitar auto-discovery em dev com geração de código estático para build.

**Instruções:**
- Adicione ao `pubspec.yaml` de `dartian_di`: `build_runner: ^2.4.0` e `source_gen: ^1.4.0` em dev_dependencies.
- Crie um builder customizado (ou use configuração mínima com source_gen) que:
  - Procura por anotações `@Service()` ou `@Singleton()` em arquivos do projeto.
  - Gera arquivo `lib/src/generated_providers.dart` com registros estáticos.
  - Arquivo gerado pode ser carregado em tempo de build, evitando reflective lookup em runtime.
- Documenta como usar: `@Service() class MyService {}` vai gerar auto-registro.
- Commit com "feat: auto-discovery with code generation".

**Verificações esperadas:**
- `dart run build_runner build` em projeto que use `@Service()` deve gerar arquivo `generated_providers.dart`.
- Arquivo gerado deve ser válido Dart sem erros.

***

### Etapa 3.3: Integração com HTTP kernel
**Objetivo:** Conectar DI ao kernel HTTP para resolução automática de controllers/handlers.

**Instruções:**
- Modifique `dartian_http/lib/src/kernel.dart` para aceitar instância de `Container` (do dartian_di) como dependência.
- Adicione middleware que popula `Request` com acesso ao container via contexto de shelf.
- Implemente resolução automática: quando handler é controller com dependências, resolver automaticamente.
- Commit com "feat: HTTP kernel DI integration".

**Verificações esperadas:**
- Kernel HTTP consegue resolver serviços registrados em Container.
- Teste: registrar um `Service`, injetar em handler, verificar instância.

***

### Etapa 3.4: Testes 100% de DI
**Objetivo:** Cobertura completa de funcionalidade DI.

**Instruções:**
- Em `test/container_test.dart`, adicione testes para:
  - Registro e resolução de singleton.
  - Registro e resolução de factory.
  - Lazy initialization.
  - Detecção de ciclo (A depende de B, B depende de A).
  - Auto-discovery com anotações (se implementado).
  - Integração com HTTP kernel.
- Execute `dart test` e confirme 100% de cobertura.
- Commit com "test: 100% coverage for DI module".

**Verificações esperadas:**
- `dart test` em `dartian_di/` com todos os testes passando.
- Cobertura >= 100%.

***

## FASE 4: ORM e Data Layer (dartian_orm)

### Etapa 4.1: Integração com Drift
**Objetivo:** Preparar camada ORM sobre Drift com API "Eloquent-like".

**Instruções:**
- Em `packages/dartian_orm/`, execute `dart create -t package .`.
- Adicione ao `pubspec.yaml`:
  - `drift: ^2.14.0` e `drift_dev: ^2.14.0` em dev_dependencies.
  - `sqlite3: ^3.2.0` para suporte local.
  - `postgres: ^3.0.0` para PostgreSQL em produção.
- Crie estrutura:
  ```
  lib/
    src/
      database.dart       # Classe Database base integrando Drift
      model.dart          # Base model com helpers Eloquent-like
      builder.dart        # Query builder fluente
      migration.dart      # Suporte a migrações
    dartian_orm.dart      # Exporta API pública
  test/
    orm_test.dart         # Testes de ORM com SQLite em memória
  ```
- Implemente classe `Database` que wrappa Drift's `GeneratedDatabase` com métodos: `table<T>()`, `query<T>()`, `migrate()`, `seed()`.
- Implemente `Model` base com helpers: `save()`, `delete()`, `where()`, `all()`, `find(id)`, relações básicas.
- Query builder com métodos fluentes: `where()`, `select()`, `join()`, `limit()`, `order()`.
- Commit com "init: dartian_orm with Drift integration".

**Verificações esperadas:**
- `dart analyze` sem erros.
- Imports de Drift funcionam.

---

### Etapa 4.2: Migrations
**Objetivo:** Implementar sistema de migrações para schema versioning.

**Instruções:**
- Crie em `lib/src/migration.dart`:
  - Classe abstrata `Migration` com métodos `up()` e `down()`.
  - Executor de migrações que:
    - Lê migrações de `database/migrations/` em estrutura futura de projeto.
    - Registra versão no banco (tabela `migrations`).
    - Executa apenas migrações não executadas (forward progress).
    - Suporta rollback com `down()`.
- Integre com CLI: `dartian migrate` e `dartian migrate:rollback`.
- Commit com "feat: migration system with versioning".

**Verificações esperadas:**
- `dartian migrate` deve criar tabela `migrations` e executar migrações.
- `dartian migrate:rollback` deve reverter última migração.

***

### Etapa 4.3: SQLite e PostgreSQL drivers
**Objetivo:** Suportar ambos os bancos no MVP com configuração por ambiente.

**Instruções:**
- Modifique `Database` para aceitar parâmetro de driver:
  - `Database.sqlite(path: 'app.db')` para SQLite local.
  - `Database.postgres(host, port, database, user, password)` para PostgreSQL remoto.
- Use variáveis de ambiente `.env` para determinar driver padrão: `DB_DRIVER=sqlite` ou `DB_DRIVER=postgres`.
- Implemente DI Service para `Database`: quando container resolve, lê .env e instancia driver apropriado.
- Commit com "feat: SQLite and PostgreSQL driver support".

**Verificações esperadas:**
- Ambos os drivers conseguem criar conexão e executar queries simples.

***

### Etapa 4.4: Testes 100% de ORM
**Objetivo:** Cobertura completa com SQLite in-memory e tags de integração para Postgres.

**Instruções:**
- Em `test/orm_test.dart`, adicione testes para:
  - Criar tabela, inserir, recuperar, atualizar, deletar com SQLite in-memory.
  - Query builder: where, select, join, limit, order.
  - Migrações: up, down, reexecução.
  - Relações: one-to-many, many-to-one básicas.
  - Marque testes de PostgreSQL com `@Tag('integration')` para execução condicional.
- Para Postgres, forneça docker-compose.yml com container PostgreSQL e instruções de setup.
- Execute `dart test` e confirme 100% de cobertura (skip integration se não houver Postgres).
- Commit com "test: 100% coverage for ORM module".

**Verificações esperadas:**
- `dart test` com SQLite in-memory sem dependências externas.
- `dart test --tags="!integration"` deve ignorar testes Postgres.
- Cobertura >= 100% para code path principal.

***

## FASE 5: Cache e Filas (dartian_redis, dartian_queue)

### Etapa 5.1: Redis client integration
**Objetivo:** Integrar cliente Redis consolidado para cache, pub/sub e filas.

**Instruções:**
- Em `packages/dartian_redis/`, execute `dart create -t package .`.
- Adicione ao `pubspec.yaml`: `redis: ^4.8.0` ou `dartis: ^1.0.0` (ambos consolidados).
- Crie estrutura:
  ```
  lib/
    src/
      redis.dart          # Wrapper do cliente Redis
      cache.dart          # Abstração de cache
    dartian_redis.dart
  test/
    redis_test.dart       # Testes com Redis mockado/local
  ```
- Implemente classe `RedisManager` que:
  - Conecta a Redis via host/port (variáveis de ambiente).
  - Expõe métodos: `get(key)`, `set(key, value, ttl)`, `delete(key)`, `increment(key)`, `publish(channel, message)`, `subscribe(channel, callback)`.
- Crie abstração `CacheDriver` que pode ter implementação in-memory fallback e Redis quando disponível.
- Commit com "init: dartian_redis with client integration".

**Verificações esperadas:**
- Imports de Redis cliente funcionam.
- Conexão simples pode ser testada (mesmo que falhe sem Redis rodando, estrutura está correta).

---

### Etapa 5.2: Filas (sync, isolates, Redis)
**Objetivo:** Sistema de filas abstrato com múltiplos drivers.

**Instruções:**
- Em `packages/dartian_queue/`, execute `dart create -t package .`.
- Adicione ao `pubspec.yaml`: `dartian_redis` como dependência local (path: ../dartian_redis).
- Crie estrutura:
  ```
  lib/
    src/
      queue.dart          # Classe Queue principal
      job.dart            # Classe Job abstrata
      drivers/
        sync_driver.dart  # Driver que executa imediatamente
        isolate_driver.dart # Driver que spawna isolate
        redis_driver.dart  # Driver persistente em Redis
    dartian_queue.dart
  test/
    queue_test.dart       # Testes de fila
  ```
- Implemente `Queue` que:
  - Aceita parâmetro `driver: 'sync' | 'isolate' | 'redis'`.
  - Expõe `enqueue(Job)`, `dequeue()`, `process()`.
  - Drivers executam jobs com retry logic e backoff configurável.
- Implemente `Job` abstrata com `handle()` e `failed()` hooks.
- Driver sync: executa imediatamente (para testes).
- Driver isolate: spawna novo isolate para cada job (paralelismo).
- Driver Redis: persiste jobs em lista Redis, processados por worker.
- Commit com "init: dartian_queue with drivers".

**Verificações esperadas:**
- Sync driver executa job imediatamente.
- Isolate driver spawna isolate sem erro.
- Redis driver enfileira em estrutura Redis (pode falhar sem Redis rodando, ok).

***

### Etapa 5.3: Worker CLI
**Objetivo:** Implementar `dartian queue:work` para processar filas em background.

**Instruções:**
- Em `packages/dartian_cli/`, estenda subcomando "queue:work" para:
  - Conectar a Queue com driver configurado (via .env).
  - Dequeue jobs continuamente com timeout configurável.
  - Processar job, capturar exceções, chamar `job.failed()` se erro.
  - Retry com backoff exponencial.
  - Responder a sinais SIGTERM para graceful shutdown (concluir job atual e sair).
- Commit com "feat: dartian queue:work command".

**Verificações esperadas:**
- `dartian queue:work` inicia e processa jobs (com sync driver, testa imediatamente).
- Graceful shutdown funciona ao enviar SIGTERM.

---

### Etapa 5.4: Testes 100% de Redis e Queue
**Objetivo:** Cobertura completa com mocks para Redis.

**Instruções:**
- Em `test/`, adicione testes para:
  - Redis: mock client com `package:mockito` ou similar, testar get/set/publish.
  - Queue: enqueue/dequeue, retry logic, backoff, driver switching.
  - Worker: processar jobs, falhas, graceful shutdown.
  - Marque testes de Redis/Isolate com `@Tag('integration')` para skip em CI simples.
- Execute `dart test` e confirme 100% de cobertura.
- Commit com "test: 100% coverage for Redis and Queue modules".

**Verificações esperadas:**
- Sync driver testado sem dependências externas (100% cobertura).
- Redis e Isolate testados com tags, skippáveis.

***

## FASE 6: Scheduler (dartian_scheduler)

### Etapa 6.1: Integração com cron
**Objetivo:** Agendar tarefas com expressões cron usando pacote estabelecido.

**Instruções:**
- Em `packages/dartian_scheduler/`, execute `dart create -t package .`.
- Adicione ao `pubspec.yaml`: `cron: ^0.7.0` (ou versão mais recente consolidada).
- Crie estrutura:
  ```
  lib/
    src/
      scheduler.dart      # Classe Scheduler com DSL
      task.dart           # Classe Task abstrata
    dartian_scheduler.dart
  test/
    scheduler_test.dart   # Testes de agendamento
  ```
- Implemente `Scheduler` que:
  - Expõe método `add(expression, callback)` para agendar com expressão cron (ex: "0 * * * *").
  - Suporta `every(duration, callback)` para intervalos simples.
  - Suporta `runAsync()` que executa o scheduler e processa tarefas indefinidamente.
  - Permita pausar/resumir execução.
- Implemente `Task` abstrata com `run()` hook para definir jobs customizados em subclasses.
- Commit com "init: dartian_scheduler with cron".

**Verificações esperadas:**
- Imports de cron funcionam.
- Scheduler consegue adicionar tarefas sem erro.

***

### Etapa 6.2: CLI e integração com filas
**Objetivo:** Implementar `dartian schedule:run` e integração com queue para jobs.

**Instruções:**
- Em `packages/dartian_cli/`, estenda "schedule:run" para:
  - Inicializar Scheduler.
  - Carregar tarefas agendadas de provider (futuro) ou arquivo de configuração.
  - Executar `runAsync()` indefinidamente.
  - Responder a SIGTERM para graceful shutdown.
  - Opcionalmente despachar jobs em Queue em vez de executar inline.
- Commit com "feat: dartian schedule:run command".

**Verificações esperadas:**
- `dartian schedule:run` inicia scheduler e aguarda.
- Tarefas agendadas executam no horário esperado (teste com `every(1 second)`).

***

### Etapa 6.3: Testes 100% de Scheduler
**Objetivo:** Cobertura completa de agendamento e execução.

**Instruções:**
- Em `test/scheduler_test.dart`, adicione testes para:
  - Parsing de expressões cron válidas.
  - Execução de task no tempo esperado (mock time ou mini-intervals).
  - `every()` com durações pequenas.
  - Pausa e resumo.
  - Erros em tasks e recuperação.
- Execute `dart test` e confirme 100% de cobertura.
- Commit com "test: 100% coverage for Scheduler module".

**Verificações esperadas:**
- `dart test` com todos os testes passando.
- Cobertura >= 100%.

***

## FASE 7: Autenticação e Segurança (dartian_auth, integrações)

### Etapa 7.1: Autenticação com sessão e JWT
**Objetivo:** Implementar guards de autenticação para sessão/cookies e JWT.

**Instruções:**
- Em `packages/dartian_auth/` (novo), execute `dart create -t package .`.
- Adicione ao `pubspec.yaml`: `crypto: ^3.0.0` para hashing seguro.
- Crie estrutura:
  ```
  lib/
    src/
      guard.dart          # Classe Guard abstrata
      session_guard.dart  # Implementação de sessão/cookies
      jwt_guard.dart      # Implementação de JWT
      user.dart           # Interface User para autenticação
    dartian_auth.dart
  test/
    auth_test.dart        # Testes de autenticação
  ```
- Implemente `Guard` com métodos: `attempt(username, password)`, `login(user)`, `logout()`, `user()`, `check()`.
- Implemente `SessionGuard` que armazena user ID em sessão HTTP (via cookie, em futuro integrado com middleware).
- Implemente `JwtGuard` que emite/valida tokens JWT com payload do user.
- Hashing de senha com argon2 ou bcrypt (use `crypto` ou `argon2` package).
- Commit com "init: dartian_auth with guards".

**Verificações esperadas:**
- Guards conseguem ser instanciados.
- Métodos de guard compilam sem erro.

***

### Etapa 7.2: CORS e CSRF
**Objetivo:** Middlewares configuráveis de CORS e proteção CSRF.

**Instruções:**
- Em `packages/dartian_http/`, adicione middlewares:
  - `CorsMiddleware` que:
    - Em dev, permite todos (Access-Control-Allow-Origin: *).
    - Em prod, valida contra allowlist de origins (via .env).
    - Responde a CORS preflight (OPTIONS).
  - `CsrfMiddleware` que:
    - Gera token CSRF em cada resposta (via cookie e header).
    - Valida token em POST/PUT/DELETE.
    - Configurável por rota/grupo (opt-in para stateful).
- Integre ao kernel HTTP default.
- Commit com "feat: CORS and CSRF middleware".

**Verificações esperadas:**
- Middleware CORS responde apropriadamente a OPTIONS.
- Token CSRF é gerado e validado corretamente.

***

### Etapa 7.3: Testes 100% de Autenticação
**Objetivo:** Cobertura completa de flows de auth.

**Instruções:**
- Em `test/auth_test.dart`, adicione testes para:
  - Login com credenciais válidas/inválidas.
  - Geração de JWT com payload esperado.
  - Validação de JWT.
  - Logout.
  - Hashing de senha.
  - CORS preflight e validação.
  - CSRF geração e validação.
- Execute `dart test` e confirme 100% de cobertura.
- Commit com "test: 100% coverage for Auth module".

**Verificações esperadas:**
- `dart test` com todos os testes passando.
- Cobertura >= 100%.

***

## FASE 8: Views SSR com Mustache (dartian_view)

### Etapa 8.1: Engine de templates com mustache
**Objetivo:** Implementar renderização server-side com mustache.

**Instruções:**
- Em `packages/dartian_view/`, execute `dart create -t package .`.
- Adicione ao `pubspec.yaml`: `mustache_template: ^2.0.0`.
- Crie estrutura:
  ```
  lib/
    src/
      view.dart           # Classe View para renderizar templates
      engine.dart         # Engine mustache wrapper
    dartian_view.dart
  test/
    view_test.dart        # Testes de renderização
  ```
- Implemente `View` que:
  - Aceita caminho de template (ex: 'users/list.mustache') e dados.
  - Renderiza com mustache com escape por padrão.
  - Suporta layouts (view master pode envolver view atual).
  - Suporta includes de sub-templates.
- Integre ao kernel HTTP: adicione helper `render(view, data)` que retorna Response HTML.
- Commit com "init: dartian_view with mustache".

**Verificações esperadas:**
- Imports de mustache_template funcionam.
- Template simples renderiza corretamente.

***

### Etapa 8.2: Gerador "dartian make:view"
**Objetivo:** CLI para gerar templates boilerplate.

**Instruções:**
- Em `packages/dartian_cli/`, estenda "make:view" para:
  - Aceitar nome de view (ex: `dartian make:view users/list`).
  - Criar arquivo `resources/views/users/list.view.dart.mustache` (ou `.mustache` conforme decisão).
  - Fornecer template boilerplate com variáveis comuns.
- Commit com "feat: dartian make:view command".

**Verificações esperadas:**
- `dartian make:view test/sample` cria arquivo em `resources/views/test/sample.view.dart.mustache`.

***

### Etapa 8.3: Testes 100% de Views
**Objetivo:** Cobertura completa de renderização.

**Instruções:**
- Em `test/view_test.dart`, adicione testes para:
  - Renderização básica com variáveis.
  - Escape de HTML.
  - Includes e layouts.
  - Erros quando template não existe.
- Execute `dart test` e confirme 100% de cobertura.
- Commit com "test: 100% coverage for View module".

**Verificações esperadas:**
- `dart test` com todos os testes passando.
- Cobertura >= 100%.

***

## FASE 9: Internacionalização (dartian_i18n)

### Etapa 9.1: i18n básico
**Objetivo:** Sistema de tradução com fallback de locale.

**Instruções:**
- Em `packages/dartian_i18n/`, execute `dart create -t package .`.
- Crie estrutura:
  ```
  lib/
    src/
      translator.dart     # Classe Translator
      loader.dart         # Carregador de arquivos de idioma
    dartian_i18n.dart
  test/
    i18n_test.dart        # Testes de tradução
  ```
- Implemente `Translator` que:
  - Carrega mensagens de `resources/lang/` (ex: `en/messages.dart`).
  - Expõe método `translate(key)` ou `__(key)` para obter mensagem.
  - Suporta fallback: se chave não encontrada em locale, tenta fallback (ex: 'pt_BR' -> 'pt' -> 'en').
  - Suporta substituições: `__('greeting', {'name': 'John'})` com chaves em template.
- Integrate ao DI: registre Translator como singleton com locale detectado.
- Commit com "init: dartian_i18n with basic translation".

**Verificações esperadas:**
- Translator consegue carregar e traduzir chaves simples.
- Fallback funciona entre locales.

***

### Etapa 9.2: Middleware e integração com views
**Objetivo:** Detectar locale em requisições e integrar com templates.

**Instruções:**
- Em `packages/dartian_http/`, adicione middleware:
  - `I18nMiddleware` que detecta locale de header Accept-Language ou session.
  - Define locale current no contexto de requisição.
- Integre `Translator` ao contexto de template mustache: templates conseguem usar `__(key)` diretamente.
- Commit com "feat: i18n middleware and view integration".

**Verificações esperadas:**
- Middleware detecta locale de Accept-Language.
- Templates conseguem renderizar traduções.

***

### Etapa 9.3: Gerador "dartian make:lang"
**Objetivo:** CLI para criar arquivos de idioma.

**Instruções:**
- Em `packages/dartian_cli/`, estenda "make:lang" para:
  - Aceitar código de locale (ex: `dartian make:lang pt_BR`).
  - Criar arquivo `resources/lang/pt_BR/messages.dart` com estrutura boilerplate.
- Commit com "feat: dartian make:lang command".

**Verificações esperadas:**
- `dartian make:lang es` cria arquivo em `resources/lang/es/messages.dart`.

***

### Etapa 9.4: Testes 100% de i18n
**Objetivo:** Cobertura completa de tradução.

**Instruções:**
- Em `test/i18n_test.dart`, adicione testes para:
  - Carregar e traduzir chaves.
  - Fallback entre locales.
  - Substituições de parâmetros.
  - Middleware detecta locale.
  - Integração com templates.
- Execute `dart test` e confirme 100% de cobertura.
- Commit com "test: 100% coverage for i18n module".

**Verificações esperadas:**
- `dart test` com todos os testes passando.
- Cobertura >= 100%.

***

## FASE 10: Telemetria via Hooks (dartian_core)

### Etapa 10.1: Hooks de telemetria
**Objetivo:** Expor hooks para instrumentação sem acoplamento direto.

**Instruções:**
- Em `packages/dartian_core/`, crie:
  - Classe `TelemetryHooks` com métodos estáticos para hook em pontos-chave:
    - `onRequest(request)` quando requisição inicia.
    - `onResponse(response, duration)` quando requisição conclui.
    - `onQueryExecuted(sql, duration)` para queries ORM.
    - `onJobQueued(job)`, `onJobProcessed(job, duration)`.
  - Cada hook é lista de callbacks; aplicação pode registrar observers.
- Documentar como integrar com OpenTelemetry SDK (quando usuário instalar) registrando callbacks que exportam spans/métricas.
- Commit com "init: dartian_core with telemetry hooks".

**Verificações esperadas:**
- Hooks conseguem ser chamados sem error.
- Callbacks registrados são executados quando hooks são acionados.

***

### Etapa 10.2: Instrumentação do core
**Objetivo:** Chamar hooks em componentes principais (HTTP, ORM, Queue).

**Instruções:**
- Em `dartian_http/`, adicione chamadas a hooks em kernel:
  - `TelemetryHooks.onRequest()` no início de requisição.
  - `TelemetryHooks.onResponse()` no fim.
- Em `dartian_orm/`, adicione:
  - `TelemetryHooks.onQueryExecuted()` após executar query.
- Em `dartian_queue/`, adicione:
  - `TelemetryHooks.onJobQueued()` ao enfileirar.
  - `TelemetryHooks.onJobProcessed()` ao concluir.
- Commit com "feat: instrument core with hooks".

**Verificações esperadas:**
- Hooks são chamados nos pontos esperados (pode-se testar registrando mock callback).

***

### Etapa 10.3: Testes 100% de Telemetria
**Objetivo:** Cobertura completa de hooks.

**Instruções:**
- Adicione testes que:
  - Registram mock callbacks em hooks.
  - Verificam que callbacks são executados quando apropriado.
  - Validam payload dos callbacks.
  - Verificam que ausência de callbacks não causa erro.
- Execute `dart test` e confirme 100% de cobertura.
- Commit com "test: 100% coverage for Telemetry module".

**Verificações esperadas:**
- `dart test` com todos os testes passando.
- Cobertura >= 100%.

---

## FASE 11: Deployment – AOT, Docker e WASI

### Etapa 11.1: Compilação AOT para produção
**Objetivo:** Configurar build para gerar executável nativo otimizado.

**Instruções:**
- Em `packages/dartian_cli/`, estenda comando "build" para:
  - `dartian build exe` que executa `dart compile exe -O2 bin/main.dart -o dartian-aot`.
  - `dartian build aot-snapshot` que gera AOT snapshot.
  - Ambos salvam artefatos em `build/` com timestamp ou versão.
- Adicione script de build em `scripts/build.sh` que:
  - Limpa diretório `build/`.
  - Executa `dart pub get` em todos os pacotes.
  - Compila monorepo como projeto final (estrutura main em raiz ou em exemplo).
  - Gera relatório de tamanho do binário.
- Commit com "feat: AOT build command and scripts".

**Verificações esperadas:**
- `dartian build exe` gera executável em `build/dartian-aot`.
- Executável consegue rodar (teste com `build/dartian-aot version`).

***

### Etapa 11.2: Docker unificado
**Objetivo:** Imagem Docker multi-stage para dev e prod.

**Instruções:**
- Crie `Dockerfile` na raiz com estágios:
  - **Stage 1 (build):** Dart VM, instala dependências, compila AOT.
  - **Stage 2 (runtime):** Imagem base mínima (alpine ou distroless), copia binário do stage 1.
  - Parametriza via ENV variáveis: `DB_DRIVER`, `LOG_LEVEL`, `PORT`, etc.
  - Healthcheck que testa GET `/health` na porta configurada.
  - Entryscript que carrega .env se existir e inicia binário.
- Crie `docker-compose.yml` com serviços para Dartian + PostgreSQL + Redis para dev local.
- Documentar build: `docker build -t dartian:latest .`.
- Commit com "feat: Docker Dockerfile and docker-compose".

**Verificações esperadas:**
- `docker build -t dartian:test .` sucede.
- Container consegue iniciar e responder a healthcheck (teste com `docker run --rm dartian:test version`).

***

### Etapa 11.3: WASI suportado e testado
**Objetivo:** Compilação para WebAssembly com WASI e testes básicos.

**Instruções:**
- Crie script `scripts/build-wasi.sh` que:
  - Executa `dart compile wasm --target-os=wasi bin/main.dart -o dartian.wasm` (ou comando equivalente conforme versão de Dart).
  - Valida que `.wasm` foi gerado.
  - Se possível, testa com wasmtime: `wasmtime dartian.wasm --version` (install wasmtime se necessário).
- Adicione testes WASI em `test/wasm_test.dart`:
  - Compila teste simples para WASM.
  - Executa com wasmtime.
  - Valida output.
  - Marque com `@Tag('wasm')` para skip em CI sem wasmtime.
- Documenta estado: "WASI support is experimental and tested with wasmtime".[2]
- Commit com "feat: WASI build and testing".

**Verificações esperadas:**
- Script `scripts/build-wasi.sh` executa sem erro.
- `.wasm` é gerado em `build/`.
- Se wasmtime disponível, consegue executar.

***

## FASE 12: Gerador de Código – Geradores "make:*"

### Etapa 12.1: Geradores de controller, model, migration
**Objetivo:** Comandos CLI que geram boilerplate.

**Instruções:**
- Em `packages/dartian_cli/`, estenda subcomandos:
  - `dartian make:controller UserController` cria `app/Http/Controllers/UserController.dart` com métodos de CRUD stubs.
  - `dartian make:model User` cria `app/Models/User.dart` com classe de Model Drift.
  - `dartian make:migration create_users_table` cria `database/migrations/YYYY_MM_DD_HHMM_SS_create_users_table.dart`.
  - `dartian make:request UserRequest` cria `app/Http/Requests/UserRequest.dart` com validação stub.
  - `dartian make:provider UserServiceProvider` cria `app/Providers/UserServiceProvider.dart`.
- Templates devem ser texto com placeholders (ex: `{CLASS_NAME}`, `{TABLE_NAME}`) que são substituídos.
- Commit com "feat: make:* generators for boilerplate".

**Verificações esperadas:**
- `dartian make:controller TestController` cria arquivo em diretório correto.
- Arquivo gerado compila sem erro.

***

### Etapa 12.2: Gerador de testes
**Objetivo:** Comando para gerar testes.

**Instruções:**
- Estenda `dartian make:test UserControllerTest` que cria `test/Feature/UserControllerTest.dart`.
- Template inclui imports, exemplo de teste, stubs de setup/teardown.
- Commit com "feat: make:test generator".

**Verificações esperadas:**
- `dartian make:test SampleTest` cria arquivo testável.

***

## FASE 13: Hot Reload Completo no "dartian serve"

### Etapa 13.1: Watch e reload de arquivos
**Objetivo:** Monitorar mudanças e recarregar server sem perder estado.

**Instruções:**
- Em `packages/dartian_cli/`, refine "serve" para:
  - Usar `package:watcher` para monitorar mudanças em `lib/`, `app/`, `routes/`, `resources/`.
  - Ao detectar mudança, recarregar apenas arquivo modificado se possível (hot reload).
  - Fallback para hot restart se reload não possível.
  - Exibir mensagens claras: "Files changed: app/Http/Controllers/UserController.dart" e "Reloading...".
- Preserve estado de banco em memória (SQLite in-memory com transações) ou session em cache para continuidade.
- Commit com "feat: complete hot reload in dartian serve".

**Verificações esperadas:**
- `dartian serve` detecta mudanças de arquivo e recarrega.
- Server continua respondendo após reload.

***

## FASE 14: Qualidade de Código e Análise

### Etapa 14.1: Análise estática e linting
**Objetivo:** Garantir qualidade com análise automática.

**Instruções:**
- Em cada pacote, configure `analysis_options.yaml` com regras rígidas.
- Execute `dart analyze` em todos os pacotes:
  - Sem erros ou warnings sérios.
  - Foco em code smells, dead code, tipos incompletos.
- Adicione script `scripts/lint.sh` que executa análise em paralelo.
- Commit com "feat: analysis_options and lint scripts".

**Verificações esperadas:**
- `dart analyze` em todos os pacotes sem erros/warnings.

***

### Etapa 14.2: Cobertura de testes consolidada
**Objetivo:** Verificar cobertura total do MVP.

**Instruções:**
- Crie script `scripts/test-coverage.sh` que:
  - Executa `dart test` em todos os pacotes com `--coverage=coverage/`.
  - Consolida relatórios de cobertura.
  - Gera relatório HTML com `package:coverage`.
  - Exibe cobertura total esperada (meta: >= 95% para MVP).
- Commit com "feat: consolidated test coverage reporting".

**Verificações esperadas:**
- Script executa sem erro.
- Relatório de cobertura consolidado é gerado.

***

## FASE 15: Documentação e README

### Etapa 15.1: README principal
**Objetivo:** Documentação compreensiva para usuários e contribuidores.

**Instruções:**
- Crie `README.md` na raiz com seções:
  - **Visão geral:** Dartian é um framework backend para Dart inspirado no Laravel.
  - **Requisitos:** Dart SDK 3.x+, Git, Docker (opcional).
  - **Instalação:** `dart pub global activate -s path ./packages/dartian_cli`.
  - **Quick Start:** Exemplo simples de projeto: `dartian new myapp`, `dartian serve`, acessar localhost:8000.
  - **Recursos Principais:** HTTP, Roteamento, ORM (Drift), DI (get_it), Filas (Redis), Scheduler (cron), Views (mustache), i18n, Telemetria (hooks).
  - **Arquitetura:** Descrição de módulos e padrões.
  - **Deployment:** Docker, AOT, WASI.
  - **Contribuindo:** Link para CONTRIBUTING.md.
  - **Licença:** AGPLv3 com opção comercial.
  - **Links:** GitHub, documentação, exemplos.
- Badges de CI, cobertura, versão.
- Commit com "docs: comprehensive README".

**Verificações esperadas:**
- README.md existe e é legível em Markdown.
- Links funcionam (validar com verificador de links).

***

### Etapa 15.2: CONTRIBUTING.md
**Objetivo:** Guia para contribuidores.

**Instruções:**
- Crie `CONTRIBUTING.md` com:
  - Processo de fork e PR.
  - Padrões de código e estilo (alinhar com análise_options.yaml).
  - Testes obrigatórios (100% cobertura por módulo).
  - Commits semânticos (feat:, fix:, docs:, test:, etc.).
  - Setup local (instalar Dart, clonar, `dart pub get` em packages/, `dartian --version`).
- Commit com "docs: contributing guidelines".

**Verificações esperadas:**
- CONTRIBUTING.md existe e descreve processo claro.

***

### Etapa 15.3: Exemplos de projeto
**Objetivo:** Aplicação exemplo que demonstra funcionalidades.

**Instruções:**
- Crie diretório `examples/hello_world/` com projeto Dartian funcional:
  - `pubspec.yaml` que depende dos pacotes do monorepo via path.
  - `routes/web.dart` com rotas simples.
  - `app/Http/Controllers/WelcomeController.dart` com método index que retorna JSON ou HTML.
  - `resources/views/welcome.mustache` com template.
  - `.env.example` com configurações.
  - README com instruções de execução: `dartian serve` e visitar `http://localhost:8000`.
- Commit com "docs: example hello_world project".

**Verificações esperadas:**
- Exemplo compila e executa com `dartian serve`.
- Requisições funcionam e retornam respostas esperadas.

***

## FASE 16: Criação de Projeto "Example" Integrado

### Etapa 16.1: Projeto de teste completo
**Objetivo:** Criar projeto que integra todos os módulos do MVP.

**Instruções:**
- Na raiz, crie diretório `testing-project/` com projeto Dartian completo:
  - `pubspec.yaml` que depende de todos os pacotes `dartian_*` via path.
  - `bin/main.dart` que inicializa app, configura DI, rodeia HTTP kernel, carrega rotas.
  - `app/` com controllers, models, providers.
  - `routes/web.dart` com rotas CRUD de exemplo.
  - `database/` com migrations e seeder.
  - `resources/` com views e i18n.
  - `.env` configurado para SQLite local, cache in-memory, queue sync, locale 'en'.
- Teste completo end-to-end:
  - `dartian serve` inicia sem erro.
  - GET /api/users retorna JSON.
  - GET /users retorna HTML renderizado.
  - POST /users enfileira job, processa com `dartian queue:work`.
  - POST /admin/seed popula banco com dados de teste.
- Commit com "test: full integration project".

**Verificações esperadas:**
- Projeto compila sem erro.
- Todos os endpoints funcionam conforme descrito.

***

## FASE 17: CI/CD Básico

### Etapa 17.1: GitHub Actions workflow
**Objetivo:** Testar e validar ao cada push.

**Instruções:**
- Crie `.github/workflows/ci.yml` que:
  - Dispara em push e PR.
  - Matrix de Dart versions (3.x LTS e latest).
  - Steps:
    - Setup Dart.
    - `dart pub get` em todos os packages.
    - `dart analyze` (lint).
    - `dart test --coverage=coverage/` em cada package.
    - Upload cobertura para Codecov (opcional).
    - `dart run build_runner build` para testar code-gen.
  - Tempo total esperado: 5-10 minutos.
- Commit com "ci: GitHub Actions workflow".

**Verificações esperadas:**
- Workflow executa sem erro em push.
- Relatório de testes é exibido.

***

## FASE 18: Verificações Finais e PR

### Etapa 18.1: Smoke tests finais
**Objetivo:** Validação manual de happy paths antes de PR.

**Instruções:**
- Teste cada comando CLI:
  - `dartian version` → "Dartian 0.0.1"
  - `dartian help` → Lista subcomandos
  - `dartian new myapp` → Cria projeto novo
  - `dartian make:controller`, `make:model`, etc. → Geram arquivos
- Teste servidor:
  - `dartian serve` na pasta `testing-project/` → Server inicia
  - GET http://localhost:8000/api/users → JSON response
  - GET http://localhost:8000/users → HTML response
- Teste deployment:
  - `dartian build exe` → Binário gerado
  - `./build/dartian-aot version` → Funciona
  - `docker build -t dartian:test .` → Imagem criada
  - `docker run --rm dartian:test version` → Funciona
- Teste cobertura:
  - `dart test --coverage=coverage/` em todos os packages
  - Cobertura >= 95% para core modules
- Commit com "test: smoke tests validation".

**Verificações esperadas:**
- Todos os smoke tests passam.
- Não há erros ou warnings de análise.

***

### Etapa 18.2: Limpeza e validação final
**Objetivo:** Preparar repositório para PR.

**Instruções:**
- Execute `dart format --set-exit-if-changed lib/ bin/ test/` em cada package para garantir código formatado.
- Verifique `.gitignore` inclui: `build/`, `coverage/`, `.dart_tool/`, `pubspec.lock` (onde apropriado), `.env` (não incluir em committe).
- Remova arquivos temporários ou de debug.
- Execute uma última batida de `dart test` em todos os packages.
- Verifique que histórico de commits é limpo e mensagens são descritivas.
- Commit com "chore: final cleanup and validation".

**Verificações esperadas:**
- `git status` mostra árvore limpa.
- `git log --oneline` mostra histórico claro com commits semânticos.

***

### Etapa 18.3: Abertura de PR
**Objetivo:** Submeter MVP para review.

**Instruções:**
- Execute `git push -u origin feat/dartian-mvp` para enviar branch.
- No GitHub, navegue para o repositório dartian e clique "New Pull Request".
- Selecione `main` como base e `feat/dartian-mvp` como compare.
- Preencha título: "feat: Dartian MVP – Core modules and infrastructure".
- Preencha descrição com:
  - Sumário de módulos completados (CLI, HTTP, Router, DI, ORM, Redis, Queue, Scheduler, Auth, Views, i18n, Telemetria, Deployment).
  - Checklist: todos os módulos com 100% de cobertura, CI verde, documentação completa, exemplos funcionando.
  - Links para: README.md, CONTRIBUTING.md, exemplo.
  - Notas de conhecimento: "WASI é experimental conforme status do SDK", "AGPLv3 com licença comercial disponível".
- Requer revisão (manualmente feita se necessário em ambiente real).
- Inclua em descrição:
  ```
  Checklist:
  - [x] dartian_cli: Core CLI com subcomandos base
  - [x] dartian_http: HTTP kernel com shelf
  - [x] dartian_router: Router fluente com shelf_router
  - [x] dartian_di: DI com get_it e auto-discovery
  - [x] dartian_orm: ORM com Drift (SQLite + PostgreSQL)
  - [x] dartian_redis: Cache e pub/sub
  - [x] dartian_queue: Filas com drivers (sync, isolate, Redis)
  - [x] dartian_scheduler: Agendamento com cron
  - [x] dartian_auth: Autenticação (sessão + JWT), CORS, CSRF
  - [x] dartian_view: SSR com mustache
  - [x] dartian_i18n: Tradução e localização
  - [x] Telemetria: Hooks opt-in
  - [x] Docker: Multi-stage unificado
  - [x] WASI: Suportado e testado
  - [x] AOT: Build para produção
  - [x] Hot reload: Completo em dartian serve
  - [x] Cobertura: 100% por módulo
  - [x] Documentação: README, CONTRIBUTING, exemplos
  - [x] CI/CD: GitHub Actions workflow
  - [x] Smoke tests: Todos os happy paths validados
  ```
- Commit final com "pr: ready for review – Dartian MVP".

**Verificações esperadas:**
- PR criada em GitHub.
- CI workflow dispara e passa (green check).
- Descrição é clara e completa.

***

## Instruções de Monitoramento e Recuperação de Erros para o Jules

Durante toda execução, o Jules deve:

1. **Ao ficar preso em erro:**
   - Capture stack trace completo.
   - Pesquise o erro no GitHub do projeto relevante (ex: `https://github.com/dart-lang/sdk/issues` para erros do Dart, `https://github.com/dart-lang/shelf/issues` para shelf).
   - Pesquise no site oficial de documentação (ex: `https://dart.dev/server`, `https://drift.simonbinder.eu/`).
   - Aplique sugestão de workaround ou downgrade de versão se necessário.
   - Se persistir, faça commit do estado atual com mensagem descritiva e exiba erro para aprovação manual.

2. **Após cada módulo:**
   - Execute `dart test` e confirme 100% de cobertura.
   - Execute `dart analyze` sem erros/warnings.
   - Commit com mensagem semântica.
   - Integre com módulos anteriores e valide que não quebrou nada.

3. **Ao falhar integração entre módulos:**
   - Revise imports e dependências.
   - Certifique que `pubspec.yaml` reflete caminhos corretos de path dependencies.
   - Se ciclo de dependência, reestruture (ex: mova classes para dartian_core).
   - Pesquise padrão no GitHub de projetos similares (ex: Serverpod).

4. **Ao finalizar cada fase:**
   - Exiba relatório: módulos completados, testes passando, cobertura atingida, commits realizados.

5. **Caso atinja token/resource limit:**
   - Faça commit do progresso atual.
   - Exiba status e recomendações para continuação manual.

***

## Resumo de Entregáveis Esperados

Ao término, o repositório `dartian` na branch `feat/dartian-mvp` deve conter:

- **Monorepo de 11 pacotes Dart:** Cada um com 100% de cobertura de testes, análise verde, documentação inline.
- **CLI funcional:** `dartian` como comando global com 15+ subcomandos.
- **HTTP kernel:** Baseado em shelf, pronto para produção.
- **ORM robusto:** Drift com SQLite e PostgreSQL.
- **Autenticação:** Sessão e JWT.
- **Filas e scheduler:** Funcionais com múltiplos drivers.
- **Views SSR:** Mustache com i18n integrado.
- **Docker e AOT:** Imagem oficial, binário compilado.
- **WASI:** Suportado com testes.
- **Documentação:** README, CONTRIBUTING, exemplos, comentários em código.
- **CI/CD:** GitHub Actions workflow verde.
- **PR aberta:** Pronta para merge após review.

**Arquivo final esperado na raiz do projeto:**
```
dartian/
├── .github/
│   └── workflows/
│       └── ci.yml
├── .gitignore
├── packages/
│   ├── dartian_cli/
│   ├── dartian_core/
│   ├── dartian_http/
│   ├── dartian_router/
│   ├── dartian_di/
│   ├── dartian_orm/
│   ├── dartian_redis/
│   ├── dartian_queue/
│   ├── dartian_scheduler/
│   ├── dartian_view/
│   └── dartian_i18n/
├── examples/
│   └── hello_world/
├── testing-project/
├── scripts/
│   ├── build.sh
│   ├── build-wasi.sh
│   ├── lint.sh
│   └── test-coverage.sh
├── docs/
├── Dockerfile
├── docker-compose.yml
├── pubspec.yaml (meta-package, se aplicável)
├── README.md
├── CONTRIBUTING.md
└── (branch: feat/dartian-mvp)
```

Este plano é auto-suficiente e guia o Jules a completar o Dartian MVP de forma autônoma, com validação em cada etapa, pesquisa ativa de soluções e entrega de um sistema pronto para produção.

[1](https://dart.dev/get-dart)
[2](https://dart.dev/web/wasm)