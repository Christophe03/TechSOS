export type Role = "CLIENT" | "PROVIDER" | "ADMIN";

export interface User {
  id: string;
  phone: string;
  fullName: string;
  role: Role;
  workshopName?: string | null;
  specialties?: string | null;
  ratingAvg?: number;
  reviewCount?: number;
  createdAt: string;
}

export interface Category {
  id: string;
  name: string;
  description?: string | null;
  iconName?: string | null;
  displayOrder: number;
}

export type RepairStatus = "PENDING" | "OFFERS_RECEIVED" | "IN_PROGRESS" | "COMPLETED" | "CANCELLED";

export interface Offer {
  id: string;
  repairId: string;
  providerId: string;
  priceXof: number;
  estimatedDuration: string;
  comment?: string | null;
  status: "PENDING" | "ACCEPTED" | "REJECTED";
  createdAt: string;
  provider?: User;
}

export interface Review {
  id: string;
  repairId: string;
  clientId: string;
  providerId: string;
  rating: number;
  comment?: string | null;
  createdAt: string;
  client?: {
    fullName: string;
  };
}

export interface Repair {
  id: string;
  clientId: string;
  categoryId: string;
  equipmentTitle: string;
  issueDescription: string;
  audioVoiceUrl?: string | null;
  photosUrls?: string | null; // JSON string or comma-separated
  district: string;
  status: RepairStatus;
  selectedOfferId?: string | null;
  createdAt: string;
  category?: Category;
  client?: User;
  offers?: Offer[];
  reviews?: Review[];
}

export type WorkshopStatus = "RECEPTIONNE" | "DIAGNOSTIC" | "EN_REPARATION" | "PRET_RECUPERATION" | "LIVRE";

export interface WorkshopEntry {
  id: string;
  providerId: string;
  clientName: string;
  clientPhone: string;
  deviceBrandModel: string;
  issueReported: string;
  estimatedPriceXof: number;
  status: WorkshopStatus;
  createdAt: string;
  updatedAt: string;
}

export interface SubscriptionStatus {
  isActive: boolean;
  expiresAt?: string | null;
  planName: string;
  priceXof: number;
}
