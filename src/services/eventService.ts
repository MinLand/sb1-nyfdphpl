import { recordActivity } from './activityService';

export interface ExternalEvent {
  roomId: string;
  companyId: 'A' | 'D';
  roundNumber: number;
  doctorName: string;
  role: 'speaker' | 'attendee';
  topic?: string;
}

export const createExternalEvent = async (event: ExternalEvent): Promise<void> => {
  try {
    const cost = event.role === 'speaker' ? 10000 : 0;

    await recordActivity({
      roomId: event.roomId,
      companyId: event.companyId,
      roundNumber: event.roundNumber,
      actionType: 'event',
      cost,
      doctorName: event.doctorName,
      topic: event.topic
    });
  } catch (error) {
    console.error('External event error:', error);
    throw error;
  }
};