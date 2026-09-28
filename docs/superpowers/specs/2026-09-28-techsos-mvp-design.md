# Spécification Technique et Fonctionnelle — MVP TechSOS

**Date** : 28 Septembre 2026  
**Éditeur** : Golden Innovation Tech (Bamako, Mali)  
**Application** : TechSOS Mobile (Flutter) & Backend API (NestJS + Prisma)  
**Statut** : Validé pour implémentation  

---

## 1. Contexte et Objectifs

TechSOS est une plateforme mobile mettant en relation les utilisateurs ayant des appareils électroniques en panne (smartphones, ordinateurs, imprimantes, etc.) avec des réparateurs qualifiés au Mali (principalement Bamako).

### Objectifs du MVP :
1. **Authentification** : Gestion des rôles Client (`CLIENT`), Prestataire (`PROVIDER`) et Administrateur (`ADMIN`).
2. **Publication d'annonces de panne** : Saisie par catégorie, type de panne (ou saisie libre), description textuelle, enregistrement audio vocal et photos d'illustration.
3. **Système d'offres** : Réception des offres des prestataires qualifiés avec prix en Francs CFA (XOF) et délai estimé, comparaison et acceptation par le client.
4. **Clôture et notation** : Confirmation de la réparation, attribution d'une note (1 à 5 étoiles) avec commentaire et mise à jour de la réputation du réparateur.
5. **Gestion administrative** : Catalogue des catégories d'appareils et types de pannes, modération des pannes en saisie libre.
6. **Abonnement prestataire** : Modèle économique à plan unique validant l'accès aux fonctionnalités avancées, compatible Mobile Money (Orange Money, Moov Money).
7. **Back-office atelier minimal** : Journal des entrées/sorties d'appareils pour les réparateurs et déclenchement automatique de notifications WhatsApp aux clients.

---

## 2. Charte Graphique & Identité Visuelle

| Rôle | Nom / Description | Code HEX |
|---|---|---|
| **Primaire** | Bleu nuit / Indigo | `#1F3A5F` |
| **Accent / CTA** | Orange technique (Urgence, action) | `#E8641C` |
| **Succès** | Vert (Réparation terminée, validé) | `#2E8B57` |
| **Alerte** | Ambre (Panne en attente, warning) | `#D9A441` |
| **Fond** | Blanc cassé technique | `#F7F8FA` |
| **Texte principal** | Gris anthracite | `#1A1A1A` |
| **Texte secondaire** | Gris moyen | `#595959` |

- **Typographie** : Inter / Poppins, taille minimale 14sp pour une lisibilité optimale sur écran mobile en extérieur.
- **Badges de statut standardisés** :
  - `En attente` : Ambre (`#D9A441`)
  - `Offres reçues` : Bleu nuit (`#1F3A5F`)
  - `Prise en charge` : Orange (`#E8641C`)
  - `Terminée` : Vert (`#2E8B57`)

---

## 3. Architecture Technique Globale

```
tech_sos/
├── backend/                  # API REST NestJS avec TypeScript & Prisma ORM
│   ├── src/
│   │   ├── common/           # Filtres HTTP, Interceptors, Guards JWT / Roles
│   │   ├── config/           # Configuration environnement
│   │   ├── database/         # PrismaService et client
│   │   ├── modules/
│   │   │   ├── auth/         # Register / Login / JWT
│   │   │   ├── users/        # Profils client et fiches atelier prestataire
│   │   │   ├── categories/   # Catégories d'appareils & types de pannes
│   │   │   ├── repairs/      # Création, liste, détail, sélection d'offre
│   │   │   ├── offers/       # Propositions de prix et délais par réparateur
│   │   │   ├── reviews/      # Évaluation et calcul de note moyenne
│   │   │   ├── workshop/     # Journal d'atelier & notification WhatsApp
│   │   │   ├── subscriptions/# Abonnement réparateur & simulateur Mobile Money
│   │   │   ├── storage/      # Stockage photos et fichiers audio vocaux
│   │   │   └── notifications/# Mock WhatsApp Business API et Push FCM
│   ├── prisma/
│   │   ├── schema.prisma     # Modèle relationnel Prisma (SQLite dev / Postgres prod)
│   │   └── seed.ts           # Jeu de données d'initialisation (Bamako)
├── mobile/                   # Application Flutter (Dart, Android & iOS)
│   ├── lib/
│   │   ├── core/             # Thème, constantes couleurs, client Dio, widgets partagés
│   │   ├── features/
│   │   │   ├── auth/         # Écrans d'authentification et sélection du profil
│   │   │   ├── client/       # Accueil, publication panne, suivi de mes annonces
│   │   │   ├── provider/     # Fil de pannes, mes offres, journal atelier
│   │   │   ├── subscription/ # Écran d'abonnement & paiement Mobile Money
│   │   │   └── profile/      # Profil, historique et déconnexion
└── docs/                     # Spécifications et documentation d'architecture
```

