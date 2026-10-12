import { apiClient } from "./client";
import { Repair, Offer, WorkshopEntry, WorkshopStatus, SubscriptionStatus } from "../types";

export interface CreateOfferPayload {
  repairId: string;
  priceXof: number;
  estimatedDuration: string;
  comment?: string;
}

export interface QuickEntryPayload {
  clientName: string;
  clientPhone: string;
  deviceBrandModel: string;
  issueReported: string;
  estimatedPriceXof: number;
}

export const workshopApi = {
  getFeed: async (): Promise<Repair[]> => {
    const { data } = await apiClient.get<Repair[]>("/repairs/feed");
    return data;
  },

  getMyOffers: async (): Promise<Offer[]> => {
    const { data } = await apiClient.get<Offer[]>("/offers/my-offers");
    return data;
  },

  submitOffer: async (payload: CreateOfferPayload): Promise<Offer> => {
    const { data } = await apiClient.post<Offer>("/offers", payload);
    return data;
  },

  getJournalEntries: async (): Promise<WorkshopEntry[]> => {
    const { data } = await apiClient.get<WorkshopEntry[]>("/workshop");
    return data;
  },

  createQuickEntry: async (payload: QuickEntryPayload): Promise<WorkshopEntry> => {
    const { data } = await apiClient.post<WorkshopEntry>("/workshop/quick-entry", payload);
    return data;
  },

  updateEntryStatus: async (
    id: string,
    status: WorkshopStatus
  ): Promise<WorkshopEntry> => {
    const { data } = await apiClient.patch<WorkshopEntry>(`/workshop/${id}/status`, {
      status,
    });
    return data;
  },

  getSubscriptionStatus: async (): Promise<SubscriptionStatus> => {
    const { data } = await apiClient.get<SubscriptionStatus>("/subscriptions/status");
    return data;
  },

  subscribe: async (paymentMethod: "ORANGE_MONEY" | "MOOV_MONEY", phoneNumber: string): Promise<any> => {
    const { data } = await apiClient.post("/subscriptions/subscribe", {
      paymentMethod,
      phoneNumber,
    });
    return data;
  },
};
