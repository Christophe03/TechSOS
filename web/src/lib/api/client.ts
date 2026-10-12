import axios, { AxiosError } from "axios";

export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_URL || "http://localhost:3000/api";

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
  timeout: 15000,
});

// Interceptor: inject Bearer token
apiClient.interceptors.request.use(
  (config) => {
    if (typeof window !== "undefined") {
      const token = localStorage.getItem("techsos_token");
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor: map errors to clear French messages
apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError<{ message?: string | string[] }>) => {
    if (!error.response) {
      return Promise.reject(
        new Error("Impossible de joindre le serveur TechSOS. Vérifiez votre connexion internet.")
      );
    }

    const { status, data } = error.response;
    let message = "Une erreur imprévue est survenue.";

    if (data?.message) {
      if (Array.isArray(data.message)) {
        message = data.message.join(", ");
      } else {
        message = data.message;
      }
    } else if (status === 401) {
      message = "Session expirée ou identifiants incorrects.";
    } else if (status === 403) {
      message = "Action non autorisée.";
    } else if (status === 404) {
      message = "La ressource demandée n'a pas été trouvée.";
    } else if (status === 500) {
      message = "Erreur interne du serveur TechSOS. Veuillez réessayer plus tard.";
    }

    return Promise.reject(new Error(message));
  }
);
