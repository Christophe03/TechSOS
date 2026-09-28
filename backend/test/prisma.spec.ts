import { Test, TestingModule } from '@nestjs/testing';
import { PrismaService } from '../src/database/prisma.service';

describe('PrismaService (Intégration SQLite)', () => {
  let prisma: PrismaService;
  let module: TestingModule;

  beforeAll(async () => {
    module = await Test.createTestingModule({
      providers: [PrismaService],
    }).compile();

    prisma = module.get<PrismaService>(PrismaService);
    await prisma.$connect();
  });

  afterAll(async () => {
    await prisma.$disconnect();
    await module.close();
  });

  it('doit être défini et connecté à SQLite', () => {
    expect(prisma).toBeDefined();
  });

  it('doit pouvoir créer, lire et supprimer une catégorie d’appareil de test', async () => {
    const testCategoryName = `Test_Category_${Date.now()}`;

    // 1. Création d'une catégorie
    const created = await prisma.deviceCategory.create({
      data: {
        name: testCategoryName,
        iconName: 'smartphone',
        sortOrder: 1,
      },
    });

    expect(created).toBeDefined();
    expect(created.id).toBeDefined();
    expect(created.name).toBe(testCategoryName);
    expect(created.iconName).toBe('smartphone');
    expect(created.sortOrder).toBe(1);

    // 2. Lecture / Recherche
    const found = await prisma.deviceCategory.findUnique({
      where: { id: created.id },
    });

    expect(found).not.toBeNull();
    expect(found?.id).toBe(created.id);
    expect(found?.name).toBe(testCategoryName);

    // 3. Suppression
    const deleted = await prisma.deviceCategory.delete({
      where: { id: created.id },
    });

    expect(deleted.id).toBe(created.id);

    // 4. Vérification de la suppression effective
    const verify = await prisma.deviceCategory.findUnique({
      where: { id: created.id },
    });
    expect(verify).toBeNull();
  });
});
