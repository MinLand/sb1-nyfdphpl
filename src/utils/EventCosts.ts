export const getEventCost = (role: 'speaker' | 'attendee'): number => {
  switch (role) {
    case 'speaker':
      return 10000;
    case 'attendee':
      return 0;
    default:
      return 0;
  }
};