# TechSOS — Plateforme de Dépannage Informatique & Électronique d'Urgence

> Conçu et développé par **Golden Innovation Tech** à **Bamako, Mali**.  
> Mise en relation instantanée entre usagers en détresse technique et réparateurs qualifiés, avec gestion d'atelier intégrée et résilience aux contraintes locales.

---

## 📌 Sommaire

1. [Présentation & Enjeux Locaux](#-présentation--enjeux-locaux)
2. [Architecture & Stack Technologique](#-architecture--stack-technologique)
3. [Structure du Projet](#-structure-du-projet)
4. [Prise en Main Rapide (Quickstart)](#-prise-en-main-rapide-quickstart)
5. [Comptes de Démonstration Pré-configurés](#-comptes-de-démonstration-pré-configurés)
6. [Matrice des Fonctionnalités MVP](#-matrice-des-fonctionnalités-mvp)
7. [Résilience Réseau & Mode Dégradé à Bamako](#-résilience-réseau--mode-dégradé-à-bamako)
8. [Vérification & Suites de Tests](#-vérification--suites-de-tests)

---

## 💡 Présentation & Enjeux Locaux

À Bamako et dans les grandes agglomérations maliennes, la panne d'un équipement informatique (smartphone, ordinateur portable de travail, imprimante de bureau) entraîne une paralysie immédiate des activités professionnelles et personnelles. Les usagers se heurtent traditionnellement à trois écueils majeurs :
- **Opacité des tarifs et manque de traçabilité** des pièces détachées.
- **Difficulté à exprimer techniquement la panne par écrit**, dans un contexte où les notes vocales WhatsApp sont le canal de communication privilégié.
- **Instabilité chronique de la connectivité réseau (3G/4G) et coupures de courant imprévues.**

**TechSOS** répond directement à ces réalités de terrain en combinant :
- Une application mobile Flutter fluide et moderne (Material 3), avec **enregistrement vocal de la panne en un clic**, devis chiffrés en **FCFA**, et suivi en direct.
- Un système d'enchères inversées et de mise en concurrence saine des réparateurs vérifiés par quartier (Hamdallaye ACI 2000, Badalabougou, Lafiabougou, Médina Coura, etc.).
- Un **Back-Office Atelier ("Quick Entry")** permettant aux réparateurs de consigner les clients physiques de passage et d'envoyer des notifications WhatsApp automatiques lors de la réception et de la mise à disposition de l'appareil.
- Un modèle de monétisation adapté via **Mobile Money (Orange Money Mali & Moov Money)** pour les abonnements professionnels à 5 000 FCFA/mois.

---

## 🛠 Architecture & Stack Technologique

TechSOS repose sur une architecture découplée, typée et hautement testable :

```
                        ┌──────────────────────────────────────────┐
                        │        Application Mobile Flutter        │
                        │ (Riverpod 2.x, Material 3, Dio, Record) │
                        └─────────────────────┬────────────────────┘
                                              │ HTTP REST / JSON
                                              │ Multipart (Uploads)
                                              ▼
                        ┌──────────────────────────────────────────┐
                        │           API Backend NestJS             │
                        │     (TypeScript, Passport JWT, Pipes)    │
                        └──────┬────────────────────────────┬──────┘
                               │                            │
                               ▼                            ▼
                 ┌───────────────────────────┐    ┌────────────────────┐
                 │       ORM Prisma          │    │ Notifications      │
                 │ (SQLite dev / PostgreSQL) │    │ & Stockage Fichiers│
                 └───────────────────────────┘    └────────────────────┘
```

### Frontend Mobile
- **Framework** : Flutter 3.x (Dart 3.x)
- **Gestion d'État** : Riverpod (StateNotifier / Notifier)
- **Client HTTP** : Dio avec intercepteurs JWT, gestion des timeouts et reconnexion automatique
- **Audio & Médias** : Paquet `record` pour la captation de notes vocales (format AAC/M4A), `audioplayers` pour la restitution
- **Interface Utilisateur** : Design System Material 3, palette de couleurs TechSOS (Bleu Nuit `#1E3A8A`, Orange d'Urgence `#F97316`, Vert Succès `#10B981`)
- **Stockage Local** : `shared_preferences` pour le cache des catégories et sessions

### Backend API
- **Framework** : NestJS 10.x (Node.js & TypeScript)
- **Base de Données & ORM** : Prisma ORM v5 avec connecteur SQLite (environnement de développement/test) et support natif PostgreSQL
- **Sécurité & Authentification** : JWT (JSON Web Tokens), Passport-JWT, hachage sécurisé bcrypt avec salt rounds
- **Validation** : `class-validator` et `class-transformer` sur l'ensemble des DTOs entrants
- **Stockage des Médias** : Multer avec validation stricte MIME (images et audio M4A/AAC/MP3) et exposition statique `/uploads/`
- **Notifications** : Service de messagerie WhatsApp transactionnelle simulant l'envoi de messages d'atelier en temps réel

---

## 📂 Structure du Projet

```
tech_sos/
├── backend/                        # API REST modulaire NestJS
│   ├── prisma/
│   │   ├── schema.prisma           # Schéma relationnel Prisma (SQLite/PostgreSQL)
│   │   └── seed.ts                 # Référentiel Bamako (catégories, pannes, comptes démo)
│   ├── src/
│   │   ├── common/                 # Décorateurs (@CurrentUser, @Roles), Guards JWT
│   │   ├── database/               # Module et service Prisma
│   │   ├── modules/
│   │   │   ├── auth/               # Inscription Client & Réparateur, Connexion unifiée
│   │   │   ├── categories/         # Catégories d'équipements & types de pannes
│   │   │   ├── repairs/            # Annonces SOS de réparation & Fil d'opportunités
│   │   │   ├── offers/             # Devis chiffrés FCFA & validation client
│   │   │   ├── reviews/            # Évaluation 5 étoiles & réputation réparateur
│   │   │   ├── workshop/           # Back-Office Atelier & entrées physiques (Walk-in)
│   │   │   ├── subscriptions/      # Abonnements Pro & Paiement Orange/Moov Money
│   │   │   ├── notifications/      # Service transactionnel WhatsApp
│   │   │   ├── storage/            # Téléversement médias & notes vocales
│   │   │   └── users/              # Annuaire et profils des réparateurs
│   │   ├── app.module.ts
│   │   └── main.ts
│   └── test/
│       ├── prisma.spec.ts          # Test d'intégration base de données
│       └── e2e-workflow.spec.ts    # Test d'intégration E2E du cycle de vie complet (13 étapes)
│
├── mobile/                         # Application mobile Flutter
│   ├── lib/
│   │   ├── config/                 # Thème Material 3, Couleurs, Configuration API
│   │   ├── models/                 # Modèles de données Dart immutables
│   │   ├── providers/              # Fournisseurs Riverpod (Auth, Categories, Repairs, Workshop)
│   │   ├── screens/                # Écrans Client, Réparateur et Communs
│   │   ├── services/               # Services Dio API, AudioRecorder
│   │   └── widgets/                # Composants réutilisables (TechSosButton, StatusBadge, Audio)
│   └── test/                       # 52 tests unitaires, widgets et intégration Flutter
│
└── README.md                       # Documentation officielle du projet
```

---

## 🚀 Prise en Main Rapide (Quickstart)

### 1. Prérequis Système
- **Node.js** v18.x ou v20.x et **npm**
- **Flutter SDK** v3.22+ avec environnement Android ou simulateur configuré
- **Git**

---

### 2. Démarrage du Backend NestJS

1. Accédez au répertoire `backend` :
   ```bash
   cd backend
   ```

2. Installez les dépendances :
   ```bash
   npm install
   ```

3. Synchronisez le schéma Prisma et chargez les données initiales de Bamako :
   ```bash
   npm run prisma:push
   npm run prisma:seed
   ```

4. Démarrez le serveur backend en mode développement :
   ```bash
   npm run start:dev
   ```

Le serveur démarre sur le port `3000` :
- **Point d'entrée API** : `http://localhost:3000/api`
- **Dossier de stockage public des médias** : `http://localhost:3000/uploads/`

---

### 3. Lancement de l'Application Mobile Flutter

1. Accédez au répertoire `mobile` :
   ```bash
   cd mobile
   ```

2. Récupérez les paquets Flutter :
   ```bash
   flutter pub get
   ```

3. Vérifiez la configuration de l'URL API dans `mobile/lib/config/api_config.dart` :
   - Pour un émulateur Android standard : `http://10.0.2.2:3000/api`
   - Pour un appareil physique sur le même réseau Wi-Fi : `http://<IP_DE_VOTRE_PC>:3000/api`
   - Pour l'application Windows / macOS / Web : `http://localhost:3000/api`

4. Lancez l'application :
   ```bash
   flutter run
   ```

---

## 👥 Comptes de Démonstration Pré-configurés

La commande `npm run prisma:seed` initialise automatiquement trois comptes de démonstration prêts à l'emploi :

| Rôle | Nom complet | Numéro de téléphone | Mot de passe | Rôle & Établissement | Quartier (Bamako) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Client Démo** | Amadou Diallo | `+22370000001` | `password123` | Particulier en détresse SOS | Badalabougou |
| **Réparateur Atelier** | Mamadou Koné | `+22376000001` | `password123` | *Clinique High-Tech Bamako* (Abonnement Actif) | Hamdallaye ACI 2000 |
| **Administrateur** | Admin TechSOS | `+22370000000` | `adminpassword123` | Siège Golden Innovation Tech | Bamako Centre |

---

## 📱 Matrice des Fonctionnalités MVP

### 1. Parcours Client (SOS Dépannage)
- **Création de Panne Express** : Sélection visuelle de l'appareil (Smartphone, Ordinateur, Imprimante, Tablette), choix ou saisie libre du symptôme.
- **Note Vocale Directe** : Enregistrement micro d'une note audio de 30 secondes pour expliciter le dysfonctionnement sans barrière d'écriture.
- **Réception & Comparaison des Devis** : Consultation des offres en FCFA soumises par les ateliers de Bamako avec délai garanti (ex: 2 heures, 24h).
- **Validation d'Offre & Clôture** : Acceptation du réparateur retenu (`IN_PROGRESS`), notification de mise à disposition, clôture (`COMPLETED`).
- **Évaluation & Avis 5 Étoiles** : Notation et commentaire mis à jour immédiatement sur la note moyenne publique du réparateur.

### 2. Parcours Réparateur (Développement d'Activité)
- **Fil d'Opportunités (Feed SOS)** : Consultation en temps réel des pannes signalées dans sa zone d'intervention.
- **Chiffrage Express** : Proposition de devis compétitif en FCFA avec délai estimé et engagement de garantie pièces.
- **Back-Office Gestion Atelier (Quick Entry)** : Enregistrement sur place des clients physiques non utilisateurs de l'application (modèle, panne, tarif convenu).
- **Notifications WhatsApp Automatisées** :
  - Envoi instantané du récépissé de dépôt d'appareil avec identifiant unique de ticket.
  - Envoi de l'alerte de retrait immédiat dès que le réparateur passe la fiche au statut `READY_FOR_PICKUP`.
- **Abonnement Pro Mobile Money** : Souscription et renouvellement en un clic à 5 000 FCFA/mois via Orange Money Mali ou Moov Money avec génération de référence de transaction.

---

## ⚡ Résilience Réseau & Mode Dégradé à Bamako

Pour garantir une expérience utilisateur irréprochable face aux réalités d'infrastructure de Bamako :
1. **Mise en Cache Hors-Ligne des Catégories** : Les catégories et types de pannes officielles sont sauvegardées localement via `SharedPreferences`. Même en zone blanche ou coupure 3G, l'utilisateur peut préparer son annonce SOS.
2. **Gestion Optimisée des Timeouts & Retry** : Le client Dio applique des délais d'attente de 15 secondes et gère élégamment les pertes momentanées de connexion sans blocage de l'interface.
3. **Capture Vocale Locale Préalable** : L'enregistrement audio est finalisé et compressé sur le stockage local du téléphone avant toute tentative d'envoi réseau.
4. **Relais WhatsApp Transactionnel** : Pour le suivi d'atelier, les notifications transitent par le canal WhatsApp, hautement résilient même sur des forfaits data restreints ("Pass WhatsApp").

---

## 🧪 Vérification & Suites de Tests

Le projet dispose d'une couverture de tests rigoureuse tant sur le backend que sur le frontend mobile.

### Backend NestJS (11 Suites — 102 Tests)
Pour lancer l'intégralité des tests unitaires et d'intégration :
```bash
cd backend
npm test
```

Résultats d'exécution :
```
PASS src/modules/repairs/repairs.service.spec.ts
PASS src/modules/reviews/reviews.service.spec.ts
PASS src/modules/categories/categories.service.spec.ts
PASS src/modules/offers/offers.service.spec.ts
PASS test/prisma.spec.ts
PASS src/modules/workshop/workshop.service.spec.ts
PASS src/modules/users/users.service.spec.ts
PASS src/modules/storage/storage.service.spec.ts
PASS src/modules/subscriptions/subscriptions.service.spec.ts
PASS src/modules/auth/auth.service.spec.ts
PASS test/e2e-workflow.spec.ts (Workflow E2E 13 étapes)

Test Suites: 11 passed, 11 total
Tests:       102 passed, 102 total
```

#### Cycle E2E Workflow Test (`backend/test/e2e-workflow.spec.ts`)
Le test de bout en bout valide les 13 étapes du cycle de vie complet de la plateforme :
1. Récupération du catalogue de catégories & pannes (`GET /api/categories`)
2. Inscription d'un client à Bamako (`POST /api/auth/register-client`)
3. Inscription d'un atelier réparateur à Hamdallaye ACI 2000 (`POST /api/auth/register-provider`)
4. Téléversement d'une note vocale dans le stockage sécurisé (`POST /api/storage/upload`)
5. Publication d'une annonce SOS de réparation (`POST /api/repairs`)
6. Consultation du fil des pannes par le réparateur (`GET /api/repairs/feed`)
7. Soumission d'un devis chiffré à 25 000 FCFA sous 2h (`POST /api/repairs/:id/offers`)
8. Consultation et acceptation du devis par le client (`POST /api/offers/:id/accept`)
9. Clôture de la réparation à l'état `COMPLETED` (`POST /api/repairs/:id/complete`)
10. Dépôt d'un avis 5 étoiles et vérification de la réputation (`POST /api/repairs/:id/reviews`)
11. Enregistrement d'un client physique d'atelier avec récépissé WhatsApp (`POST /api/workshop/quick-entry`)
12. Passage de l'appareil à `READY_FOR_PICKUP` avec alerte WhatsApp (`PATCH /api/workshop/:id/status`)
13. Souscription à l'abonnement Orange Money 5 000 FCFA avec passage au statut `ACTIVE` (`POST /api/subscriptions/pay-mobile-money`)

---

### Mobile Flutter (52 Tests & Analyse Statique 0 Défaut)
Pour exécuter la suite de tests mobiles :
```bash
cd mobile
flutter test
```
Résultat : **52/52 tests validés avec succès.**

Pour vérifier l'analyse statique du code Dart :
```bash
cd mobile
flutter analyze
```
Résultat : **No issues found! (0 warning, 0 error).**

---

## 📄 Licence & Droits

Propriété exclusive de **Golden Innovation Tech** — Bamako, Mali.  
Tous droits réservés © 2026.
