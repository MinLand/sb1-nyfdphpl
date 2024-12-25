import { recordActivity } from './activityService';

export interface ConferenceRequest {
  roomId: string;
  companyId: 'A' | 'D';
  roundNumber: number;
  doctorName: string;
  role: 'speaker' | 'attendee';
  topic?: string;
}

export const createConference = async (request: ConferenceRequest): Promise<void> => {
  try {
    const cost = request.role === 'speaker' ? 5000 : 0;
    
    await recordActivity({
      roomId: request.roomId,
      companyId: request.companyId,
      roundNumber: request.roundNumber,
      actionType: 'conference',
      cost,
      doctorName: request.doctorName,
      topic: request.topic
    });
  } catch (error) {
    console.error('Conference creation error:', error);
    throw error;
  }
};