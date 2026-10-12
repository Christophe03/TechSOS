import { apiClient, API_BASE_URL } from "./client";
import { Category, Repair, Offer, Review } from "../types";

export interface CreateRepairPayload {
  categoryId: string;
  equipmentTitle: string;
  issueDescription: string;
  district: string;
  audioBlob?: Blob;
  photos?: File[];
}

export const repairsApi = {
  getCategories: async (): Promise<Category[]> => {
    const { data } = await apiClient.get<Category[]>("/categories");
    return data;
  },

  getMyRepairs: async (): Promise<Repair[]> => {
    const { data } = await apiClient.get<Repair[]>("/repairs/my-repairs");
    return data;
  },

  getRepairById: async (id: string): Promise<Repair> => {
    const { data } = await apiClient.get<Repair>(`/repairs/${id}`);
    return data;
  },

  createRepair: async (payload: CreateRepairPayload): Promise<Repair> => {
    const formData = new FormData();
    formData.append("categoryId", payload.categoryId);
    formData.append("equipmentTitle", payload.equipmentTitle);
    formData.append("issueDescription", payload.issueDescription);
    formData.append("district", payload.district);

    if (payload.audioBlob) {
      formData.append(
        "voiceAudio",
        payload.audioBlob,
        "note-vocale-panne.webm"
      );
    }

    if (payload.photos && payload.photos.length > 0) {
      payload.photos.forEach((file) => {
        formData.append("photos", file);
      });
    }

    const { data } = await apiClient.post<Repair>("/repairs", formData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
    return data;
  },

  acceptOffer: async (offerId: string): Promise<Offer> => {
    const { data } = await apiClient.post<Offer>(`/offers/${offerId}/accept`);
    return data;
  },

  createReview: async (payload: {
    repairId: string;
    rating: number;
    comment?: string;
  }): Promise<Review> => {
    const { data } = await apiClient.post<Review>("/reviews", payload);
    return data;
  },

  // Media helper
  getMediaUrl: (path?: string | null): string => {
    if (!path) return "";
    if (path.startsWith("http")) return path;
    const cleanPath = path.startsWith("/") ? path : `/${path}`;
    return `${API_BASE_URL.replace("/api", "")}${cleanPath}`;
  },
};
