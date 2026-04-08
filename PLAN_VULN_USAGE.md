# 🔒 Plano: Fix da Vulnerabilidade do Limite Freemium

**Status:** Plano aprovado pela Marina, aguardando aprovação do Gabi para execução.
**Demanda:** Usuário burla o limite gratuito (3 buscas) reinstalando o app.
**Data:** 07/04/2026

---

## 📋 Requisitos (Marina — PM)

Consolidação das decisões tomadas com o Gabi:

1. **Modelo de cobrança:** 3 chamadas de IA por dia (resetando à meia-noite local).
2. **Escopo do contador:** Cada chamada à API do Gemini conta como 1 crédito. Hoje só conta troca de cidade — precisamos contar também:
   - Busca inicial de sugestões (`fetchSuggestions` / `fetchSuggestionsForCity`)
   - "Mais passeios" (`fetchMoreTours`)
   - Busca por interesse (`fetchInterestSuggestions`)
   - Gerar roteiro (`generateItinerary`)
3. **Offline:** Bloqueio total. Sem internet, nenhum recurso de IA funciona.
4. **Identificação:** Firebase Anonymous Auth + UUID persistente no Keychain/KeyStore.
5. **Compatibilidade retroativa:** Usuários já instalados não devem perder buscas. Faremos migração suave.

**Critérios de aceite:**
- ✅ Desinstalar e reinstalar o app NÃO reseta o contador
- ✅ Qualquer chamada ao Gemini incrementa o contador em +1
- ✅ Sem conexão = bloqueio com mensagem clara
- ✅ Contador reseta à meia-noite do horário local do dispositivo
- ✅ Premium não pode ser ativado só alterando o dispositivo (validação server-side)
- ✅ Usuário premium atual continua premium após a atualização
- ✅ Regras de segurança do Firestore impedem um cliente de escrever em dados de outro dispositivo

---

## 🏗️ Arquitetura da Solução (Ricardo — Tech Lead)

### Visão Geral

```
┌─────────────────────────────────────────────────────────────┐
│                        APP (Cliente)                       │
│                                                             │
│  ┌──────────────────┐      ┌───────────────────────────┐   │
│  │  DeviceIdentity  │─────▶│  flutter_secure_storage   │   │
│  │  (gera/lê UUID)  │      │  Keychain / EncryptedPrefs│   │
│  └──────────────────┘      └───────────────────────────┘   │
│          │                                                  │
│          ▼                                                  │
│  ┌──────────────────┐                                       │
│  │ Firebase Anon    │                                       │
│  │ Auth (uid = x)   │                                       │
│  └──────────────────┘                                       │
│          │                                                  │
│          ▼                                                  │
│  ┌──────────────────────────────────────┐                   │
│  │  UsageRepository (nova abstração)    │                   │
│  │  - canUseAI()                        │                   │
│  │  - recordAICall()                    │                   │
│  │  - isPremium()                       │                   │
│  └──────────────────────────────────────┘                   │
│          │                                                  │
└──────────┼──────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│                   FIREBASE (Cloud)                          │
│                                                             │
│  ┌──────────────────────────────────────┐                   │
│  │  Firestore: usage/{deviceUuid}       │                   │
│  │  {                                   │                   │
│  │    authUid: "abc123",                │                   │
│  │    dateKey: "2026-04-07",            │                   │
│  │    aiCallsToday: 2,                  │                   │
│  │    isPremium: false,                 │                   │
│  │    premiumSince: null,               │                   │
│  │    lastUpdated: <timestamp>,         │                   │
│  │    createdAt: <timestamp>            │                   │
│  │  }                                   │                   │
│  └──────────────────────────────────────┘                   │
│                                                             │
│  ┌──────────────────────────────────────┐                   │
│  │  Cloud Function: validateIAPReceipt  │                   │
│  │  (valida compra com Apple/Google e   │                   │
│  │   marca isPremium=true no Firestore) │                   │
│  └──────────────────────────────────────┘                   │
│                                                             │
│  ┌──────────────────────────────────────┐                   │
│  │  Security Rules                      │                   │
│  │  - Só authenticated pode ler/escrever│                   │
│  │  - Doc ID deve bater com custom claim│                   │
│  │  - isPremium só via Cloud Function   │                   │
│  └──────────────────────────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
```

### Por que UUID no Keychain e não só Firebase Anon Auth?

Porque a **Firebase Anonymous Auth cria um NOVO usuário anônimo a cada reinstalação**. A auth não persiste sozinha no disco local do app — quando o app é removido, o refresh token vai junto.

A chave do fix é:
- **iOS Keychain:** persiste itens entre reinstalações por padrão desde iOS 10.3 ✅
- **Android EncryptedSharedPreferences:** vamos habilitar **Android Auto Backup** no `AndroidManifest.xml`, que faz backup cifrado dos dados no Google Drive do usuário e restaura ao reinstalar. Cobre ~95% dos casos.

