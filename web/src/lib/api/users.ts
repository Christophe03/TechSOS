import { apiClient } from "./client";

export interface ProviderItem {
  id: string;
  userId: string;
  workshopName: string;
  addressZone?: string | null;
  specialtiesJson?: string | null;
  ratingAvg: number;
  reviewCount: number;
  subscriptionStatus: string;
  user: {
    id: string;
    fullName: string;
    phone: string;
    email?: string | null;
    city?: string | null;
    address?: string | null;
    avatarUrl?: string | null;
  };
}

export const usersApi = {
  getProviders: async (filters?: {
    specialtyId?: string;
    zone?: string;
  }): Promise<ProviderItem[]> => {
    const params = new URLSearchParams();
    if (filters?.specialtyId) params.append("specialtyId", filters.specialtyId);
    if (filters?.zone) params.append("zone", filters.zone);

    const { data } = await apiClient.get<ProviderItem[]>(
      `/users/providers?${params.toString()}`
    );
    return data;
  },
};
