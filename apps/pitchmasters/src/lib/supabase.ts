import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export type Database = {
  public: {
    Tables: {
      clubs: {
        Row: {
          id: string;
          name: string;
          charter_number: string | null;
          timezone: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          charter_number?: string | null;
          timezone: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          name?: string;
          charter_number?: string | null;
          timezone?: string;
          created_at?: string;
          updated_at?: string;
        };
      };
      users: {
        Row: {
          id: string;
          email: string;
          full_name: string;
          club_id: string;
          role: 'member' | 'officer' | 'admin';
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          email: string;
          full_name: string;
          club_id: string;
          role?: 'member' | 'officer' | 'admin';
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          email?: string;
          full_name?: string;
          club_id?: string;
          role?: 'member' | 'officer' | 'admin';
          created_at?: string;
          updated_at?: string;
        };
      };
      meetings: {
        Row: {
          id: string;
          club_id: string;
          title: string;
          date: string;
          start_time: string;
          end_time: string;
          meeting_type: 'regular' | 'special' | 'demo';
          status: 'scheduled' | 'in_progress' | 'completed' | 'cancelled';
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          club_id: string;
          title: string;
          date: string;
          start_time: string;
          end_time: string;
          meeting_type?: 'regular' | 'special' | 'demo';
          status?: 'scheduled' | 'in_progress' | 'completed' | 'cancelled';
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          club_id?: string;
          title?: string;
          date?: string;
          start_time?: string;
          end_time?: string;
          meeting_type?: 'regular' | 'special' | 'demo';
          status?: 'scheduled' | 'in_progress' | 'completed' | 'cancelled';
          created_at?: string;
          updated_at?: string;
        };
      };
      speeches: {
        Row: {
          id: string;
          meeting_id: string;
          user_id: string;
          title: string;
          manual: string;
          project_number: number;
          objectives: string[];
          duration_minutes: number;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          meeting_id: string;
          user_id: string;
          title: string;
          manual: string;
          project_number: number;
          objectives: string[];
          duration_minutes: number;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          meeting_id?: string;
          user_id?: string;
          title?: string;
          manual?: string;
          project_number?: number;
          objectives?: string[];
          duration_minutes?: number;
          created_at?: string;
          updated_at?: string;
        };
      };
      meeting_roles: {
        Row: {
          id: string;
          meeting_id: string;
          user_id: string | null;
          role_type: 'toastmaster' | 'evaluator' | 'timer' | 'grammarian' | 'ah_counter' | 'table_topics_master';
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          meeting_id: string;
          user_id?: string | null;
          role_type: 'toastmaster' | 'evaluator' | 'timer' | 'grammarian' | 'ah_counter' | 'table_topics_master';
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          meeting_id?: string;
          user_id?: string | null;
          role_type?: 'toastmaster' | 'evaluator' | 'timer' | 'grammarian' | 'ah_counter' | 'table_topics_master';
          created_at?: string;
          updated_at?: string;
        };
      };
    };
  };
};