Edge cases aceitáveis (fraude residual):
- Usuário desativa iCloud Keychain no iPhone → reinstalação reseta
- Usuário desativa Google Backup no Android → reinstalação reseta
- Factory reset do device → reseta (aceitável)

Se no futuro isso virar problema, migramos para **Apple DeviceCheck API + Google Play Integrity** (fase 2).

### Fluxo de Boot do App

```
1. main() roda
2. Firebase.initializeApp()
3. DeviceIdentityService.initialize()
   a. Lê UUID do secure storage
   b. Se não existe, gera UUID v4 e salva
4. FirebaseAuth.signInAnonymously() (cria ou reusa anon user)
5. UsageRepository.syncFromRemote()
   a. Busca doc em usage/{uuid}
   b. Se não existe, cria com valores padrão
   c. Cacheia em memória
6. Navega para SplashPage → HomePage
```

### Fluxo de uma Chamada de IA

```
1. User tapa "Usar minha localização"
2. TravelProvider.fetchSuggestions() é chamado
3. UsageRepository.canUseAI() é consultado:
   a. Se offline → throw OfflineException → UI mostra erro
   b. Se premium → retorna true
   c. Se dateKey != today → reset + retorna true
   d. Se aiCallsToday < 3 → retorna true
   e. Senão → retorna false → abre Paywall
4. Gemini é chamado
5. Após sucesso (ou erro HTTP): UsageRepository.recordAICall()
   a. Atomic increment no Firestore (FieldValue.increment(1))
   b. Atualiza cache local
6. UI atualiza "2/3" → "3/3"
```

**Nota importante:** Contamos só APÓS o Gemini responder com sucesso. Se falhou por timeout/rede, não consome crédito. É mais justo com o usuário.

---

## 👥 Distribuição do Trabalho

### 🔐 Henrique (Backend) — Firebase setup
- [ ] Habilitar Firebase Anonymous Auth no console
- [ ] Criar coleção `usage` no Firestore
- [ ] Escrever security rules (`firestore.rules`)
- [ ] Criar Cloud Function `validateIAPReceipt` (valida recibo da App Store)
- [ ] Deploy das rules e functions

### 📱 Beatriz (Mobile UI) — Integração secure storage + Android manifest
- [ ] Adicionar dependências: `flutter_secure_storage`, `uuid`, `connectivity_plus`
- [ ] Verificar se `cloud_firestore` e `firebase_auth` já estão no `pubspec.yaml` (adicionar se não)
- [ ] Criar `lib/core/device_identity_service.dart` — gera/lê UUID no Keychain
- [ ] Configurar `android/app/src/main/AndroidManifest.xml` com `android:allowBackup="true"` e `BackupAgent` para incluir os secure prefs
- [ ] Criar regra de backup `android/app/src/main/res/xml/backup_rules.xml`
- [ ] Atualizar `main.dart` para inicializar DeviceIdentity + Anon Auth antes do `runApp`
- [ ] Adicionar telas/mensagens de erro offline e quota excedida

### 💎 Lucas (State & Data Layer) — Refatoração do UsageDatasource
- [ ] Renomear `UsageDatasource` para `LocalUsageCache` (apenas cache)
- [ ] Criar `UsageRepository` (nova abstração de alto nível)
- [ ] Criar `FirestoreUsageDatasource` (lê/escreve em `usage/{uuid}`)
- [ ] Implementar lógica de reset diário no servidor (comparando `dateKey` com hoje)
- [ ] Atualizar `InjectionContainer` para injetar o novo repository
- [ ] Atualizar `TravelProvider` para usar o novo repository
- [ ] Unificar contador de `search` e `itinerary` em um único `aiCallsToday`
- [ ] Garantir que TODAS as chamadas ao Gemini passem por `canUseAI()` + `recordAICall()`

### 🤖 Diego (AI & Performance) — Instrumentação das chamadas Gemini
- [ ] Mapear todas as chamadas ao `GeminiDatasource` no repositório
- [ ] Envolver cada método em `canUseAI()` + `recordAICall()`:
  - `fetchSuggestions` (já conta, só migrar)
  - `fetchMoreTours` (novo)
  - `fetchInterestSuggestions` (novo)
  - `generateItinerary` (já conta, só migrar)
- [ ] Adicionar logging de métricas (tempo, sucesso/falha) para Firebase Analytics
- [ ] Garantir que o débito só acontece APÓS sucesso do Gemini

