import React from 'react';
import { Login } from './components/Login';
import { GameLayout } from './components/game/GameLayout';
import { useAuth } from './hooks/useAuth';
import { LoadingSpinner } from './components/common/LoadingSpinner';

function App() {
  const { isAuthenticated, isLoading } = useAuth();

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (!isAuthenticated) {
    return <Login />;
  }

  return <GameLayout />;
}

export default App;