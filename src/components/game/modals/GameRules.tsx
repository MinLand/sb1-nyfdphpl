import React from 'react';
import { Modal } from '../../common/Modal';
import { ModalContent } from './components/ModalContent';
import { gameRulesSections } from './constants/gameRules';
import { BaseModalProps } from './types';

export const GameRules: React.FC<BaseModalProps> = ({ isOpen, onClose }) => (
  <Modal isOpen={isOpen} onClose={onClose} title="Game Rules">
    <ModalContent sections={gameRulesSections} />
  </Modal>
);