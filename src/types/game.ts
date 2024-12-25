export interface Hospital {
  id: string;
  name: string;
  patientCount: number;
  doctors: Doctor[];
}

export interface Doctor {
  id: string;
  name: string;
  hospitalId: string;
  knowledgeScores: {
    aDrug: number;
    dDrug: number;
    hormones: number;
    immunosuppressants: number;
  };
}

export interface GameState {
  roomId: string;
  currentRound: number;
  totalRounds: number;
  players: {
    companyA: string | null;
    companyD: string | null;
  };
  marketShare: {
    [hospitalId: string]: {
      aDrug: number;
      dDrug: number;
    };
  };
  remainingFunds: {
    [playerId: string]: number;
  };
}