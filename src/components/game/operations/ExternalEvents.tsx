import React, { useState } from 'react';
import { Modal } from '../../common/Modal';
import { HospitalSelection } from './shared/HospitalSelection';
import { DoctorSelection } from './shared/DoctorSelection';
import { RoleSelection } from './shared/RoleSelection';
import { TopicSelection } from './shared/TopicSelection';
import { useGameStore } from '../../../store/gameStore';
import { recordActivity } from '../../../services/activityService';
import { getEventCost } from '../../../utils/EventCosts';
import { useActivityCount } from '../../../hooks/useActivityCount';


interface ExternalEventsProps {
  isOpen: boolean;
  onClose: () => void;
}

type Step = 'hospital' | 'doctor' | 'role' | 'topic';

export const ExternalEvents: React.FC<ExternalEventsProps> = ({ isOpen, onClose }) => {
  const [step, setStep] = useState<Step>('hospital');
  const [selectedHospital, setSelectedHospital] = useState<string | null>(null);
  const [selectedDoctor, setSelectedDoctor] = useState<string | null>(null);
  const [selectedRole, setSelectedRole] = useState<'speaker' | 'attendee' | null>(null);
  const [error, setError] = useState<string | null>(null);

  const { roomId, currentRound, players, remainingFunds } = useGameStore();
  const companyType = players.companyA ? 'A' : 'D';
  const playerFunds = remainingFunds[Object.keys(remainingFunds)[0]] || 0;
  const { incrementCount } = useActivityCount();

  const handleComplete = async (topic?: string) => {
    try {
      if (!selectedHospital || !selectedDoctor || !selectedRole) {
        throw new Error('Missing required selections');
      }

      const cost = getEventCost(selectedRole);
      
      if (cost > playerFunds) {
        throw new Error('Insufficient funds');
      }

      await recordActivity({
        roomId,
        companyId: companyType,
        roundNumber: currentRound,
        actionType: 'event',
        doctorName: selectedDoctor,
        cost,
        topic: topic
      });

      useGameStore.getState().updateFunds(
        Object.keys(remainingFunds)[0],
        playerFunds - cost
      );

      onClose();
      resetState();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to schedule events');
    }
  };
  
  const resetState = () => {
    setStep('hospital');
    setSelectedHospital(null);
    setSelectedDoctor(null);
    setSelectedRole(null);
    setError(null);
  };

  const renderStep = () => {
    switch (step) {
      case 'hospital':
        return (
          <HospitalSelection
            onSelect={(hospitalId) => {
              setSelectedHospital(hospitalId);
              setStep('doctor');
            }}
          />
        );
      case 'doctor':
        return (
          <DoctorSelection
            hospitalId={selectedHospital!}
            onSelect={(doctorId) => {
              setSelectedDoctor(doctorId);
              setStep('role');
            }}
            onBack={() => setStep('hospital')}
          />
        );
      case 'role':
        return (
          <RoleSelection
            onSelect={(role) => {
              setSelectedRole(role);
              if (role === 'speaker') {
                setStep('topic');
              } else {
                handleComplete();
              }
            }}
            onBack={() => setStep('doctor')}
          />
        );
      case 'topic':
        return (
          <TopicSelection
            companyId={companyType}
            onSelect={(topic) => handleComplete(topic)}
            onBack={() => setStep('role')}
          />
        );
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="External Events Sponsorship">
      <div className="space-y-6">
        {renderStep()}
        {error && (
          <div className="p-3 text-sm text-red-600 bg-red-50 rounded-lg">
            {error}
          </div>
        )}
      </div>
    </Modal>
  );
};