"use client";

import React, { useState, useRef, useEffect } from "react";
import { Mic, Square, Play, Pause, RotateCcw, Volume2, Check } from "lucide-react";

interface WebAudioRecorderProps {
  onAudioReady: (blob: Blob | null) => void;
}

export const WebAudioRecorder: React.FC<WebAudioRecorderProps> = ({ onAudioReady }) => {
  const [isRecording, setIsRecording] = useState(false);
  const [audioUrl, setAudioUrl] = useState<string | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [duration, setDuration] = useState(0);
  const [error, setError] = useState<string | null>(null);

  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);
  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const audioElementRef = useRef<HTMLAudioElement | null>(null);

  useEffect(() => {
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
      if (audioUrl) URL.revokeObjectURL(audioUrl);
    };
  }, [audioUrl]);

  const startRecording = async () => {
    setError(null);
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const mediaRecorder = new MediaRecorder(stream);
      mediaRecorderRef.current = mediaRecorder;
      audioChunksRef.current = [];

      mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          audioChunksRef.current.push(event.data);
        }
      };

      mediaRecorder.onstop = () => {
        const audioBlob = new Blob(audioChunksRef.current, {
          type: "audio/webm;codecs=opus",
        });
        const url = URL.createObjectURL(audioBlob);
        setAudioUrl(url);
        onAudioReady(audioBlob);
        stream.getTracks().forEach((track) => track.stop());
      };

      mediaRecorder.start();
      setIsRecording(true);
      setDuration(0);

      timerRef.current = setInterval(() => {
        setDuration((prev) => {
          if (prev >= 120) {
            stopRecording();
            return prev;
          }
          return prev + 1;
        });
      }, 1000);
    } catch (err: any) {
      console.error("Mic access error", err);
      setError("Accès au microphone refusé. Autorisez l'accès micro dans votre navigateur.");
    }
  };

  const stopRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stop();
      setIsRecording(false);
      if (timerRef.current) {
        clearInterval(timerRef.current);
      }
    }
  };

  const resetRecording = () => {
    if (audioUrl) {
      URL.revokeObjectURL(audioUrl);
    }
    setAudioUrl(null);
    setIsPlaying(false);
    setDuration(0);
    onAudioReady(null);
  };

  const togglePlayback = () => {
    if (!audioElementRef.current && audioUrl) {
      audioElementRef.current = new Audio(audioUrl);
      audioElementRef.current.onended = () => setIsPlaying(false);
    }

    if (audioElementRef.current) {
      if (isPlaying) {
        audioElementRef.current.pause();
        setIsPlaying(false);
      } else {
        audioElementRef.current.play();
        setIsPlaying(true);
      }
    }
  };

  const formatTime = (secs: number) => {
    const m = Math.floor(secs / 60);
    const s = secs % 60;
    return `${m}:${s < 10 ? "0" : ""}${s}`;
  };

  return (
    <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200 space-y-3">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Volume2 className="w-4 h-4 text-brand-accent" />
          <span className="text-xs font-bold text-slate-800 uppercase tracking-wider">
            Note Vocale de la Panne (Option recommandée)
          </span>
        </div>
        {audioUrl && (
          <span className="inline-flex items-center gap-1 text-[11px] font-bold text-emerald-700 bg-emerald-100 px-2.5 py-0.5 rounded-full">
            <Check className="w-3 h-3" /> Note enregistrée
          </span>
        )}
      </div>

      <p className="text-xs text-slate-500">
        Parlez directement pour expliquer les bruits suspects, l'historique ou le comportement de l'appareil.
      </p>

      {error && (
        <div className="text-xs p-2.5 bg-rose-50 border border-rose-200 text-rose-700 rounded-lg">
          {error}
        </div>
      )}

      {/* Record state UI */}
      {!audioUrl && !isRecording && (
        <button
          type="button"
          onClick={startRecording}
          className="w-full py-4 px-4 bg-white border-2 border-dashed border-slate-300 hover:border-brand-accent rounded-xl text-slate-700 hover:text-brand-accent flex items-center justify-center gap-3 transition-colors group"
        >
          <div className="w-9 h-9 rounded-full bg-orange-100 group-hover:bg-brand-accent group-hover:text-white text-brand-accent flex items-center justify-center transition-colors">
            <Mic className="w-5 h-5" />
          </div>
          <span className="text-sm font-bold">Appuyez pour enregistrer votre voix</span>
        </button>
      )}

      {isRecording && (
        <div className="p-4 bg-white rounded-xl border border-orange-200 flex items-center justify-between shadow-sm">
          <div className="flex items-center gap-3">
            <span className="w-3.5 h-3.5 rounded-full bg-rose-500 animate-ping" />
            <span className="text-sm font-bold text-slate-900">
              Enregistrement en cours... {formatTime(duration)}
            </span>
          </div>

          <div className="flex items-center gap-1 h-6">
            <span className="w-1 bg-brand-accent rounded-full animate-soundwave [animation-delay:0.1s]" />
            <span className="w-1 bg-brand-accent rounded-full animate-soundwave [animation-delay:0.3s]" />
            <span className="w-1 bg-brand-accent rounded-full animate-soundwave [animation-delay:0.2s]" />
            <span className="w-1 bg-brand-accent rounded-full animate-soundwave [animation-delay:0.4s]" />
            <span className="w-1 bg-brand-accent rounded-full animate-soundwave [animation-delay:0.15s]" />
          </div>

          <button
            type="button"
            onClick={stopRecording}
            className="px-3.5 py-1.5 rounded-lg bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold flex items-center gap-1.5 transition-colors"
          >
            <Square className="w-3.5 h-3.5 fill-white" />
            <span>Terminer</span>
          </button>
        </div>
      )}

      {audioUrl && (
        <div className="p-3.5 bg-white rounded-xl border border-slate-200 flex items-center justify-between shadow-sm">
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={togglePlayback}
              className="w-9 h-9 rounded-full bg-brand-primary text-white flex items-center justify-center hover:bg-brand-primary-light transition-colors"
            >
              {isPlaying ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4 ml-0.5" />}
            </button>
            <div>
              <div className="text-xs font-bold text-slate-800">
                {isPlaying ? "Lecture en cours..." : "Note vocale prête"}
              </div>
              <div className="text-[11px] text-slate-500">Durée : {formatTime(duration)}</div>
            </div>
          </div>

          <button
            type="button"
            onClick={resetRecording}
            className="p-2 text-slate-400 hover:text-rose-600 rounded-lg hover:bg-slate-100 transition-colors"
            title="Recommencer l'enregistrement"
          >
            <RotateCcw className="w-4 h-4" />
          </button>
        </div>
      )}
    </div>
  );
};
