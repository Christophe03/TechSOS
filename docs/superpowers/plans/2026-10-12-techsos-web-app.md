# TechSOS Web App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Développer et déployer l'application Web moderne, responsive et professionnelle TechSOS (Next.js 15, React 19, TypeScript, Tailwind CSS) connectée à l'API NestJS existante, incluant la vitrine publique, l'espace client SOS et le tableau de bord atelier.

**Architecture:** Application Next.js 15 avec App Router située dans `web/`. Consommation directe de l'API REST NestJS sur `http://localhost:3000/api`. Intégration de la charte graphique TechSOS (Bleu Nuit, Orange Technique, Vert Succès, Ambre), enregistrement vocal Web Audio pour les pannes et génération de liens WhatsApp `wa.me/` pour le journal d'atelier.

**Tech Stack:** Next.js 15 (App Router), React 19, TypeScript, Tailwind CSS, Lucide React, Axios.

**Spec:** `docs/superpowers/specs/2026-10-12-techsos-web-app-design.md`

## Global Constraints

- Langue principale : Français
- Monnaie : Franc CFA (FCFA / XOF)
- Contexte géographique : Bamako, Mali (Communes I à VI, quartiers clés : ACI 2000, Badalabougou, Lafiabougou, Médina Coura, etc.)
- Palette officielle :
  - `primary`: `#1F3A5F`
  - `accent`: `#E8641C`
  - `success`: `#2E8B57`
  - `alert`: `#D9A441`
  - `background`: `#F8FAFC`
  - `dark`: `#0F172A`
- Port Web : `3001` (évite tout conflit avec NestJS sur 3000 et Flutter web-server sur 8080)
- Exécution sous Windows : toujours utiliser `npm.cmd` et `npx.cmd`

---

### Task 1: Scaffolding du projet Next.js 15 & Design System TechSOS

**Files:**
- Create: `web/package.json`
- Create: `web/tsconfig.json`
- Create: `web/next.config.ts`
- Create: `web/tailwind.config.ts`
- Create: `web/postcss.config.mjs`
- Create: `web/src/app/globals.css`
- Create: `web/src/app/layout.tsx`
- Create: `web/src/components/layout/Navbar.tsx`
- Create: `web/src/components/layout/Footer.tsx`
- Create: `web/src/components/ui/Button.tsx`
- Create: `web/src/components/ui/Badge.tsx`

**Interfaces:**
- Produces: Base layout, design system Tailwind tokens, components UI `Button`, `Badge`, `Navbar`, `Footer`.

- [ ] **Step 1: Initialiser le package.json et les dépendances dans `web/`**
- [ ] **Step 2: Configurer Tailwind CSS avec les tokens TechSOS (`primary`, `accent`, `success`, `alert`) et les polices**
- [ ] **Step 3: Créer les composants UI partagés (`Button`, `Badge`, `Card`) et le Layout racine (`Navbar`, `Footer`) avec le logo vectoriel officiel TechSOS**
- [ ] **Step 4: Tester le build initial avec `npm.cmd run build` dans `web/`**
- [ ] **Step 5: Commit `feat(web): scaffold Next.js 15 app with TechSOS design system and layout`**

---

### Task 2: Client API REST, Authentification & Sessions

**Files:**
- Create: `web/src/lib/api/client.ts`
- Create: `web/src/lib/api/auth.ts`
- Create: `web/src/lib/context/AuthContext.tsx`
- Create: `web/src/app/(auth)/connexion/page.tsx`
- Create: `web/src/app/(auth)/inscription/page.tsx`

**Interfaces:**
- Consumes: Endpoints NestJS `POST /api/auth/login`, `POST /api/auth/register-client`, `POST /api/auth/register-provider`.
- Produces: `useAuth()` hook, session persistée, pages de connexion et d'inscription avec sélection de rôle (Client / Réparateur).

- [ ] **Step 1: Créer le client HTTP Axios avec gestion des tokens JWT et intercepteurs d'erreurs en français**
- [ ] **Step 2: Créer le AuthContext React avec persistance dans localStorage/cookies et méthodes `login`, `registerClient`, `registerProvider`, `logout`**
- [ ] **Step 3: Développer la page de connexion responsive avec bascule rapide et comptes démo de Bamako**
- [ ] **Step 4: Développer la page d'inscription avec onglets Client / Atelier (spécialités, nom d'atelier, quartier)**
- [ ] **Step 5: Vérifier le build et la compilation TypeScript**
- [ ] **Step 6: Commit `feat(web): add API client, AuthContext, and login/register pages`**

---

### Task 3: Landing Page Vitrine Haute Conversion & Réassurance

**Files:**
- Create: `web/src/app/page.tsx`
- Create: `web/src/components/landing/HeroSection.tsx`
- Create: `web/src/components/landing/ServicesSection.tsx`
- Create: `web/src/components/landing/HowItWorksSection.tsx`
- Create: `web/src/components/landing/BamakoDistrictsSection.tsx`
- Create: `web/src/components/landing/TestimonialsSection.tsx`
- Create: `web/src/components/landing/EmergencyBanner.tsx`

**Interfaces:**
- Consumes: Tokens de design, routes `/(client)/sos-panne` et `/(auth)/connexion`.
- Produces: Landing page publique responsive avec SEO metadata, CTA d'urgence, simulateur et annuaire des communes.

