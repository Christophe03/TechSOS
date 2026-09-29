import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/database/prisma.service';
import { seed } from '../prisma/seed';

describe('Workflow E2E Intégration Complète TechSOS (Bamako)', () => {
  let app: INestApplication;
  let prisma: PrismaService;

  // Variables partagées tout au long du cycle de vie E2E
  let categoryId: string;
  let issueTypeId: string;
  let clientToken: string;
  let clientId: string;
  let providerToken: string;
  let providerProfileId: string;
  let uploadedVoiceUrl: string;
  let repairId: string;
  let offerId: string;
  let workshopEntryId: string;

  // Numéros de téléphone dédiés au test E2E pour nettoyage idempotent
  const TEST_CLIENT_PHONE = '+22370001122';
  const TEST_PROVIDER_PHONE = '+22376003344';
  const TEST_WALKIN_PHONE = '+22378990011';

  async function cleanupTestData() {
    // 1. Suppression des fiches d'atelier créées pour le client physique
    await prisma.workshopEntry.deleteMany({
      where: { clientPhone: TEST_WALKIN_PHONE },
    });

    // 2. Nettoyage des utilisateurs de test (client & réparateur) et de leurs relations en cascade
    const testUsers = await prisma.user.findMany({
      where: {
        phone: { in: [TEST_CLIENT_PHONE, TEST_PROVIDER_PHONE] },
      },
      include: {
        providerProfile: true,
      },
    });

    for (const user of testUsers) {
      if (user.providerProfile) {
        await prisma.workshopEntry.deleteMany({
          where: { providerId: user.providerProfile.id },
        });
        await prisma.subscription.deleteMany({
          where: { providerId: user.providerProfile.id },
        });
        await prisma.offer.deleteMany({
          where: { providerId: user.providerProfile.id },
        });
        await prisma.review.deleteMany({
          where: { providerId: user.providerProfile.id },
        });
        await prisma.providerProfile.delete({
          where: { id: user.providerProfile.id },
        });
      }

      await prisma.review.deleteMany({ where: { clientId: user.id } });
      await prisma.repairRequest.deleteMany({ where: { clientId: user.id } });
      await prisma.user.delete({ where: { id: user.id } });
    }
  }

  beforeAll(async () => {
    // Initialisation du module de test NestJS
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api');
    app.useGlobalPipes(
      new ValidationPipe({
        transform: true,
        whitelist: true,
        forbidNonWhitelisted: false,
      }),
    );

    await app.init();
    prisma = app.get<PrismaService>(PrismaService);

    // Initialisation du seed des catégories & nettoyage préalable
    await seed();
    await cleanupTestData();
  }, 35000);

  afterAll(async () => {
    await cleanupTestData();
    if (app) {
      await app.close();
    }
  });

  // --------------------------------------------------------------------------
  // Étape 1 : Récupération et vérification des catégories et types de pannes
  // --------------------------------------------------------------------------
  it('Étape 1 : doit récupérer le référentiel des catégories et des pannes (GET /api/categories)', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/categories')
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThan(0);

    // Recherche de la catégorie Smartphone / Téléphone
    const phoneCategory = res.body.find((cat: any) =>
      cat.name.includes('Téléphone'),
    );
    expect(phoneCategory).toBeDefined();
    expect(phoneCategory.id).toBeDefined();
    expect(Array.isArray(phoneCategory.issueTypes)).toBe(true);
    expect(phoneCategory.issueTypes.length).toBeGreaterThan(0);

    categoryId = phoneCategory.id;

    // Sélection d'une panne typique d'écran
    const screenIssue = phoneCategory.issueTypes.find((issue: any) =>
      issue.name.includes('Écran'),
    );
    expect(screenIssue).toBeDefined();
    issueTypeId = screenIssue.id;
  });

  // --------------------------------------------------------------------------
  // Étape 2 : Inscription du client Amadou Diallo à Bamako
  // --------------------------------------------------------------------------
  it('Étape 2 : doit inscrire un nouveau client (POST /api/auth/register-client)', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/auth/register-client')
      .send({
        phone: TEST_CLIENT_PHONE,
        fullName: 'Amadou Diallo',
        password: 'password123',
        city: 'Bamako',
        address: 'Hamdallaye ACI 2000, Bamako',
      })
      .expect(201);

    expect(res.body.access_token).toBeDefined();
    expect(res.body.user).toBeDefined();
    expect(res.body.user.phone).toBe(TEST_CLIENT_PHONE);
    expect(res.body.user.fullName).toBe('Amadou Diallo');
    expect(res.body.user.role).toBe('CLIENT');
    expect(res.body.user.city).toBe('Bamako');

    clientToken = res.body.access_token;
    clientId = res.body.user.id;
  });

  // --------------------------------------------------------------------------
  // Étape 3 : Inscription du réparateur professionnel Clinique du Smartphone Bamako
  // --------------------------------------------------------------------------
  it('Étape 3 : doit inscrire un nouveau réparateur atelier (POST /api/auth/register-provider)', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/auth/register-provider')
      .send({
        phone: TEST_PROVIDER_PHONE,
        fullName: 'Mamadou Traoré',
        password: 'password123',
        workshopName: 'Clinique du Smartphone Bamako',
        addressZone: 'Hamdallaye ACI 2000',
        specialties: [categoryId],
      })
      .expect(201);

    expect(res.body.access_token).toBeDefined();
    expect(res.body.user).toBeDefined();
    expect(res.body.user.role).toBe('PROVIDER');
    expect(res.body.user.providerProfile).toBeDefined();
    expect(res.body.user.providerProfile.workshopName).toBe(
      'Clinique du Smartphone Bamako',
    );
    expect(res.body.user.providerProfile.addressZone).toBe(
      'Hamdallaye ACI 2000',
    );

    providerToken = res.body.access_token;
    providerProfileId = res.body.user.providerProfile.id;
  });

  // --------------------------------------------------------------------------
  // Étape 4 : Téléversement d'un média (note vocale m4a / photo)
  // --------------------------------------------------------------------------
  it('Étape 4 : doit téléverser un fichier audio/média (POST /api/storage/upload)', async () => {
    const audioDummyBuffer = Buffer.from('RIFF_SIMULATED_AUDIO_PAYLOAD_TEST');

    const res = await request(app.getHttpServer())
      .post('/api/storage/upload')
      .attach('file', audioDummyBuffer, 'test-voice.m4a')
      .expect(201);

    expect(res.body.url).toBeDefined();
    expect(res.body.url).toMatch(/^\/uploads\//);
    expect(res.body.filename).toBeDefined();

    uploadedVoiceUrl = res.body.url;
  });

  // --------------------------------------------------------------------------
  // Étape 5 : Publication d'une annonce de dépannage SOS par le client
  // --------------------------------------------------------------------------
  it('Étape 5 : le client publie une demande de réparation SOS (POST /api/repairs)', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/repairs')
      .set('Authorization', `Bearer ${clientToken}`)
      .send({
        categoryId,
        issueTypeId,
        descriptionText: 'Écran fissuré suite à une chute',
        voiceAudioUrl: uploadedVoiceUrl || '/uploads/test-voice.m4a',
        locationAddress: 'Hamdallaye ACI 2000, Bamako',
      })
      .expect(201);

    expect(res.body.id).toBeDefined();
    expect(res.body.status).toBe('PENDING');
    expect(res.body.descriptionText).toBe('Écran fissuré suite à une chute');
    expect(res.body.clientId).toBe(clientId);

    repairId = res.body.id;
  });

  // --------------------------------------------------------------------------
  // Étape 6 : Consultation du fil des opportunités (feed) par le réparateur
  // --------------------------------------------------------------------------
  it('Étape 6 : le réparateur consulte son feed et identifie la nouvelle panne (GET /api/repairs/feed)', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/repairs/feed')
      .set('Authorization', `Bearer ${providerToken}`)
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
    const published = res.body.find((item: any) => item.id === repairId);
    expect(published).toBeDefined();
    expect(published.descriptionText).toBe('Écran fissuré suite à une chute');
    expect(published.category?.name).toBeDefined();
  });

  // --------------------------------------------------------------------------
  // Étape 7 : Soumission d'un devis chiffré par le réparateur
  // --------------------------------------------------------------------------
  it('Étape 7 : le réparateur soumet un devis de 25 000 FCFA sous 2 heures (POST /api/repairs/:id/offers)', async () => {
    const res = await request(app.getHttpServer())
      .post(`/api/repairs/${repairId}/offers`)
      .set('Authorization', `Bearer ${providerToken}`)
      .send({
        priceCfa: 25000,
        estimatedDuration: '2 heures',
        comment: 'Remplacement écran tactile original avec garantie pièces et main d’œuvre',
      })
      .expect(201);

    expect(res.body.id).toBeDefined();
    expect(res.body.repairRequestId).toBe(repairId);
    expect(res.body.priceCfa).toBe(25000);
    expect(res.body.estimatedDuration).toBe('2 heures');
    expect(res.body.status).toBe('PENDING');

    offerId = res.body.id;
  });

  // --------------------------------------------------------------------------
  // Étape 8 : Consultation des offres et acceptation par le client
  // --------------------------------------------------------------------------
  it('Étape 8 : le client consulte l’offre et l’accepte -> passage à IN_PROGRESS (POST /api/offers/:offerId/accept)', async () => {
    // Vérification de la visibilité de l'offre
    const detailRes = await request(app.getHttpServer())
      .get(`/api/repairs/${repairId}`)
      .set('Authorization', `Bearer ${clientToken}`)
      .expect(200);

    expect(detailRes.body.offers).toBeDefined();
    expect(detailRes.body.offers.length).toBeGreaterThanOrEqual(1);

    // Acceptation de l'offre par le client
    const acceptRes = await request(app.getHttpServer())
      .post(`/api/offers/${offerId}/accept`)
      .set('Authorization', `Bearer ${clientToken}`)
      .expect(201);

    expect(acceptRes.body.id).toBe(repairId);
    expect(acceptRes.body.status).toBe('IN_PROGRESS');
    expect(acceptRes.body.selectedOfferId).toBe(offerId);

    const acceptedOffer = acceptRes.body.offers?.find(
      (o: any) => o.id === offerId,
    );
    expect(acceptedOffer).toBeDefined();
    expect(acceptedOffer.status).toBe('ACCEPTED');

    // Vérification de la mise à jour de la demande de réparation
    const updatedRepairRes = await request(app.getHttpServer())
      .get(`/api/repairs/${repairId}`)
      .set('Authorization', `Bearer ${clientToken}`)
      .expect(200);

    expect(updatedRepairRes.body.status).toBe('IN_PROGRESS');
  });

  // --------------------------------------------------------------------------
  // Étape 9 : Clôture de la réparation (statut COMPLETED)
  // --------------------------------------------------------------------------
  it('Étape 9 : la réparation est marquée comme terminée (POST /api/repairs/:id/complete)', async () => {
    const res = await request(app.getHttpServer())
      .post(`/api/repairs/${repairId}/complete`)
      .set('Authorization', `Bearer ${clientToken}`)
      .expect(201);

    expect(res.body.status).toBe('COMPLETED');
  });

  // --------------------------------------------------------------------------
  // Étape 10 : Évaluation 5 étoiles et mise à jour de la réputation du réparateur
  // --------------------------------------------------------------------------
  it('Étape 10 : le client laisse un avis 5 étoiles et vérifie la note moyenne (POST /api/repairs/:id/reviews)', async () => {
    const reviewRes = await request(app.getHttpServer())
      .post(`/api/repairs/${repairId}/reviews`)
      .set('Authorization', `Bearer ${clientToken}`)
      .send({
        rating: 5,
        comment: 'Réparation impeccable et rapide !',
      })
      .expect(201);

    expect(reviewRes.body.id).toBeDefined();
    expect(reviewRes.body.rating).toBe(5);
    expect(reviewRes.body.comment).toBe('Réparation impeccable et rapide !');

    // Vérification de la note moyenne mise à jour sur le profil du réparateur
    const providerMeRes = await request(app.getHttpServer())
      .get('/api/users/me')
      .set('Authorization', `Bearer ${providerToken}`)
      .expect(200);

    expect(providerMeRes.body.providerProfile).toBeDefined();
    expect(providerMeRes.body.providerProfile.ratingAvg).toBe(5);
    expect(providerMeRes.body.providerProfile.reviewCount).toBeGreaterThanOrEqual(1);
  });

  // --------------------------------------------------------------------------
  // Étape 11 : Enregistrement d’un client physique à l’atelier (Quick Entry)
  // --------------------------------------------------------------------------
  it('Étape 11 : le réparateur enregistre un client atelier avec alerte WhatsApp (POST /api/workshop/quick-entry)', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/workshop/quick-entry')
      .set('Authorization', `Bearer ${providerToken}`)
      .send({
        clientName: 'Fatoumata Traoré',
        clientPhone: TEST_WALKIN_PHONE,
        deviceModel: 'HP EliteBook 840',
        issueSummary: 'Clavier bloqué',
        priceCfa: 15000,
      })
      .expect(201);

    expect(res.body.id).toBeDefined();
    expect(res.body.clientName).toBe('Fatoumata Traoré');
    expect(res.body.deviceModel).toBe('HP EliteBook 840');
    expect(res.body.status).toBe('DEPOSITED');
    expect(res.body.whatsappNotifiedAt).toBeDefined();
    expect(res.body.whatsappNotifiedAt).not.toBeNull();

    workshopEntryId = res.body.id;
  });

  // --------------------------------------------------------------------------
  // Étape 12 : Mise à jour du statut atelier à READY_FOR_PICKUP avec notification WhatsApp
  // --------------------------------------------------------------------------
  it('Étape 12 : le réparateur passe l’appareil à READY_FOR_PICKUP (PATCH /api/workshop/:id/status)', async () => {
    const res = await request(app.getHttpServer())
      .patch(`/api/workshop/${workshopEntryId}/status`)
      .set('Authorization', `Bearer ${providerToken}`)
      .send({
        status: 'READY_FOR_PICKUP',
      })
      .expect(200);

    expect(res.body.status).toBe('READY_FOR_PICKUP');
    expect(res.body.whatsappNotifiedAt).toBeDefined();
    expect(res.body.whatsappNotifiedAt).not.toBeNull();
  });

  // --------------------------------------------------------------------------
  // Étape 13 : Réabonnement Orange Money 5 000 FCFA et passage au statut ACTIVE
  // --------------------------------------------------------------------------
  it('Étape 13 : le réparateur souscrit par Orange Money à 5 000 FCFA (POST /api/subscriptions/pay-mobile-money)', async () => {
    const res = await request(app.getHttpServer())
      .post('/api/subscriptions/pay-mobile-money')
      .set('Authorization', `Bearer ${providerToken}`)
      .send({
        phoneNumber: TEST_PROVIDER_PHONE,
        paymentMethod: 'ORANGE_MONEY',
      })
      .expect(201);

    expect(res.body.success).toBe(true);
    expect(res.body.subscription).toBeDefined();
    expect(res.body.subscription.status).toBe('ACTIVE');
    expect(res.body.subscription.amountCfa).toBe(5000);
    expect(res.body.transactionRef).toMatch(/^TECHSOS-OM-/);

    // Vérification du statut courant de l'abonnement
    const currentSubRes = await request(app.getHttpServer())
      .get('/api/subscriptions/current')
      .set('Authorization', `Bearer ${providerToken}`)
      .expect(200);

    expect(currentSubRes.body.status).toBe('ACTIVE');
    expect(currentSubRes.body.subscriptionStatus).toBe('ACTIVE');
    expect(currentSubRes.body.amountCfa).toBe(5000);
  });
});
