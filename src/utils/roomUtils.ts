export const generateRoomId = (): string => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

export const validateRoomId = (roomId: string): boolean => {
  return /^\d{6}$/.test(roomId);
};