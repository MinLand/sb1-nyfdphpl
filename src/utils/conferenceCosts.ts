export const getConferenceCost = (role: 'speaker' | 'attendee'): number => {
  switch (role) {
    case 'speaker':
      return 5000;
    case 'attendee':
      return 0;
    default:
      return 0;
  }
};