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

export interface UpdateProfilePayload {
  fullName?: string;
  phone?: string;
  email?: string;
  city?: string;
  address?: string;
  workshopName?: string;
  addressZone?: string;
  specialties?: string[];
}

export interface ChangePasswordPayload {
  currentPassword: string;
  newPassword: string;
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

  getMe: async (): Promise<any> => {
    const { data } = await apiClient.get("/users/me");
    return data;
  },

  updateProfile: async (payload: UpdateProfilePayload): Promise<any> => {
    const { data } = await apiClient.patch("/users/profile", payload);
    return data;
  },

  changePassword: async (payload: ChangePasswordPayload): Promise<{ message: string }> => {
    const { data } = await apiClient.patch("/users/change-password", payload);
    return data;
  },
};