---

## 4. Modèle de Données Prisma

```prisma
datasource db {
  provider = "sqlite" // Configuré pour SQLite en dev local immédiat, portable vers postgresql
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

enum UserRole {
  CLIENT
  PROVIDER
  ADMIN
}

enum RepairStatus {
  PENDING
  OFFERS_RECEIVED
  IN_PROGRESS
  COMPLETED
  CANCELLED
}

enum OfferStatus {
  PENDING
  ACCEPTED
  REJECTED
}

enum WorkshopStatus {
  DEPOSITED
  DIAGNOSTIC
  IN_REPAIR
  READY_FOR_PICKUP
  DELIVERED
}

enum ClientOrigin {
  FROM_APP
  WALK_IN_OFFLINE
}

enum SubscriptionStatus {
  FREE_TRIAL
  ACTIVE
  EXPIRED
}

model User {
  id           String        @id @default(uuid())
  email        String?       @unique
  phone        String        @unique
  passwordHash String
  fullName     String
  role         UserRole      @default(CLIENT)
  city         String        @default("Bamako")
  address      String?
  avatarUrl    String?
  createdAt    DateTime      @default(now())
  updatedAt    DateTime      @updatedAt

  providerProfile ProviderProfile?
  repairRequests  RepairRequest[]
  reviewsGiven    Review[]
}

model ProviderProfile {
  id                 String             @id @default(uuid())
  userId             String             @unique
  user               User               @relation(fields: [userId], references: [id], onDelete: Cascade)
  workshopName       String
  addressZone        String             // Ex: Hamdallaye ACI 2000, Badalabougou, Lafiabougou
  bio                String?
  isVerified         Boolean            @default(false)
  ratingAvg          Float              @default(5.0)
  reviewCount        Int                @default(0)
  subscriptionStatus SubscriptionStatus @default(FREE_TRIAL)
  specialtiesJson    String             @default("[]") // Liste des ID de catégories/pannes prises en charge

  offers             Offer[]
  reviewsReceived    Review[]
  workshopEntries    WorkshopEntry[]
  subscriptions      Subscription[]
}

model DeviceCategory {
  id             String          @id @default(uuid())
  name           String          @unique // Ex: Téléphone / Smartphone, Ordinateur, Imprimante
  iconName       String          @default("devices")
  sortOrder      Int             @default(0)
  createdAt      DateTime        @default(now())

  issueTypes     IssueType[]
  repairRequests RepairRequest[]
}

model IssueType {
  id             String          @id @default(uuid())
  categoryId     String
  category       DeviceCategory  @relation(fields: [categoryId], references: [id], onDelete: Cascade)
  name           String          // Ex: Écran cassé, Batterie déchargée rapidement, Connecteur de charge
  isOfficial     Boolean         @default(true) // false si soumis par un utilisateur en saisie libre
  createdAt      DateTime        @default(now())

  repairRequests RepairRequest[]
}

model RepairRequest {
  id                   String        @id @default(uuid())
  clientId             String
  client               User          @relation(fields: [clientId], references: [id], onDelete: Cascade)
  categoryId           String
  category             DeviceCategory@relation(fields: [categoryId], references: [id])
  issueTypeId          String?
  issueType            IssueType?    @relation(fields: [issueTypeId], references: [id])
  customIssueTitle     String?       // Utilisé si l'utilisateur a choisi "Autre"
  descriptionText      String
  voiceAudioUrl        String?       // URL de la note vocale enregistrée
  photoUrlsJson        String        @default("[]") // Tableau JSON des URLs de photos
  status               RepairStatus  @default(PENDING)
  locationAddress      String?
  selectedOfferId      String?
  createdAt            DateTime      @default(now())
  updatedAt            DateTime      @updatedAt

  offers               Offer[]
  review               Review?
}

model Offer {
  id                String        @id @default(uuid())
  repairRequestId   String
  repairRequest     RepairRequest @relation(fields: [repairRequestId], references: [id], onDelete: Cascade)
  providerId        String
  provider          ProviderProfile @relation(fields: [providerId], references: [id], onDelete: Cascade)
  priceCfa          Int           // Prix proposé en FCFA
  estimatedDuration String        // Ex: "2 heures", "24h", "2 jours"
  comment           String?
  status            OfferStatus   @default(PENDING)
  createdAt         DateTime      @default(now())
}

model Review {
  id              String          @id @default(uuid())
  repairRequestId String          @unique
  repairRequest   RepairRequest   @relation(fields: [repairRequestId], references: [id], onDelete: Cascade)
  clientId        String
  client          User            @relation(fields: [clientId], references: [id], onDelete: Cascade)
  providerId      String
  provider        ProviderProfile @relation(fields: [providerId], references: [id], onDelete: Cascade)
  rating          Int             // 1 à 5
  comment         String?
  createdAt       DateTime        @default(now())
}

model WorkshopEntry {
  id                     String         @id @default(uuid())
  providerId             String
  provider               ProviderProfile @relation(fields: [providerId], references: [id], onDelete: Cascade)
  origin                 ClientOrigin   @default(FROM_APP)
  clientName             String
  clientPhone            String
  deviceModel            String
  issueSummary           String
  voiceNoteUrl           String?
  status                 WorkshopStatus @default(DEPOSITED)
  priceCfa               Int?
  whatsappNotifiedAt     DateTime?
  createdAt              DateTime       @default(now())
  updatedAt              DateTime       @updatedAt
}

model Subscription {
  id              String             @id @default(uuid())
  providerId      String
  provider        ProviderProfile    @relation(fields: [providerId], references: [id], onDelete: Cascade)
  planName        String             @default("Standard Pro")
  amountCfa       Int                @default(5000)
  startDate       DateTime           @default(now())
  endDate         DateTime
  status          SubscriptionStatus @default(ACTIVE)
  paymentMethod   String             // ORANGE_MONEY ou MOOV_MONEY
  transactionRef  String             @unique
  createdAt       DateTime           @default(now())
}
```

