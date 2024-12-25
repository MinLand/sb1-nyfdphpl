import React from 'react';
import { Modal } from '../../common/Modal';
import { ModalContent } from './components/ModalContent';
import { marketInfoSections } from './constants/marketInfo';
import { BaseModalProps } from './types';

export const MarketInfo: React.FC<BaseModalProps> = ({ isOpen, onClose }) => (
  <Modal isOpen={isOpen} onClose={onClose} title="Market Information">
    <ModalContent sections={marketInfoSections} />
  </Modal>
);