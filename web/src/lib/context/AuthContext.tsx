"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { User } from "../types";
import { authApi, RegisterClientData, RegisterProviderData } from "../api/auth";
import { GeoLocationCoords, findClosestBamakoDistrict } from "../utils/geo";

interface AuthContextType {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  login: (phone: string, pass: string) => Promise<User>;
  registerClient: (data: RegisterClientData) => Promise<User>;
  registerProvider: (data: RegisterProviderData) => Promise<User>;
  logout: () => void;
  setUser: React.Dispatch<React.SetStateAction<User | null>>;
  // Geolocation & Proximity properties
  userDistrict: string;
  setUserDistrict: (district: string) => void;
  userCoords: GeoLocationCoords | null;
  isLocating: boolean;
  locationError: string | null;
  requestGeoLocation: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // User location state
  const [userDistrict, setUserDistrictState] = useState<string>("Hamdallaye ACI 2000");
  const [userCoords, setUserCoords] = useState<GeoLocationCoords | null>(null);
  const [isLocating, setIsLocating] = useState<boolean>(false);
  const [locationError, setLocationError] = useState<string | null>(null);

  useEffect(() => {
    try {
      const storedToken = localStorage.getItem("techsos_token");
      const storedUser = localStorage.getItem("techsos_user");
      const storedDistrict = localStorage.getItem("techsos_user_district");

      if (storedToken && storedUser) {
        setToken(storedToken);
        const parsedUser: User = JSON.parse(storedUser);
        setUser(parsedUser);
        if (parsedUser.addressZone) {
          setUserDistrictState(parsedUser.addressZone);
        }
      }

      if (storedDistrict) {
        setUserDistrictState(storedDistrict);
      }
    } catch (e) {
      console.error("Failed to restore session from storage", e);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const setUserDistrict = (district: string) => {
    setUserDistrictState(district);
    try {
      localStorage.setItem("techsos_user_district", district);
    } catch {}
  };

  const requestGeoLocation = async (): Promise<void> => {
    if (typeof window === "undefined" || !navigator.geolocation) {
      setLocationError("La géolocalisation n'est pas prise en charge par votre navigateur.");
      return;
    }

    setIsLocating(true);
    setLocationError(null);

    return new Promise((resolve) => {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const coords: GeoLocationCoords = {
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
          };
          setUserCoords(coords);
          const closest = findClosestBamakoDistrict(coords);
          setUserDistrict(closest.district);
          setIsLocating(false);
          resolve();
        },
        (error) => {
          setIsLocating(false);
          let msg = "Impossible de récupérer votre position.";
          if (error.code === error.PERMISSION_DENIED) {
            msg = "Accès à la position refusé. Vous pouvez choisir votre quartier manuellement.";
          }
          setLocationError(msg);
          resolve();
        },
        { enableHighAccuracy: true, timeout: 8000 }
      );
    });
  };

  const saveSession = (accessToken: string, loggedUser: User) => {
    setToken(accessToken);
    setUser(loggedUser);
    if (loggedUser.addressZone) {
      setUserDistrict(loggedUser.addressZone);
    }
    localStorage.setItem("techsos_token", accessToken);
    localStorage.setItem("techsos_user", JSON.stringify(loggedUser));
  };

  const login = async (phone: string, pass: string): Promise<User> => {
    setIsLoading(true);
    try {
      const res = await authApi.login(phone, pass);
      saveSession(res.access_token, res.user);
      return res.user;
    } finally {
      setIsLoading(false);
    }
  };

  const registerClient = async (data: RegisterClientData): Promise<User> => {
    setIsLoading(true);
    try {
      const res = await authApi.registerClient(data);
      saveSession(res.access_token, res.user);
      return res.user;
    } finally {
      setIsLoading(false);
    }
  };

  const registerProvider = async (data: RegisterProviderData): Promise<User> => {
    setIsLoading(true);
    try {
      const res = await authApi.registerProvider(data);
      saveSession(res.access_token, res.user);
      return res.user;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    localStorage.removeItem("techsos_token");
    localStorage.removeItem("techsos_user");
    window.location.href = "/";
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isLoading,
        login,
        registerClient,
        registerProvider,
        logout,
        setUser,
        userDistrict,
        setUserDistrict,
        userCoords,
        isLocating,
        locationError,
        requestGeoLocation,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};
