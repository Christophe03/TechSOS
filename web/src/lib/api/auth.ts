import { apiClient } from "./client";
import { User } from "../types";

export interface LoginResponse {
  access_token: string;
  user: User;
}

export interface RegisterClientData {
  phone: string;
  fullName: string;
  password: string;
}

export interface RegisterProviderData {
  phone: string;
  fullName: string;
  password: string;
  workshopName: string;
  specialties: string[];
}

export const authApi = {
  login: async (phone: string, password: string): Promise<LoginResponse> => {
    const { data } = await apiClient.post<LoginResponse>("/auth/login", {
      phone,
      password,
    });
    return data;
  },

  registerClient: async (payload: RegisterClientData): Promise<LoginResponse> => {
    const { data } = await apiClient.post<LoginResponse>(
      "/auth/register-client",
      payload
    );
    return data;
  },

  registerProvider: async (
    payload: RegisterProviderData
  ): Promise<LoginResponse> => {
    const { data } = await apiClient.post<LoginResponse>(
      "/auth/register-provider",
      payload
    );
    return data;
  },

  getProfile: async (): Promise<User> => {
    const { data } = await apiClient.get<User>("/users/profile");
    return data;
  },
};
