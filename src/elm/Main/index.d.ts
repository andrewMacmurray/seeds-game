// WARNING: Do not manually modify this file. It was generated using:
// https://github.com/dillonkearns/elm-typescript-interop
// Type definitions for Elm ports

export namespace Elm {
  namespace Main {
    export interface App {
      ports: {
        saveProgress: {
          subscribe(callback: (data: { worldId: number; levelId: number }) => void): void
        }
        saveLives: {
          subscribe(callback: (data: { lastPlayed: number; timeTillNextLife: number }) => void): void
        }
        clearCache_: {
          subscribe(callback: (data: null) => void): void
        }
        playIntroMusic: {
          subscribe(callback: (data: null) => void): void
        }
        introMusicPlaying: {
          send(data: boolean): void
        }
        fadeMusic: {
          subscribe(callback: (data: null) => void): void
        },
        scrollToCenter: {
          subscribe(callback: (data: string) => void): void
        },
        onRightSwipe: {
          send(data: null): void
        }
      };
    }
    
    export function init(options: {
      node?: HTMLElement | null;
      flags: { now: number; lives: { lastPlayed: number; timeTillNextLife: number } | null; progress: { worldId: number; levelId: number } | null; randomMessageIndex: number; window: { width: number; height: number } };
    }): Elm.Main.App;
  }
}