- [ ] **Step 1: Développer la Hero Section avec accroche percutante pour Bamako, boutons d'action double et badges de garantie**
- [ ] **Step 2: Développer la section des catégories d'équipements (Smartphones, Ordinateurs, Imprimantes, Électronique)**
- [ ] **Step 3: Développer la section explicative "Comment ça marche" en 3 étapes claires**
- [ ] **Step 4: Développer la section des quartiers et ateliers vérifiés à Bamako**
- [ ] **Step 5: Assembler la page d'accueil dans `web/src/app/page.tsx` avec les métadonnées SEO OpenGraph**
- [ ] **Step 6: Commit `feat(web): implement high-converting landing page with emergency CTA and local Bamako showcase`**

---

### Task 4: Espace Client — Déclaration SOS Panne & Suivi des Devis

**Files:**
- Create: `web/src/components/audio/WebAudioRecorder.tsx`
- Create: `web/src/app/(client)/sos-panne/page.tsx`
- Create: `web/src/app/(client)/mes-demandes/page.tsx`
- Create: `web/src/app/(client)/demandes/[id]/page.tsx`
- Create: `web/src/components/client/OffersComparator.tsx`
- Create: `web/src/components/client/ReviewModal.tsx`

**Interfaces:**
- Consumes: Endpoints NestJS `GET /api/categories`, `POST /api/repairs`, `GET /api/repairs/my-repairs`, `POST /api/offers/:id/accept`, `POST /api/reviews`.
- Produces: Formulaire de déclaration avec enregistrement vocal Web Audio, suivi des demandes, acceptation d'offre et avis 5 étoiles.

- [ ] **Step 1: Implémenter le composant `WebAudioRecorder` avec l'API Web Audio (enregistrement, minuteur, pré-écoute et réenregistrement)**
- [ ] **Step 2: Créer le formulaire de déclaration SOS Panne (`/sos-panne`) avec choix de catégorie, description, note vocale, photos et quartier**
- [ ] **Step 3: Développer la page `/mes-demandes` avec filtrage par statut et badges colorés standardisés**
- [ ] **Step 4: Développer la page de détail `/demandes/[id]` avec le comparateur d'offres reçues (prix en FCFA, délai, réputation réparateur) et acceptation en 1 clic**
- [ ] **Step 5: Intégrer la modale d'évaluation 5 étoiles avec commentaire lors de la clôture de réparation**
- [ ] **Step 6: Commit `feat(web): add client SOS breakdown flow with Web Audio recording and offers comparison`**

---

### Task 5: Portail Pro Atelier — Dashboard, Journal Comptoir & Abonnement

**Files:**
- Create: `web/src/app/(atelier)/dashboard/page.tsx`
- Create: `web/src/app/(atelier)/fil-urgences/page.tsx`
- Create: `web/src/app/(atelier)/journal/page.tsx`
- Create: `web/src/app/(atelier)/abonnement/page.tsx`
- Create: `web/src/components/workshop/QuickEntryModal.tsx`
- Create: `web/src/components/workshop/SubmitOfferModal.tsx`
- Create: `web/src/components/workshop/WhatsAppNotificationButton.tsx`

**Interfaces:**
- Consumes: Endpoints NestJS `GET /api/repairs/feed`, `POST /api/offers`, `GET /api/workshop`, `POST /api/workshop/quick-entry`, `PATCH /api/workshop/:id/status`, `POST /api/subscriptions/subscribe`.
- Produces: Tableau de bord réparateur, fil de pannes en temps réel, Journal d'atelier physique avec relance WhatsApp instantanée, paiement d'abonnement Mobile Money.

- [ ] **Step 1: Développer le Dashboard Atelier avec indicateurs clés (chiffre d'affaires estimé, réparations en cours, pannes disponibles)**
- [ ] **Step 2: Développer le fil des urgences (`/atelier/fil-urgences`) avec modale de soumission de devis chiffré (prix FCFA, durée)**
- [ ] **Step 3: Implémenter le Journal d'Atelier de comptoir (`/atelier/journal`) avec la modale "Quick Entry" (client physique direct, panne, tarif)**
- [ ] **Step 4: Implémenter le bouton d'action WhatsApp générant les liens directs `wa.me/223...` pré-remplis pour prévenir le client du statut**
- [ ] **Step 5: Développer la page d'abonnement Pro (`/atelier/abonnement`) à 5 000 FCFA/mois avec simulateur Orange Money et Moov Money**
- [ ] **Step 6: Commit `feat(web): add repairer workshop pro dashboard with quick entry, WhatsApp trigger and subscription`**

---

### Task 6: Intégration globale, Tests de Build, Documentation & Push

**Files:**
- Modify: `README.md`
- Create: `web/README.md`

**Interfaces:**
- Produces: Build complet validé, documentation de démarrage rapide du Web, synchronisation GitHub.

- [ ] **Step 1: Exécuter `npm.cmd run build` dans `web/` et s'assurer de 0 erreur de compilation**
- [ ] **Step 2: Mettre à jour le fichier `README.md` principal pour documenter l'application Web (lancement, routes, architecture)**
- [ ] **Step 3: Créer `web/README.md` avec les guides d'utilisation et de déploiement**
- [ ] **Step 4: Commit `docs: update README with TechSOS Web App instructions`**
- [ ] **Step 5: Push sur la branche `main` du dépôt GitHub `https://github.com/Christophe03/TechSOS.git`**