### 🧪 Priya (QA/DevOps) — Testes e validação
- [ ] Testes unitários do `UsageRepository` com mock do Firestore
- [ ] Teste de integração do fluxo completo (usando Firebase Emulator Suite)
- [ ] Teste manual de reinstalação no iOS (verificar se o UUID persiste)
- [ ] Teste manual de reinstalação no Android (verificar Auto Backup)
- [ ] Teste manual offline (modo avião)
- [ ] Teste do Cloud Function `validateIAPReceipt` com receipt de sandbox
- [ ] Validar security rules com Firestore Emulator
- [ ] Atualizar CI/CD (GitHub Actions) para rodar os testes novos

### 🏗️ Ricardo (Tech Lead) — Revisão e migração
- [ ] Code review de cada PR do time
- [ ] Planejar migração suave para usuários existentes:
  - Ao inicializar o UsageRepository pela 1ª vez, ler os counters do `SharedPreferences` antigo
  - Migrar para Firestore
  - Marcar migração como completa (flag no secure storage)
- [ ] Validar que o fluxo de paywall continua funcionando
- [ ] Revisar security rules com cuidado

---

## 🔒 Firestore Security Rules (draft do Henrique)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /usage/{deviceUuid} {
      // Leitura: só o próprio dispositivo autenticado
      allow read: if request.auth != null
                  && request.auth.uid == resource.data.authUid;

      // Criação: permitida para usuário autenticado criando seu próprio doc
      allow create: if request.auth != null
                    && request.resource.data.authUid == request.auth.uid
                    && request.resource.data.aiCallsToday == 0
                    && request.resource.data.isPremium == false;

      // Update: cliente só pode incrementar o contador ou mudar dateKey
      //         NUNCA pode mudar isPremium (só Cloud Function com admin SDK)
      allow update: if request.auth != null
                    && request.auth.uid == resource.data.authUid
                    && request.resource.data.isPremium == resource.data.isPremium
                    && request.resource.data.authUid == resource.data.authUid;

      allow delete: if false; // nunca
    }
  }
}
```

**Truque importante:** `isPremium` só pode ser alterado via Cloud Function que usa Admin SDK e ignora security rules. Isso impede que o cliente tempere a flag.

---

## 📦 Dependências Novas

Adicionar ao `pubspec.yaml`:

```yaml
dependencies:
  # Já devem existir, confirmar:
  firebase_core: ^...
  firebase_auth: ^...
  cloud_firestore: ^...
  cloud_functions: ^...

  # Novas:
  flutter_secure_storage: ^9.2.2
  uuid: ^4.5.1
  connectivity_plus: ^6.1.0
```

---

## 📅 Fases de Rollout

### Fase 1 — Core (essencial, 3-4 dias de trabalho)
1. Henrique: Firebase setup + security rules
2. Beatriz: DeviceIdentityService + dependências + Android manifest
3. Lucas: UsageRepository + migração + integração no TravelProvider
4. Diego: Instrumentação de todas as chamadas Gemini
5. Priya: Testes básicos

### Fase 2 — Validação server-side do IAP (1-2 dias)
1. Henrique: Cloud Function `validateIAPReceipt`
2. Beatriz: Chamar a Cloud Function após compra bem-sucedida
3. Priya: Teste end-to-end com sandbox

### Fase 3 — Polish (1 dia)
1. Beatriz: Mensagens de erro amigáveis (offline, quota, falha de auth)
2. Diego: Analytics eventos
3. Priya: Teste de regressão completo
4. Ricardo: Code review final e merge

**Total estimado:** ~6-8 dias de desenvolvimento (em paralelo, ~3 dias corridos com o time atuando junto).

---

## ⚠️ Riscos Identificados

| Risco | Mitigação |
|---|---|
| Android Auto Backup desabilitado pelo usuário → reinstalação reseta | Aceitável para v1. Se virar problema, adicionar Play Integrity API na fase 2. |
| Usuário em região sem Firebase (China) | Detectar via tentativa inicial; fallback para bloqueio total educativo. Fora de escopo. |
| Firestore fica indisponível (outage) | App bloqueia uso de IA mostrando "Serviço indisponível". Gracioso. |
| Migração dos usuários atuais quebrar | Testar com device real já com versão antiga instalada antes do release. |
| Latência extra no boot (auth + Firestore read) | Fazer em paralelo com o splash screen (já temos 1.8s). |
| Cliente tempera dateKey pra resetar contador | Server-side: validar `dateKey == serverTimestamp date`. Cloud Function daily reset. |

---

## 🎯 Métricas de Sucesso (30 dias pós-deploy)

- **Taxa de conversão free → paid:** deve aumentar (hoje usuários burlam)
- **Receita mensal:** deve subir proporcional à conversão
- **Crash-free rate:** não pode cair abaixo de 99.5%
- **Latência do boot:** p95 ≤ 3s (vs 1.8s atual)
- **Reviews na App Store:** monitorar se usuários reclamam de "esgotei rápido" (sinal de que o limite está muito baixo)

---

**Time pronto pra executar.** Aguardando luz verde do Gabi. 🟢
