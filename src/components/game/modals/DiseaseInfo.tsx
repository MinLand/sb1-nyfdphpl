import React from 'react';
import { Modal } from '../../common/Modal';
import { ModalContent } from './components/ModalContent';
import { diseaseInfoSections } from './constants/diseaseInfo';
import { BaseModalProps } from './types';

export const DiseaseInfo: React.FC<BaseModalProps> = ({ isOpen, onClose }) => (
  <Modal isOpen={isOpen} onClose={onClose} title="Disease Information">
    <ModalContent sections={diseaseInfoSections} />
  </Modal>
);