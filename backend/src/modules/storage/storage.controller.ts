import {
  Controller,
  Post,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import { existsSync, mkdirSync } from 'fs';
import { randomUUID } from 'crypto';
import { StorageService } from './storage.service';

const multerOptions = {
  storage: diskStorage({
    destination: (req, file, cb) => {
      const uploadPath = join(process.cwd(), 'uploads');
      if (!existsSync(uploadPath)) {
        mkdirSync(uploadPath, { recursive: true });
      }
      cb(null, uploadPath);
    },
    filename: (req, file, cb) => {
      const ext = extname(file.originalname).toLowerCase();
      cb(null, `${randomUUID()}${ext}`);
    },
  }),
  fileFilter: (req: any, file: any, cb: any) => {
    const allowedExts = [
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.m4a',
      '.mp3',
      '.aac',
      '.wav',
      '.ogg',
    ];
    const ext = extname(file.originalname).toLowerCase();
    const isImage = file.mimetype?.startsWith('image/');
    const isAudio = file.mimetype?.startsWith('audio/') || ext === '.m4a';

    if (allowedExts.includes(ext) || isImage || isAudio) {
      cb(null, true);
    } else {
      cb(
        new BadRequestException(
          'Format de fichier non supporté. Veuillez envoyer une image ou un fichier audio.',
        ),
        false,
      );
    }
  },
  limits: {
    fileSize: 25 * 1024 * 1024, // 25 MB
  },
};

@Controller('storage')
export class StorageController {
  constructor(private readonly storageService: StorageService) {}

  @Post('upload')
  @UseInterceptors(FileInterceptor('file', multerOptions))
  async uploadFile(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('Aucun fichier fourni');
    }
    return this.storageService.saveFile(file);
  }
}
