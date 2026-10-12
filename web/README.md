# TechSOS — Web App (Next.js 15)

Plateforme web officielle de **TechSOS**, développée pour le district de **Bamako, Mali**.

---

## 🚀 Fonctionnalités Clés

1. **Vitrine & Landing Page Haute Conversion** :
   - Hero d'urgence avec call-to-action immédiat (*"SOS Panne Express"*).
   - Sélecteur d'équipements (Smartphones, Ordinateurs, Imprimantes, Électronique).
   - Annuaire des réparateurs par commune et quartier (ACI 2000, Badalabougou, Lafiabougou, Médina Coura, etc.).
   - Grille tarifaire indicative moyenne en **FCFA**.

2. **Espace Client (SOS Panne & Suivi)** :
   - Déclaration de panne avec **enregistrement vocal natif (Web Audio API)** et upload de photos.
   - Suivi en temps réel des demandes publiées (`/mes-demandes`).
   - Comparateur d'offres reçues (prix ferme en FCFA, délai d'intervention, réputation étoiles).
   - Acceptation d'offre en 1 clic et dépôt d'avis 5 étoiles à la clôture.

3. **Portail Pro Réparateurs & Ateliers (Dashboard Pro)** :
   - Tableau de bord avec indicateurs de performance et volume d'atelier.
   - Fil d'opportunités en temps réel (`/atelier/fil-urgences`) avec soumission de devis chiffrés.
   - **Journal d'Atelier de Comptoir (`/atelier/journal`)** avec saisie ultra-rapide (*Quick Entry*) des clients physiques.
   - **Bouton WhatsApp transactionnel (`wa.me`)** : notification instantanée pré-remplie au client au dépôt et lorsque l'appareil est prêt.
   - Abonnement Pro à 5 000 FCFA/mois avec simulation Orange Money et Moov Money Mali.

---

## 🛠 Stack Technique

- **Framework** : Next.js 15 (App Router)
- **UI Library** : React 19, Tailwind CSS v3
- **Icônes** : Lucide React
- **Client HTTP** : Axios (connecté à l'API NestJS sur `http://localhost:3000/api`)
- **Audio** : Native HTML5 MediaStream & Web Audio API
- **Port par défaut** : `3001`

---

## 💻 Démarrage Rapide

Dans le répertoire `web/` :

```bash
# Installation des dépendances
npm install

# Lancement du serveur de développement (sur le port 3001)
npm run dev

# Build de production
npm run build

# Démarrage du serveur de production
npm run start
```

L'application est alors accessible sur : **`http://localhost:3001`**.

---

## 👤 Comptes de Démonstration (Bamako)

- **Client Démo** :
  - Téléphone : `+223 70 00 00 01`
  - Mot de passe : `Password123!`
- **Réparateur / Atelier Démo** :
  - Téléphone : `+223 70 00 00 02`
  - Mot de passe : `Password123!`
