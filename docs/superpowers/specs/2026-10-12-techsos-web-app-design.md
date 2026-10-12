# Spécification Technique et Fonctionnelle — Web App TechSOS

**Date** : 12 Octobre 2026  
**Éditeur** : Golden Innovation Tech (Bamako, Mali)  
**Application** : TechSOS Web Platform (Next.js 15, React 19, TypeScript, Tailwind CSS)  
**Statut** : Validé pour implémentation  

---

## 1. Contexte & Objectifs

TechSOS dispose d'une API backend NestJS opérationnelle et d'une application mobile Flutter. La présente spécification cadre le développement d'une **Web App professionnelle, moderne et responsive** pour :
1. **Offrir une vitrine d'urgence publique de haute réassurance** pour les particuliers et entreprises de Bamako recherchant un dépannage express.
2. **Fournir un espace client web complet** : déclaration express de panne (avec enregistrement vocal Web Audio et upload de photos), suivi des réparations et acceptation des devis en FCFA.
3. **Fournir un portail atelier professionnel ("Dashboard Pro Atelier")** adapté aux grands écrans pour les réparateurs : fil de pannes en temps réel, émission d'offres, journal d'atelier physique de comptoir (*Quick Entry*) avec relance WhatsApp instantanée, et gestion de l'abonnement mensuel (Orange Money / Moov Money).

---

## 2. Charte Graphique & Identité Visuelle

| Rôle | Token | Code HEX | Usage |
|---|---|---|---|
| **Bleu Nuit Principal** | `techsos-primary` | `#1F3A5F` | En-têtes, navigation, structure, cartes clés |
| **Orange Technique** | `techsos-accent` | `#E8641C` | Call-to-action d'urgence, badges SOS, boutons principaux |
| **Vert Succès** | `techsos-success` | `#2E8B57` | Réparations terminées, devis acceptés, validation |
| **Ambre Alerte** | `techsos-alert` | `#D9A441` | Pannes en attente, alertes de délai |
| **Fond Technique** | `techsos-bg` | `#F8FAFC` | Arrière-plan de l'application |
| **Fond Sombre** | `techsos-dark` | `#0F172A` | Hero sections contrastées, footer, mode sombre |
| **Texte Principal** | `techsos-text-primary` | `#1A1A1A` | Typographie principale |
| **Texte Secondaire** | `techsos-text-muted` | `#64748B` | Sous-titres, métadonnées |

- **Typographie** : `Plus Jakarta Sans` ou `Inter`, haute lisibilité.
- **Micro-interactions** : États de survol soignés, visualiseur d'onde audio en temps réel pour la note vocale, transitions fluides.

---

## 3. Architecture Technique du Projet (`web/`)

L'application Web réside dans le sous-dossier `web/` à la racine du projet :

```
tech_sos/
├── backend/          # NestJS REST API (port 3000)
├── mobile/           # Flutter Mobile App
└── web/              # Next.js 15 App Router (port 3001)
    ├── public/
    │   ├── icons/
    │   └── logo.svg
    ├── src/
    │   ├── app/
    │   │   ├── layout.tsx
    │   │   ├── page.tsx
    │   │   ├── (auth)/
    │   │   │   ├── connexion/page.tsx
    │   │   │   └── inscription/page.tsx
    │   │   ├── (client)/
    │   │   │   ├── sos-panne/page.tsx
    │   │   │   ├── mes-demandes/page.tsx
    │   │   │   └── demandes/[id]/page.tsx
    │   │   └── (atelier)/
    │   │       ├── dashboard/page.tsx
    │   │       ├── fil-urgences/page.tsx
    │   │       ├── journal/page.tsx
    │   │       └── abonnement/page.tsx
    │   ├── components/
    │   │   ├── layout/ (Navbar, Footer, SidebarAtelier)
    │   │   ├── ui/ (Button, Card, Badge, Modal, Tabs)
    │   │   ├── audio/ (WebAudioRecorder, AudioPlayer)
    │   │   └── workshop/ (QuickClientEntryModal, WhatsAppButton)
    │   └── lib/
    │       ├── api/ (client Axios/fetch typé vers http://localhost:3000/api)
    │       ├── auth/ (AuthContext, token persistence)
    │       └── types/
```

---

## 4. Fonctionnalités Détaillées

### 4.1. Landing Page Vitrine
- **Hero d'urgence** avec CTA double (*"Déclarer une panne en direct"* / *"Rejoindre comme réparateur certifié"*).
- **Statistiques en direct** : +50 ateliers partenaires à Bamako, délai moyen de réponse < 15 min, note moyenne de 4.8/5.
- **Sélecteur de matériel** interactif : Smartphones, PC / Mac, Imprimantes & Bureautique, Téléviseurs & Audio.
- **Réassurance locale** : Couverture des 6 communes du district de Bamako.

### 4.2. Espace Client (Déclaration & Suivi SOS)
- **Formulaire SOS Panne** :
  - Choix de catégorie et modèle.
  - Enregistreur vocal Web Audio intégré (enregistrement de note vocale avec pré-écoute et réenregistrement).
  - Téléversement de photos avec prévisualisation.
  - Sélection du quartier à Bamako.
- **Tableau de bord Client** :
  - Liste des pannes avec badges de statut (`En attente`, `Offres reçues`, `Prise en charge`, `Terminée`).
  - Comparateur de devis : prix en FCFA, délai d'intervention, profil et note du réparateur.
  - Action d'acceptation de devis en 1 clic.
  - Clôture et dépôt d'avis (1 à 5 étoiles).

### 4.3. Portail Pro Atelier & Comptoir
- **Fil d'urgence en direct** : Visualisation des pannes publiées filtrées par spécialité, possibilité de soumettre un devis chiffré (prix FCFA + délai estimé).
- **Journal d'Atelier Comptoir ("Quick Entry")** :
  - Prise en charge d'un client physique au comptoir en 30 secondes.
  - Déclenchement automatique de notifications WhatsApp via lien direct `wa.me/` avec message pré-formaté.
  - Mise à jour du statut : `RECEPTIONNE` -> `DIAGNOSTIC` -> `EN_REPARATION` -> `PRET_RECUPERATION` -> `LIVRE`.
- **Abonnement Pro** : Suivi de l'abonnement mensuel (5 000 FCFA) et simulateur de validation Orange Money & Moov Money.

---

## 5. Intégration API NestJS

L'application Web consomme directement les routes REST existantes du backend :
- `POST /api/auth/login`
- `POST /api/auth/register-client`
- `POST /api/auth/register-provider`
- `GET /api/categories`
- `GET /api/repairs`, `POST /api/repairs` (Multipart)
- `POST /api/offers`, `POST /api/offers/:id/accept`
- `POST /api/reviews`
- `GET /api/workshop`, `POST /api/workshop/quick-entry`, `PATCH /api/workshop/:id/status`
- `GET /api/subscriptions/status`, `POST /api/subscriptions/subscribe`

---

## 6. Critères d'Acceptation & Qualité

1. **Responsiveness** : Fluidité totale sur mobile (360px+), tablette et écran large (1920px+).
2. **Accessibilité & Design** : Respect des contrastes WCAG AA, typographie nette, composants interactifs avec retours visuels immédiats.
3. **Audio Web** : Enregistrement micro fonctionnel sur Chrome, Edge, Firefox, Safari.
4. **Performance** : Temps de chargement initial < 1.5s, rendu côté serveur des pages publiques.
