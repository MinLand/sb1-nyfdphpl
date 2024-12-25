import { create } from 'zustand';
import type { GameState } from '../types/game';

interface GameStore extends GameState {
  setRoomId: (roomId: string) => void;
  joinGame: (playerId: string, company: 'A' | 'D') => void;
  updateMarketShare: (hospitalId: string, shares: { aDrug: number; dDrug: number }) => void;
  updateFunds: (playerId: string, amount: number) => void;
  advanceRound: () => void;
}

const initialState: GameState = {
  roomId: '',
  currentRound: 1,
  totalRounds: 15,
  players: {
    companyA: null,
    companyD: null,
  },
  marketShare: {},
  remainingFunds: {
    default: 60000,
  },
};

export const useGameStore = create<GameStore>((set) => ({
  ...initialState,
  setRoomId: (roomId) => set({ roomId }),
  joinGame: (playerId, company) =>
    set((state) => ({
      players: {
        ...state.players,
        [company === 'A' ? 'companyA' : 'companyD']: playerId,
      },
      remainingFunds: {
        ...state.remainingFunds,
        [playerId]: initialState.remainingFunds.default,
      },
    })),
  updateMarketShare: (hospitalId, shares) =>
    set((state) => ({
      marketShare: {
        ...state.marketShare,
        [hospitalId]: shares,
      },
    })),
  updateFunds: (playerId, amount) =>
    set((state) => ({
      remainingFunds: {
        ...state.remainingFunds,
        [playerId]: amount,
      },
    })),
  advanceRound: () =>
    set((state) => ({
      currentRound: Math.min(state.currentRound + 1, state.totalRounds),
    })),
}));