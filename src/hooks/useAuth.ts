import { useEffect, useState } from 'react';
import { User } from '@supabase/supabase-js';
import { supabase } from '../lib/supabase';

export const useAuth = () => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    let mounted = true;

    const initAuth = async () => {
      try {
        // Get initial session
        const { data: { session } } = await supabase.auth.getSession();
        if (mounted) {
          setUser(session?.user ?? null);
          setIsLoading(false);
        }

        // Listen for auth changes
        const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
          if (mounted) {
            setUser(session?.user ?? null);
            setIsLoading(false);
          }
        });

        return () => {
          subscription.unsubscribe();
        };
      } catch (error) {
        console.error('Auth initialization error:', error);
        if (mounted) {
          setUser(null);
          setIsLoading(false);
        }
      }
    };

    initAuth();

    return () => {
      mounted = false;
    };
  }, []);

  return {
    user,
    isLoading,
    isAuthenticated: !!user
  };
};