---

## 5. Endpoints REST Principaux (NestJS)

- **Auth** :
  - `POST /api/auth/register-client` : Inscription client (nom, téléphone, mot de passe).
  - `POST /api/auth/register-provider` : Inscription réparateur (nom, atelier, quartier Bamako, spécialités).
  - `POST /api/auth/login` : Connexion unique retournant JWT et informations utilisateur avec profil.
- **Catégories & Pannes** :
  - `GET /api/categories` : Liste hiérarchique des catégories d'appareils avec leurs types de pannes associés.
  - `POST /api/categories` *(Admin)* : Création d'une catégorie.
  - `POST /api/categories/:id/issues` *(Admin)* : Ajout d'une panne officielle.
  - `GET /api/admin/pending-issues` *(Admin)* : Pannes libres soumises par des clients nécessitant validation.
- **Annonces de pannes (Repairs)** :
  - `POST /api/repairs` : Publication d'une panne (description, audio, photos, catégorie, panne).
  - `GET /api/repairs` : Liste des pannes avec filtres (statut, catégorie).
  - `GET /api/repairs/feed` *(Prestataire)* : Fil filtré automatiquement selon les spécialités du réparateur connecté.
  - `GET /api/repairs/my-requests` *(Client)* : Liste des annonces publiées par le client connecté.
  - `GET /api/repairs/:id` : Détail complet d'une annonce et de ses offres reçues.
