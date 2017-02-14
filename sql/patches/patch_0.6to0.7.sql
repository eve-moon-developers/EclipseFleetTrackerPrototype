ALTER TABLE public.checkpoints
    ADD COLUMN creator integer;

UPDATE public.checkpoints SET creator=1;

ALTER TABLE public.checkpoints
    ALTER COLUMN creator SET NOT NULL;

ALTER TABLE public.checkpoints
    ADD CONSTRAINT creator_fkey FOREIGN KEY (creator)
    REFERENCES public.logins (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;
    
UPDATE public.fleets SET fleet_creator=1;

ALTER TABLE public.fleets
    ALTER COLUMN fleet_creator SET NOT NULL;

CREATE OR REPLACE VIEW public.checkpoint_count AS
 SELECT paps.checkpoint_id,
    count(*) AS count
   FROM paps
  GROUP BY paps.checkpoint_id;

CREATE OR REPLACE VIEW public.checkpoint_details AS
 SELECT checkpoints.checkpoint_id,
    checkpoints.description,
    checkpoints.creation_time,
    logins.username,
    checkpoint_count.count
   FROM checkpoints,
    checkpoint_count,
    logins
  WHERE checkpoints.creator = logins.id AND checkpoints.checkpoint_id = checkpoint_count.checkpoint_id
  ORDER BY checkpoints.creation_time;