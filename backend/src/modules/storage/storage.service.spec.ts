import { Test, TestingModule } from '@nestjs/testing';
import { StorageService } from './storage.service';
import { BadRequestException } from '@nestjs/common';
import * as fs from 'fs';

describe('StorageService', () => {
  let service: StorageService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [StorageService],
    }).compile();

    service = module.get<StorageService>(StorageService);
  });

  it('doit être défini', () => {
    expect(service).toBeDefined();
  });

  it('doit lever BadRequestException si aucun fichier n est fourni', async () => {
    await expect(service.saveFile(null as any)).rejects.toThrow(
      BadRequestException,
    );
  });

  it('doit retourner les métadonnées si le fichier a déjà été stocké par multer diskStorage', async () => {
    const mockFile: Partial<Express.Multer.File> = {
      filename: 'test-uuid-1234.png',
      mimetype: 'image/png',
      size: 1024,
    };

    const result = await service.saveFile(mockFile as Express.Multer.File);

    expect(result).toEqual({
      url: '/uploads/test-uuid-1234.png',
      filename: 'test-uuid-1234.png',
      mimetype: 'image/png',
      size: 1024,
    });
  });

  it('doit enregistrer un buffer si file.filename est absent', async () => {
    const writeSpy = jest.spyOn(fs, 'writeFileSync').mockImplementation(() => {});

    const mockFile: Partial<Express.Multer.File> = {
      originalname: 'audio-note.m4a',
      buffer: Buffer.from('fake-audio-content'),
      mimetype: 'audio/x-m4a',
      size: 512,
    };

    const result = await service.saveFile(mockFile as Express.Multer.File);

    expect(writeSpy).toHaveBeenCalled();
    expect(result.url).toMatch(/^\/uploads\/[0-9a-f-]+\.m4a$/);
    expect(result.filename).toMatch(/^[0-9a-f-]+\.m4a$/);
    expect(result.mimetype).toBe('audio/x-m4a');
    expect(result.size).toBe(512);

    writeSpy.mockRestore();
  });
});
