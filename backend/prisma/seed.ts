import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

interface SeedCategory {
  name: string;
  iconName: string;
  sortOrder: number;
  issues: string[];
}

const BAMAKO_CATEGORIES: SeedCategory[] = [
  {
    name: 'Téléphone / Smartphone',
    iconName: 'smartphone',
    sortOrder: 1,
    issues: [
      'Écran fissuré / cassé',
      'Batterie ne tient plus la charge',
      "Ne s'allume plus",
      'Connecteur de charge défaillant',
      'Problème haut-parleur / micro',
      'Dégât liquide / oxydation',
    ],
  },
  {
    name: 'Ordinateur portable / Fixe',
    iconName: 'laptop',
    sortOrder: 2,
    issues: [
      "Écran noir / Ne s'allume pas",
      'Surchauffe / Nettoyage ventilateur',
      'Clavier ou touchpad HS',
      'Disque dur défaillant / Remplacement SSD',
      'Réinstallation système Windows/Mac',
      'Batterie HS',
    ],
  },
  {
    name: 'Imprimante / Scanner',
    iconName: 'print',
    sortOrder: 3,
    issues: [
      'Bourrage papier récurrent',
      "Problème têtes d'impression / Encre",
      "Non reconnue par l'ordinateur",
      'Alimentation électrique HS',
    ],
  },
  {
    name: 'Tablette',
    iconName: 'tablet',
    sortOrder: 4,
    issues: [
      'Vitre tactile cassée',
      'Batterie gonflée',
      'Connecteur de charge abîmé',
    ],
  },
  {
    name: 'Autre équipement électronique',
    iconName: 'devices_other',
    sortOrder: 5,
    issues: [
      'Problème alimentation',
      'Autre panne spécifique',
    ],
  },
];

