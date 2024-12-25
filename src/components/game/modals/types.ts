export interface BaseModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export interface SectionContent {
  title: string;
  content: string | string[];
}