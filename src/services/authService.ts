import { supabase } from '../lib/supabase';
import { AuthError, User } from '@supabase/supabase-js';

export const getCurrentUser = async (): Promise<User | null> => {
  try {
    const { data: { user }, error } = await supabase.auth.getUser();
    if (error) throw error;
    return user;
  } catch (error) {
    console.error('Error getting current user:', error);
    return null;
  }
};

export const signUp = async (email: string, password: string) => {
  try {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        emailRedirectTo: `${window.location.origin}/auth/callback`
      }
    });

    if (error) throw error;
    return data;
  } catch (error) {
    console.error('Signup error:', error);
    throw error;
  }
};

export const signIn = async (email: string, password: string) => {
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    });

    if (error) {
      if (error instanceof AuthError) {
        switch (error.status) {
          case 400:
            throw new Error('Invalid email or password');
          case 422:
            throw new Error('Email not confirmed');
          default:
            throw new Error('Authentication failed');
        }
      }
      throw error;
    }

    return data;
  } catch (error) {
    console.error('Sign in error:', error);
    throw error;
  }
};

export const signOut = async () => {
  const { error } = await supabase.auth.signOut();
  if (error) throw error;
};