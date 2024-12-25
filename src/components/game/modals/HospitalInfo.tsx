import React from 'react';
import { Modal } from '../../common/Modal';
import { ModalContent } from './components/ModalContent';
import { hospitalInfoSections } from './constants/hospitalInfo';
import { BaseModalProps } from './types';

export const HospitalInfo: React.FC<BaseModalProps> = ({ isOpen, onClose }) => (
  <Modal isOpen={isOpen} onClose={onClose} title="Hospital Information">
    <ModalContent sections={hospitalInfoSections} />
  </Modal>
);