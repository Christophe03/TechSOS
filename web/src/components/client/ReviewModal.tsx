"use client";

import React, { useState } from "react";
import { Star, X } from "lucide-react";
import { Button } from "../ui/Button";
import { repairsApi } from "@/lib/api/repairs";

interface ReviewModalProps {
  repairId: string;
  providerName: string;
  isOpen: boolean;
  onClose: () => void;
  onReviewSubmitted: () => void;
}

export const ReviewModal: React.FC<ReviewModalProps> = ({
  repairId,
  providerName,
  isOpen,
  onClose,
  onReviewSubmitted,
}) => {
  const [rating, setRating] = useState(5);
  const [hoverRating, setHoverRating] = useState<number | null>(null);
  const [comment, setComment] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);

    try {
      await repairsApi.createReview({
        repairId,
        rating,
        comment: comment.trim() || undefined,
      });
      onReviewSubmitted();
      onClose();
    } catch (err: any) {
      setError(err.message || "Erreur lors de la notation.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-in fade-in">
      <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-slate-200 space-y-5">
        <div className="flex items-center justify-between pb-3 border-b border-slate-100">
          <h3 className="text-lg font-bold text-slate-900">
            Évaluer la réparation
          </h3>
          <button
            onClick={onClose}
            className="p-1.5 text-slate-400 hover:text-slate-600 rounded-lg hover:bg-slate-100"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <p className="text-xs text-slate-500">
          Votre avis sur la prestation de <strong className="text-slate-800">{providerName}</strong> aide la communauté TechSOS à Bamako.
        </p>

        {error && (
          <div className="p-3 bg-rose-50 text-rose-700 text-xs rounded-xl border border-rose-200">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Star selector */}
          <div className="flex flex-col items-center justify-center py-2 space-y-2">
            <div className="flex items-center gap-2">
              {[1, 2, 3, 4, 5].map((star) => {
                const currentRating = hoverRating !== null ? hoverRating : rating;
                const isFilled = star <= currentRating;
                return (
                  <button
                    key={star}
                    type="button"
                    onClick={() => setRating(star)}
                    onMouseEnter={() => setHoverRating(star)}
                    onMouseLeave={() => setHoverRating(null)}
                    className="p-1 focus:outline-none transition-transform hover:scale-110"
                  >
                    <Star
                      className={`w-8 h-8 ${
                        isFilled
                          ? "text-amber-400 fill-amber-400"
                          : "text-slate-300"
                      }`}
                    />
                  </button>
                );
              })}
            </div>
            <span className="text-xs font-bold text-slate-600">
              {rating === 5 && "Excellent (5/5)"}
              {rating === 4 && "Très bien (4/5)"}
              {rating === 3 && "Correct (3/5)"}
              {rating === 2 && "Décevant (2/5)"}
              {rating === 1 && "Médiocre (1/5)"}
            </span>
          </div>

          <div>
            <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">
              Votre commentaire (optionnel)
            </label>
            <textarea
              rows={3}
              placeholder="Ex: Réparation rapide de mon écran, pièces d'origine, très accueillant à l'atelier."
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              className="w-full px-3.5 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary text-slate-900 resize-none"
            />
          </div>

          <div className="flex items-center justify-end gap-2.5 pt-2">
            <Button type="button" variant="outline" size="sm" onClick={onClose}>
              Annuler
            </Button>
            <Button type="submit" variant="accent" size="sm" isLoading={loading}>
              Publier mon avis
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};