- **Offres (Offers)** :
  - `POST /api/repairs/:id/offers` *(Prestataire)* : Soumission d'une offre (prix FCFA, délai, commentaire).
  - `POST /api/offers/:id/accept` *(Client)* : Acceptation de l'offre (change le statut de l'annonce en `IN_PROGRESS`).
- **Notation (Reviews)** :
  - `POST /api/repairs/:id/reviews` : Notation 1 à 5 étoiles et avis après achèvement de la réparation.
- **Back-Office Atelier (Workshop)** :
  - `GET /api/workshop` : Journal des entrées et sorties d'appareils de l'atelier connecté.
  - `POST /api/workshop/quick-entry` : Enregistrement rapide client physique (nom, tél, appareil, panne texte/vocal) déclenchant la notification WhatsApp.
  - `PATCH /api/workshop/:id/status` : Changement de statut (`PRÊT À RÉCUPÉRER`, etc.) avec notification WhatsApp client.
- **Abonnements & Mobile Money** :
  - `GET /api/subscriptions/current` : Statut d'abonnement du prestataire.
  - `POST /api/subscriptions/pay-mobile-money` : Simulation/déclenchement de paiement Orange Money / Moov Money (5 000 FCFA/mois) avec activation instantanée.
- **Stockage de fichiers** :
  - `POST /api/storage/upload` : Upload multipart de photos et enregistrements audio vocaux.

---

## 6. Ergonomie Mobile & Écrans Flutter

1. **Écran d'Accueil Client** :
   - Header avec logo TechSOS et sélecteur de quartier à Bamako.
   - Bannière d'action d'urgence *"Un appareil en panne ? Publiez votre SOS en 1 minute !"*.
   - Recherche par spécialité (Smartphones, Ordinateurs, Imprimantes...).
   - Liste des prestataires recommandés avec note moyenne par étoiles et badge vérifié.
2. **Écran de Publication de Panne** :
   - Sélection visuelle de la catégorie d'appareil.
   - Choix du type de panne ou option "Autre / Saisie libre".
   - **Zone mixte Texte & Vocal** : Un grand champ de description textuelle et, à son côté, le bouton d'enregistrement audio avec onde d'enregistrement, chronomètre et possibilité de réécouter/supprimer.
   - Zone d'ajout de photos de l'appareil.
   - Bouton d'action proéminent en Orange technique : *"Lancer mon SOS"*.
3. **Écran "Mes Annonces" & Comparateur d'offres** :
   - Cartes d'annonces avec badge d'état coloré.
   - Compteur d'offres reçues.
   - Écran de comparaison des devis : affichage clair du prix en FCFA, du délai et de la note du réparateur.
   - Bouton *"Accepter cette offre"*.
4. **Interface Prestataire** :
   - **Fil des pannes** : Annonces triées par pertinence et spécialité, avec bouton *"Faire une offre"*.
   - **Back-office Atelier** : Journal des réparations en cours avec filtres par statut, et bouton flottant *"Enregistrer un client atelier"* (nom, tél, note vocale rapide + confirmation d'envoi WhatsApp).
   - **Écran d'Abonnement** : Visualisation du plan actif, bouton de renouvellement Mobile Money avec choix Orange Money / Moov Money.

---

## 7. Gestion Réseau Dégradé & Mode Hors-Ligne

- **Enregistrement vocal résilient** : Le flux audio est écrit localement dans le stockage interne du smartphone avant tentative d'envoi réseau.
- **Mise en cache locale** : Les catégories et dernières annonces sont mises en cache dans le stockage de l'appareil pour affichage instantané sans blocage.
- **Gestion des erreurs en français** : Chaque échec réseau affiche une notification claire invitant à réessayer sans perte des données déjà saisies.

---

## 8. Validation et Déploiement

- **Backend** : Démarrage via `npm run start:dev`, seed de base de données Bamako via `npm run prisma:seed`, tests Jest unitaires et e2e.
- **Mobile** : Flutter 3.x, exécution Android/iOS, tests widgets pour les badges de statuts, le système de notation et l'enregistrement audio.
