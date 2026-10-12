"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { User } from "../types";
import { authApi, RegisterClientData, RegisterProviderData } from "../api/auth";

interface AuthContextType {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  login: (phone: string, pass: string) => Promise<User>;
  registerClient: (data: RegisterClientData) => Promise<User>;
  registerProvider: (data: RegisterProviderData) => Promise<User>;
  logout: () => void;
  setUser: React.Dispatch<React.SetStateAction<User | null>>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    try {
      const storedToken = localStorage.getItem("techsos_token");
      const storedUser = localStorage.getItem("techsos_user");
      if (storedToken && storedUser) {
        setToken(storedToken);
        setUser(JSON.parse(storedUser));
      }
    } catch (e) {
      console.error("Failed to restore session from storage", e);
    } finally {
      setIsLoading(false);
    }
  }, []);

  const saveSession = (accessToken: string, loggedUser: User) => {
    setToken(accessToken);
    setUser(loggedUser);
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
