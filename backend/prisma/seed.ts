import { PrismaClient } from '@prisma/client';

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

  console.log('✨ Seed des catégories et pannes de Bamako terminé avec succès !');
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