export async function seed() {
  console.log('🌱 Démarrage du seed pour les catégories et pannes à Bamako...');

  for (const catData of BAMAKO_CATEGORIES) {
    const category = await prisma.deviceCategory.upsert({
      where: { name: catData.name },
      update: {
        iconName: catData.iconName,
        sortOrder: catData.sortOrder,
      },
      create: {
        name: catData.name,
        iconName: catData.iconName,
        sortOrder: catData.sortOrder,
      },
    });

    console.log(`✓ Catégorie synchronisée: ${category.name} (id: ${category.id})`);

    for (const issueName of catData.issues) {
      const existingIssue = await prisma.issueType.findFirst({
        where: {
          categoryId: category.id,
          name: issueName,
        },
      });

      if (!existingIssue) {
        await prisma.issueType.create({
          data: {
            categoryId: category.id,
            name: issueName,
            isOfficial: true,
          },
        });
        console.log(`  + Panne ajoutée: ${issueName}`);
      } else {
        // S'assurer que les pannes du seed restent officielles
        if (!existingIssue.isOfficial) {
          await prisma.issueType.update({
            where: { id: existingIssue.id },
            data: { isOfficial: true },
          });
        }
        console.log(`  = Panne existante: ${issueName}`);
      }
    }
  }

  // --- Seed des comptes de démonstration (Golden Innovation Tech) ---
  const passwordHash = await bcrypt.hash('TechSos2026!', 10);
  const adminPasswordHash = await bcrypt.hash('TechSosAdmin2026!', 10);

  // 1. Client Démo
  const demoClient = await prisma.user.upsert({
    where: { phone: '+22370000001' },
    update: { passwordHash },
    create: {
      phone: '+22370000001',
      fullName: 'Amadou Diallo',
      passwordHash,
      role: 'CLIENT',
      city: 'Bamako',
      address: 'Badalabougou, Bamako',
    },
  });
  console.log(`✓ Client Démo synchronisé: ${demoClient.fullName} (${demoClient.phone})`);

  // 2. Réparateur Démo
  const phoneCat = await prisma.deviceCategory.findUnique({
    where: { name: 'Téléphone / Smartphone' },
  });
  const laptopCat = await prisma.deviceCategory.findUnique({
    where: { name: 'Ordinateur portable / Fixe' },
  });
  const demoSpecialties = JSON.stringify([phoneCat?.id, laptopCat?.id].filter(Boolean));

  const demoProviderUser = await prisma.user.upsert({
    where: { phone: '+22376000001' },
    update: { passwordHash },
    create: {
      phone: '+22376000001',
      fullName: 'Mamadou Koné',
      passwordHash,
      role: 'PROVIDER',
      city: 'Bamako',
      address: 'Hamdallaye ACI 2000, Bamako',
    },
  });


  await prisma.providerProfile.upsert({
    where: { userId: demoProviderUser.id },
    update: {
      workshopName: 'Clinique High-Tech Bamako',
      addressZone: 'Hamdallaye ACI 2000',
      subscriptionStatus: 'ACTIVE',
      specialtiesJson: demoSpecialties,
      ratingAvg: 4.9,
      reviewCount: 12,
    },
    create: {
      userId: demoProviderUser.id,
      workshopName: 'Clinique High-Tech Bamako',
      addressZone: 'Hamdallaye ACI 2000',
      bio: 'Spécialiste micro-soudure et réparations express smartphones & ordinateurs',
      isVerified: true,
      subscriptionStatus: 'ACTIVE',
      specialtiesJson: demoSpecialties,
      ratingAvg: 4.9,
      reviewCount: 12,
    },
  });
  console.log(`✓ Réparateur Démo synchronisé: Mamadou Koné (+22376000001)`);

  // 3. Administrateur Démo
  const demoAdmin = await prisma.user.upsert({
    where: { phone: '+22370000000' },
    update: {},
    create: {
      phone: '+22370000000',
      fullName: 'Administrateur TechSOS',
      passwordHash: adminPasswordHash,
      role: 'ADMIN',
      city: 'Bamako',
      address: 'Siège Golden Innovation Tech, Bamako',
    },
  });
  console.log(`✓ Admin Démo synchronisé: ${demoAdmin.fullName} (${demoAdmin.phone})`);

  // 4. Données de démonstration : Pannes SOS et Devis / Offres pour Bamako
  const screenIssue = await prisma.issueType.findFirst({
    where: { name: 'Écran fissuré / cassé', categoryId: phoneCat?.id },
  });
  const overheatIssue = await prisma.issueType.findFirst({
    where: { name: 'Surchauffe / Nettoyage ventilateur', categoryId: laptopCat?.id },
  });
  const chargeIssue = await prisma.issueType.findFirst({
    where: { name: 'Connecteur de charge défaillant', categoryId: phoneCat?.id },
  });
  const providerProfile = await prisma.providerProfile.findUnique({
    where: { userId: demoProviderUser.id },
  });

  if (providerProfile && screenIssue && overheatIssue && chargeIssue) {
    // Demande 1 : iPhone 11 - Offre en attente
    const repair1 = await prisma.repairRequest.upsert({
      where: { id: 'demo-repair-iphone-11' },
      update: {},
      create: {
        id: 'demo-repair-iphone-11',
        clientId: demoClient.id,
        categoryId: phoneCat!.id,
        issueTypeId: screenIssue.id,
        customIssueTitle: 'iPhone 11 - Écran fissuré après chute',
        descriptionText: 'Vitre brisée mais le tactile fonctionne encore. Besoin d un remplacement rapide avant demain midi.',
        locationAddress: 'Badalabougou, Rue 14',
        status: 'PENDING',
      },
    });

    await prisma.offer.upsert({
      where: { id: 'demo-offer-screen-15000' },
      update: {},
      create: {
        id: 'demo-offer-screen-15000',
        repairRequestId: repair1.id,
        providerId: providerProfile.id,
        priceCfa: 15000,
        estimatedDuration: '2h',
        comment: 'Écran original disponible en stock à notre atelier ACI 2000. Réparation garantie 3 mois.',
        status: 'PENDING',
      },
    });

    // Demande 2 : HP Pavilion 15 - Offre acceptée par le client
    const repair2 = await prisma.repairRequest.upsert({
      where: { id: 'demo-repair-hp-pavilion' },
      update: {},
      create: {
        id: 'demo-repair-hp-pavilion',
        clientId: demoClient.id,
        categoryId: laptopCat!.id,
        issueTypeId: overheatIssue.id,
        customIssueTitle: 'HP Pavilion 15 - Surchauffe et arrêt inopiné',
        descriptionText: 'Le ventilateur fait un bruit très fort et le PC coupe brutalement après 15 minutes d utilisation.',
        locationAddress: 'Hamdallaye ACI 2000',
        status: 'IN_PROGRESS',
        selectedOfferId: 'demo-offer-hp-25000',
      },
    });

    await prisma.offer.upsert({
      where: { id: 'demo-offer-hp-25000' },
      update: {},
      create: {
        id: 'demo-offer-hp-25000',
        repairRequestId: repair2.id,
        providerId: providerProfile.id,
        priceCfa: 25000,
        estimatedDuration: '24h',
        comment: 'Démontage intégral, dépoussiérage compresseur et remplacement pâte thermique haute conductivité.',
        status: 'ACCEPTED',
      },
    });

    // Demande 3 : Samsung A52 - En attente dans le fil des pannes
    await prisma.repairRequest.upsert({
      where: { id: 'demo-repair-samsung-a52' },
      update: {},
      create: {
        id: 'demo-repair-samsung-a52',
        clientId: demoClient.id,
        categoryId: phoneCat!.id,
        issueTypeId: chargeIssue.id,
        customIssueTitle: 'Samsung Galaxy A52 - Ne charge plus',
        descriptionText: 'Le câble doit être tordu pour charger. Problème au niveau du connecteur USB-C.',
        locationAddress: 'Lafiabougou, près du marché',
        status: 'PENDING',
      },
    });

    // 5. Journal d atelier (Back-Office)
    await prisma.workshopEntry.upsert({
      where: { id: 'demo-workshop-macbook' },
      update: {},
      create: {
        id: 'demo-workshop-macbook',
        providerId: providerProfile.id,
        origin: 'WALK_IN_OFFLINE',
        clientName: 'Ousmane Traoré',
        clientPhone: '+22372000001',
        deviceModel: 'Apple MacBook Pro M1 2020',
        issueSummary: 'Clavier bloqué suite projection de thé, diagnostic carte mère requis',
        priceCfa: 45000,
        status: 'IN_REPAIR',
      },
    });

    await prisma.workshopEntry.upsert({
      where: { id: 'demo-workshop-tecno' },
      update: {},
      create: {
        id: 'demo-workshop-tecno',
        providerId: providerProfile.id,
        origin: 'WALK_IN_OFFLINE',
        clientName: 'Awa Sangaré',
        clientPhone: '+22378000002',
        deviceModel: 'Tecno Camon 20 Premier',
        issueSummary: 'Changement vitre arrière et test micro',
        priceCfa: 12000,
        status: 'READY_FOR_PICKUP',
      },
    });

    console.log('✓ Données démo synchronisées (Offres, Pannes SOS & Journal d atelier)');
  }

  console.log('✨ Seed des catégories, pannes et comptes démo de Bamako terminé avec succès !');
}

if (require.main === module) {
  seed()
    .catch((error) => {
      console.error('❌ Erreur lors du seed :', error);
      process.exit(1);
    })
    .finally(async () => {
      await prisma.$disconnect();
    });
}
