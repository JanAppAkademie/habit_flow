CREATE TABLE public.habits (
  id text PRIMARY KEY,
  device_id text,
  name text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  completed_today boolean NOT NULL DEFAULT false,
  completed_dates jsonb NOT NULL DEFAULT '[]'::jsonb,
  last_completed_at timestamptz,
  needs_sync boolean NOT NULL DEFAULT false
);

CREATE INDEX idx_habits_device_id ON public.habits (device_id);
CREATE INDEX idx_habits_updated_at ON public.habits (updated_at);
CREATE INDEX idx_habits_needs_sync ON public.habits (needs_sync);
CREATE INDEX idx_habits_completed_dates_gin ON public.habits USING gin (completed_dates jsonb_path_ops);