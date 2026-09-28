# TechSOS MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Développer l'application mobile TechSOS (Flutter Riverpod) et son API REST modulaire (NestJS + Prisma SQLite/PostgreSQL) pour la mise en relation dépannage électronique à Bamako (Mali).

**Architecture:** Monorepo structuré avec `backend/` (NestJS modulaire avec Prisma ORM, stockage multimédia local pour audio/photos, simulation WhatsApp Business et Mobile Money) et `mobile/` (Flutter en architecture Feature-First avec Riverpod, gestion de la connectivité dégradée, enregistrement audio résilient et design system conforme à la charte Golden Innovation Tech).

**Tech Stack:** 
- Mobile : Flutter 3.x, Dart, Riverpod (`flutter_riverpod`), Dio, Record (`record`), AudioPlayers, Shared Preferences
- Backend : Node.js (v24), NestJS 10.x, TypeScript, Prisma ORM, JWT, Bcrypt, Multer
- Base de données : SQLite en développement local (zéro dépendance externe), schéma prêt pour migration PostgreSQL 16
- Spécification : [docs/superpowers/specs/2026-09-28-techsos-mvp-design.md](file:///c:/Users/touma/Projet/tech_sos/docs/superpowers/specs/2026-09-28-techsos-mvp-design.md)

## Global Constraints

- Langue de l'interface : 100% en Français
- Couleurs de la charte :
  - Primaire : `#1F3A5F` (Bleu nuit)
  - Accent / Urgence : `#E8641C` (Orange technique)
  - Succès : `#2E8B57` (Vert)
  - Alerte : `#D9A441` (Ambre)
  - Fond : `#F7F8FA` (Blanc cassé)
  - Texte principal : `#1A1A1A`
  - Texte secondaire : `#595959`
- Monnaie : Franc CFA (XOF / FCFA)
- Localisation par défaut : Bamako, Mali
- Double mode : Navigation et écrans dédiés selon le profil (Client vs Prestataire)
- Enregistrement vocal résilient : sauvegarde locale avant tentative d'envoi réseau

---

## File Structure

```
tech_sos/
├── backend/
│   ├── package.json
│   ├── tsconfig.json
│   ├── prisma/
│   │   ├── schema.prisma
│   │   └── seed.ts
│   ├── src/
│   │   ├── main.ts
│   │   ├── app.module.ts
│   │   ├── common/
│   │   │   ├── filters/http-exception.filter.ts
│   │   │   ├── guards/jwt-auth.guard.ts
│   │   │   ├── guards/roles.guard.ts
│   │   │   └── decorators/roles.decorator.ts
│   │   ├── database/
│   │   │   ├── database.module.ts
│   │   │   └── prisma.service.ts
│   │   └── modules/
│   │       ├── auth/
│   │       ├── users/
│   │       ├── categories/
│   │       ├── repairs/
│   │       ├── offers/
│   │       ├── reviews/
│   │       ├── workshop/
│   │       ├── subscriptions/
│   │       ├── storage/
│   │       └── notifications/
│   └── test/
├── mobile/
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── core/
│   │   │   ├── constants/colors.dart
│   │   │   ├── constants/styles.dart
│   │   │   ├── theme/app_theme.dart
│   │   │   ├── network/api_client.dart
│   │   │   ├── network/api_endpoints.dart
│   │   │   └── widgets/
│   │   │       ├── status_badge.dart
│   │   │       ├── star_rating.dart
│   │   │       ├── techsos_button.dart
│   │   │       └── audio_recorder_widget.dart
│   │   └── features/
│   │       ├── auth/
│   │       ├── client/
│   │       ├── provider/
│   │       ├── subscription/
│   │       └── profile/
│   └── test/
```

---

### Task 1: Backend Scaffolding with NestJS, Prisma & SQLite

**Files:**
- Create: `backend/package.json`
- Create: `backend/tsconfig.json`
- Create: `backend/prisma/schema.prisma`
- Create: `backend/src/database/prisma.service.ts`
- Create: `backend/src/database/database.module.ts`
- Create: `backend/src/app.module.ts`
- Create: `backend/src/main.ts`
- Test: `backend/test/prisma.spec.ts`

**Interfaces:**
- Produces: `PrismaService` injection for all modules, NestJS HTTP server running on port 3000 with CORS and `/uploads` static file serving.

- [ ] **Step 1: Write backend dependencies and configuration files**
Scaffold `backend/package.json`, `backend/tsconfig.json`, `backend/nest-cli.json`.
- [ ] **Step 2: Setup Prisma schema with SQLite provider**
Define `User`, `ProviderProfile`, `DeviceCategory`, `IssueType`, `RepairRequest`, `Offer`, `Review`, `WorkshopEntry`, `Subscription` in `backend/prisma/schema.prisma`.
- [ ] **Step 3: Implement PrismaService and test database connectivity**
Create `backend/src/database/prisma.service.ts` and write `backend/test/prisma.spec.ts`.
- [ ] **Step 4: Run tests and generate Prisma Client**
Execute Prisma migration and Jest tests to verify database initialization.
- [ ] **Step 5: Commit**
`git add backend/` and commit `feat(backend): scaffold NestJS app with Prisma and SQLite schema`.

---

### Task 2: Categories, Pannes & Seed Module

**Files:**
- Create: `backend/src/modules/categories/categories.controller.ts`
- Create: `backend/src/modules/categories/categories.service.ts`
- Create: `backend/src/modules/categories/categories.module.ts`
- Create: `backend/src/modules/categories/dto/create-category.dto.ts`
- Create: `backend/src/modules/categories/dto/create-issue.dto.ts`
- Create: `backend/prisma/seed.ts`
- Test: `backend/src/modules/categories/categories.service.spec.ts`

**Interfaces:**
- Consumes: `PrismaService`
- Produces:
  - `GET /api/categories` : retourne la liste hiérarchique des catégories avec leurs types de pannes
  - `POST /api/categories` : création d'une catégorie (Admin)
  - `POST /api/categories/:id/issues` : ajout d'un type de panne
  - `GET /api/categories/pending-issues` : pannes en attente de validation

- [ ] **Step 1: Write failing unit test for CategoriesService**
- [ ] **Step 2: Verify test fails**
- [ ] **Step 3: Implement CategoriesService, Controller and DTOs**
- [ ] **Step 4: Populate seed script with Bamako device categories (Smartphone, Ordinateur, Imprimante, etc.)**
- [ ] **Step 5: Run tests and seed database**
Verify all tests pass and seed runs cleanly.
- [ ] **Step 6: Commit**
`git commit -m "feat(backend): add categories and issues module with Bamako seeds"`

---

### Task 3: Authentication & User/Provider Profiles Module

**Files:**
- Create: `backend/src/modules/auth/auth.controller.ts`
- Create: `backend/src/modules/auth/auth.service.ts`
- Create: `backend/src/modules/auth/auth.module.ts`
- Create: `backend/src/modules/auth/dto/register-client.dto.ts`
- Create: `backend/src/modules/auth/dto/register-provider.dto.ts`
- Create: `backend/src/modules/auth/dto/login.dto.ts`
- Create: `backend/src/common/guards/jwt-auth.guard.ts`
- Create: `backend/src/common/guards/roles.guard.ts`
- Create: `backend/src/modules/users/users.controller.ts`
- Create: `backend/src/modules/users/users.service.ts`
- Test: `backend/src/modules/auth/auth.service.spec.ts`

**Interfaces:**
- Consumes: `PrismaService`
- Produces:
  - `POST /api/auth/register-client`
  - `POST /api/auth/register-provider` (crée User + ProviderProfile avec quartier et spécialités)
  - `POST /api/auth/login` (retourne `{ access_token, user }`)
  - `GET /api/users/me`

- [ ] **Step 1: Write failing unit test for AuthService (registration, hashing, JWT token generation)**
- [ ] **Step 2: Run test to verify failure**
- [ ] **Step 3: Implement AuthService, Guards, Controller and DTOs**
- [ ] **Step 4: Run tests to verify they pass**
- [ ] **Step 5: Commit**
`git commit -m "feat(backend): add auth and provider profile management with JWT"`

---

### Task 4: Storage & Repair Requests Module (Text + Voice + Photos)

**Files:**
- Create: `backend/src/modules/storage/storage.controller.ts`
- Create: `backend/src/modules/storage/storage.service.ts`
- Create: `backend/src/modules/storage/storage.module.ts`
- Create: `backend/src/modules/repairs/repairs.controller.ts`
- Create: `backend/src/modules/repairs/repairs.service.ts`
- Create: `backend/src/modules/repairs/repairs.module.ts`
- Create: `backend/src/modules/repairs/dto/create-repair.dto.ts`
- Test: `backend/src/modules/repairs/repairs.service.spec.ts`

**Interfaces:**
- Consumes: `PrismaService`, `StorageService`
- Produces:
  - `POST /api/storage/upload` : upload de fichiers médias (audio vocal `.m4a` / `.mp3`, photos)
  - `POST /api/repairs` : publication d'annonce de panne
  - `GET /api/repairs` : liste des pannes avec filtres
  - `GET /api/repairs/feed` : fil personnalisé prestataire basé sur ses spécialités
  - `GET /api/repairs/my-requests` : annonces du client
  - `GET /api/repairs/:id` : détail d'une panne

- [ ] **Step 1: Write failing test for RepairsService (creation, feed filtering by provider specialty)**
- [ ] **Step 2: Run test to verify failure**
- [ ] **Step 3: Implement StorageService (local storage with static serve) and RepairsService/Controller**
- [ ] **Step 4: Run tests to verify they pass**
- [ ] **Step 5: Commit**
`git commit -m "feat(backend): add storage and repair request publication module"`

---

### Task 5: Offers & Reviews Module

**Files:**
- Create: `backend/src/modules/offers/offers.controller.ts`
- Create: `backend/src/modules/offers/offers.service.ts`
- Create: `backend/src/modules/offers/offers.module.ts`
- Create: `backend/src/modules/offers/dto/create-offer.dto.ts`
- Create: `backend/src/modules/reviews/reviews.controller.ts`
- Create: `backend/src/modules/reviews/reviews.service.ts`
- Create: `backend/src/modules/reviews/reviews.module.ts`
- Create: `backend/src/modules/reviews/dto/create-review.dto.ts`
- Test: `backend/src/modules/offers/offers.service.spec.ts`
- Test: `backend/src/modules/reviews/reviews.service.spec.ts`

**Interfaces:**
- Consumes: `PrismaService`
- Produces:
  - `POST /api/repairs/:id/offers` : soumission d'une offre par le réparateur
  - `POST /api/offers/:id/accept` : acceptation par le client (statut passe à `IN_PROGRESS`)
  - `POST /api/repairs/:id/complete` : achèvement de la réparation
  - `POST /api/repairs/:id/reviews` : notation 1-5 étoiles, avis et mise à jour de `ratingAvg`

- [ ] **Step 1: Write failing test for offer submission and acceptance**
- [ ] **Step 2: Write failing test for review submission and provider average rating recalculation**
- [ ] **Step 3: Implement OffersService, ReviewsService and controllers**
- [ ] **Step 4: Run tests to verify all pass**
- [ ] **Step 5: Commit**
`git commit -m "feat(backend): add offers lifecycle and reviews module"`

---

### Task 6: Workshop Back-Office & Subscriptions Module (Mobile Money & WhatsApp)

**Files:**
- Create: `backend/src/modules/notifications/whatsapp.service.ts`
- Create: `backend/src/modules/workshop/workshop.controller.ts`
- Create: `backend/src/modules/workshop/workshop.service.ts`
- Create: `backend/src/modules/workshop/workshop.module.ts`
- Create: `backend/src/modules/workshop/dto/create-workshop-entry.dto.ts`
- Create: `backend/src/modules/subscriptions/subscriptions.controller.ts`
- Create: `backend/src/modules/subscriptions/subscriptions.service.ts`
- Create: `backend/src/modules/subscriptions/subscriptions.module.ts`
- Create: `backend/src/modules/subscriptions/dto/pay-mobile-money.dto.ts`
- Test: `backend/src/modules/workshop/workshop.service.spec.ts`
- Test: `backend/src/modules/subscriptions/subscriptions.service.spec.ts`

**Interfaces:**
- Consumes: `PrismaService`, `WhatsAppService`
- Produces:
  - `GET /api/workshop` : liste des entrées d'atelier
  - `POST /api/workshop/quick-entry` : enregistrement client physique + déclenchement WhatsApp
  - `PATCH /api/workshop/:id/status` : transition de statut + notification WhatsApp de mise à disposition
  - `GET /api/subscriptions/current` : statut d'abonnement
  - `POST /api/subscriptions/pay-mobile-money` : simulation/paiement Orange Money / Moov Money (5 000 FCFA)

- [ ] **Step 1: Write failing tests for WorkshopService and SubscriptionsService**
- [ ] **Step 2: Verify tests fail**
- [ ] **Step 3: Implement WhatsAppService mock/logger and Workshop/Subscription modules**
- [ ] **Step 4: Run tests to verify they pass**
- [ ] **Step 5: Commit**
`git commit -m "feat(backend): add workshop journal with WhatsApp trigger and Mobile Money subscriptions"`

---

### Task 7: Flutter Project Scaffolding & Design System

**Files:**
- Create: `mobile/pubspec.yaml`
- Create: `mobile/lib/main.dart`
- Create: `mobile/lib/app.dart`
- Create: `mobile/lib/core/constants/colors.dart`
- Create: `mobile/lib/core/constants/styles.dart`
- Create: `mobile/lib/core/theme/app_theme.dart`
- Create: `mobile/lib/core/widgets/status_badge.dart`
- Create: `mobile/lib/core/widgets/star_rating.dart`
- Create: `mobile/lib/core/widgets/techsos_button.dart`
- Test: `mobile/test/status_badge_test.dart`
- Test: `mobile/test/star_rating_test.dart`

**Interfaces:**
- Produces:
  - `TechSosColors` (Bleu nuit `#1F3A5F`, Orange `#E8641C`, Vert `#2E8B57`, Ambre `#D9A441`, Fond `#F7F8FA`)
  - `StatusBadge(status: 'PENDING' | 'OFFERS_RECEIVED' | 'IN_PROGRESS' | 'COMPLETED')`
  - `StarRating(rating: double, onRatingChanged?: Function)`
  - `TechSosButton(label: string, onPressed: VoidCallback, isSecondary?: bool)`

- [ ] **Step 1: Initialize Flutter project structure and pubspec.yaml with dependencies (`flutter_riverpod`, `dio`, etc.)**
- [ ] **Step 2: Write failing widget test for `StatusBadge` and `StarRating`**
- [ ] **Step 3: Implement colors, theme and core widgets**
- [ ] **Step 4: Run widget tests to verify they pass**
- [ ] **Step 5: Commit**
`git commit -m "feat(mobile): scaffold Flutter project with TechSOS design system and core widgets"`

---

### Task 8: Flutter Network, Offline Cache & Authentication

**Files:**
- Create: `mobile/lib/core/network/api_client.dart`
- Create: `mobile/lib/core/network/api_endpoints.dart`
- Create: `mobile/lib/core/offline/cache_manager.dart`
- Create: `mobile/lib/features/auth/models/user_model.dart`
- Create: `mobile/lib/features/auth/providers/auth_provider.dart`
- Create: `mobile/lib/features/auth/screens/login_screen.dart`
- Create: `mobile/lib/features/auth/screens/register_screen.dart`
- Create: `mobile/lib/features/auth/screens/role_selection_screen.dart`
- Test: `mobile/test/auth_provider_test.dart`

**Interfaces:**
- Consumes: Backend Auth APIs
- Produces: `authProvider` (Riverpod) exposant l'utilisateur connecté, le token JWT et le rôle (`CLIENT` ou `PROVIDER`), navigation automatique vers le mode correspondant.

- [ ] **Step 1: Write test for AuthProvider state transitions (login, register, logout)**
- [ ] **Step 2: Verify test fails**
- [ ] **Step 3: Implement ApiClient with Dio interceptor, CacheManager and Auth screens**
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit**
`git commit -m "feat(mobile): add network client, offline cache and auth screens"`

---

### Task 9: Flutter Client Experience (Home, Voice & Text SOS, Offers, Review)

**Files:**
- Create: `mobile/lib/core/widgets/audio_recorder_widget.dart`
- Create: `mobile/lib/features/client/screens/client_main_screen.dart`
- Create: `mobile/lib/features/client/screens/client_home_screen.dart`
- Create: `mobile/lib/features/client/screens/publish_repair_screen.dart`
- Create: `mobile/lib/features/client/screens/my_requests_screen.dart`
- Create: `mobile/lib/features/client/screens/request_detail_screen.dart`
- Create: `mobile/lib/features/client/providers/client_repairs_provider.dart`
- Test: `mobile/test/publish_repair_test.dart`

**Interfaces:**
- Produces:
  - Formulaire de panne avec sélection catégorie/panne, zone texte et bouton vocal proéminent côte à côte
  - Écran de suivi des pannes avec badges de statuts colorés
  - Comparateur d'offres reçues avec prix en FCFA, délai et note du réparateur
  - Écran de notation finale 1 à 5 étoiles

- [ ] **Step 1: Write test for AudioRecorderWidget and ClientRepairsProvider**
- [ ] **Step 2: Verify test fails**
- [ ] **Step 3: Implement AudioRecorderWidget with local file safety fallback**
- [ ] **Step 4: Implement Client HomeScreen, PublishRepairScreen, MyRequestsScreen, RequestDetailScreen**
- [ ] **Step 5: Run tests and verify they pass**
- [ ] **Step 6: Commit**
`git commit -m "feat(mobile): add complete client flow with voice recording and offers review"`

---

### Task 10: Flutter Provider Experience & Back-Office Workshop

**Files:**
- Create: `mobile/lib/features/provider/screens/provider_main_screen.dart`
- Create: `mobile/lib/features/provider/screens/provider_feed_screen.dart`
- Create: `mobile/lib/features/provider/screens/submit_offer_dialog.dart`
- Create: `mobile/lib/features/provider/screens/my_offers_screen.dart`
- Create: `mobile/lib/features/provider/screens/workshop_journal_screen.dart`
- Create: `mobile/lib/features/provider/screens/quick_client_entry_dialog.dart`
- Create: `mobile/lib/features/subscription/screens/subscription_screen.dart`
- Create: `mobile/lib/features/provider/providers/provider_workshop_provider.dart`
- Test: `mobile/test/workshop_provider_test.dart`

**Interfaces:**
- Produces:
  - Fil des pannes selon spécialités avec modal de soumission d'offre
  - Journal d'atelier avec filtres (Déposé, En cours, Prêt, Livré)
  - Dialogue de saisie rapide client atelier (texte ou note vocale + notification WhatsApp)
  - Écran d'abonnement avec sélection Orange Money / Moov Money et validation

- [ ] **Step 1: Write test for WorkshopProvider and Offer submission**
- [ ] **Step 2: Verify test fails**
- [ ] **Step 3: Implement Provider Feed, MyOffersScreen, WorkshopJournalScreen and SubscriptionScreen**
- [ ] **Step 4: Run tests and verify they pass**
- [ ] **Step 5: Commit**
`git commit -m "feat(mobile): add provider feed, workshop back-office and subscription management"`

---

### Task 11: End-to-End Integration, Seeds & Verification

**Files:**
- Create: `backend/test/e2e-workflow.spec.ts`
- Create: `README.md` (guide de démarrage complet backend et mobile, documentation d'API et comptes de test)

**Interfaces:**
- Valide l'ensemble du cycle de vie complet de l'application :
  1. Démarrage de l'API backend et initialisation des données de Bamako
  2. Inscription d'un client et d'un réparateur d'atelier à Hamdallaye ACI 2000
  3. Publication d'une annonce de panne avec note vocale
  4. Réception dans le fil du réparateur et soumission d'une offre en FCFA
  5. Acceptation par le client
  6. Clôture de la réparation et avis 5 étoiles
  7. Enregistrement d'un client physique au journal d'atelier avec accusé WhatsApp

- [ ] **Step 1: Write E2E integration test script simulating the complete workflow**
- [ ] **Step 2: Run E2E test and verify 100% success**
- [ ] **Step 3: Write comprehensive README.md with setup guide and test accounts**
- [ ] **Step 4: Commit**
`git commit -m "feat: complete end-to-end integration test and documentation"`
