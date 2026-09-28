import { Injectable, BadRequestException } from '@nestjs/common';
import { existsSync, mkdirSync, writeFileSync } from 'fs';
import { join, extname } from 'path';
import { randomUUID } from 'crypto';

export interface UploadedFileResponse {
  url: string;
  filename: string;
  mimetype: string;
  size: number;
}

@Injectable()
export class StorageService {
  private readonly uploadsDir = join(process.cwd(), 'uploads');

  constructor() {
    if (!existsSync(this.uploadsDir)) {
      mkdirSync(this.uploadsDir, { recursive: true });
    }
  }

  async saveFile(file: Express.Multer.File): Promise<UploadedFileResponse> {
    if (!file) {
      throw new BadRequestException('Aucun fichier fourni');
    }

    let filename: string;
    if (file.filename) {
      filename = file.filename;
    } else if (file.buffer) {
      const ext = extname(file.originalname).toLowerCase();
      filename = `${randomUUID()}${ext}`;
      const filePath = join(this.uploadsDir, filename);
      writeFileSync(filePath, file.buffer);
    } else {
      throw new BadRequestException('Fichier invalide');
    }

    return {
      url: `/uploads/${filename}`,
      filename,
      mimetype: file.mimetype,
      size: file.size,
    };
  }
}
