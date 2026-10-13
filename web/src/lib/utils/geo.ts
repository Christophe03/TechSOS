import { POPULAR_DISTRICTS } from "../constants/bamako";

export interface GeoLocationCoords {
  latitude: number;
  longitude: number;
}

export interface DistrictGeo {
  name: string;
  lat: number;
  lng: number;
  commune: string;
}

// Representative GPS centers for Bamako's key districts
export const BAMAKO_DISTRICT_COORDS: Record<string, DistrictGeo> = {
  "Hamdallaye ACI 2000": {
    name: "Hamdallaye ACI 2000",
    lat: 12.6318,
    lng: -8.0267,
    commune: "Commune IV",
  },
  "Badalabougou": {
    name: "Badalabougou",
    lat: 12.6205,
    lng: -7.9942,
    commune: "Commune V",
  },
  "Lafiabougou": {
    name: "Lafiabougou",
    lat: 12.6375,
    lng: -8.0483,
    commune: "Commune IV",
  },
  "Médina Coura": {
    name: "Médina Coura",
    lat: 12.6567,
    lng: -7.9867,
    commune: "Commune II",
  },
  "Baco Djicoroni": {
    name: "Baco Djicoroni",
    lat: 12.5925,
    lng: -7.9992,
    commune: "Commune V",
  },
  "Faladié": {
    name: "Faladié",
    lat: 12.5982,
    lng: -7.9572,
    commune: "Commune VI",
  },
  "Korofina": {
    name: "Korofina",
    lat: 12.6711,
    lng: -7.9489,
    commune: "Commune I",
  },
  "Sogoniko": {
    name: "Sogoniko",
    lat: 12.6075,
    lng: -7.9694,
    commune: "Commune VI",
  },
};

/**
 * Computes great-circle distance between two GPS coordinates using Haversine formula (in kilometers)
 */
export function calculateDistanceKm(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371; // Earth radius in km
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c * 10) / 10;
}

/**
 * Finds the closest Bamako district from user GPS coordinates
 */
export function findClosestBamakoDistrict(
  coords: GeoLocationCoords
): { district: string; distanceKm: number } {
  let closestDistrict = POPULAR_DISTRICTS[0];
  let minDistance = Infinity;

  for (const [districtName, geo] of Object.entries(BAMAKO_DISTRICT_COORDS)) {
    const dist = calculateDistanceKm(coords.latitude, coords.longitude, geo.lat, geo.lng);
    if (dist < minDistance) {
      minDistance = dist;
      closestDistrict = districtName;
    }
  }

  return { district: closestDistrict, distanceKm: minDistance };
}

/**
 * Returns distance from user coordinates to a workshop zone or district name
 */
export function getDistanceToWorkshop(
  userCoords: GeoLocationCoords | null,
  workshopZone?: string | null
): number | null {
  if (!userCoords || !workshopZone) return null;

  // Match district in zone string
  for (const [districtName, geo] of Object.entries(BAMAKO_DISTRICT_COORDS)) {
    if (workshopZone.toLowerCase().includes(districtName.toLowerCase())) {
      return calculateDistanceKm(userCoords.latitude, userCoords.longitude, geo.lat, geo.lng);
    }
  }

  // Fallback default city distance estimation
  return null;
}

/**
 * Computes an effective distance in km between the user and a workshop.
 * Uses exact GPS if userCoords is available, or computes distance from userDistrict center to workshop zone.
 * Returns a numerical distance in km (default fallback 15km if unknown).
 */
export function getWorkshopDistanceScore(
  userCoords: GeoLocationCoords | null,
  userDistrict: string | null | undefined,
  workshopZone?: string | null
): number {
  if (!workshopZone) return 99;

  // 1. If GPS is present, calculate direct distance
  if (userCoords) {
    const directDist = getDistanceToWorkshop(userCoords, workshopZone);
    if (directDist !== null) return directDist;
  }

  // 2. If user has a default district or fallback
  const effectiveUserDistrict =
    userDistrict && userDistrict !== "ALL" ? userDistrict : "Hamdallaye ACI 2000";

  // If workshop is directly in user's district, distance is minimal (~0.5 km)
  if (workshopZone.toLowerCase().includes(effectiveUserDistrict.toLowerCase())) {
    return 0.5;
  }

  const userGeo = BAMAKO_DISTRICT_COORDS[effectiveUserDistrict] || BAMAKO_DISTRICT_COORDS["Hamdallaye ACI 2000"];
  if (userGeo) {
    for (const [wDistName, wGeo] of Object.entries(BAMAKO_DISTRICT_COORDS)) {
      if (workshopZone.toLowerCase().includes(wDistName.toLowerCase())) {
        return calculateDistanceKm(userGeo.lat, userGeo.lng, wGeo.lat, wGeo.lng);
      }
    }
  }

  return 12.5;
}
