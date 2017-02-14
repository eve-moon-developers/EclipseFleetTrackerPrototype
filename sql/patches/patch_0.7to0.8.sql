ALTER TABLE fleets ALTER COLUMN creation_time type timestamp with time zone USING creation_time AT TIME ZONE 'UTC';
ALTER TABLE fleets ALTER COLUMN update_time type timestamp with time zone USING update_time AT TIME ZONE 'UTC';

DROP VIEW fleet_summary;
DROP VIEW fleet_checkpoints;
DROP VIEW checkpoint_details;

ALTER TABLE checkpoints ALTER COLUMN creation_time type timestamp with time zone USING creation_time AT TIME ZONE 'UTC';

CREATE VIEW public.fleet_checkpoints AS
 SELECT fleets.fleet_id,
    count(checkpoints.checkpoint_id) AS count,
    max(checkpoints.creation_time) AS last_updated
   FROM fleets
     LEFT JOIN checkpoints ON fleets.fleet_id = checkpoints.fleet_id
  GROUP BY fleets.fleet_id;

CREATE VIEW checkpoint_details AS
 SELECT checkpoints.fleet_id,
    checkpoints.checkpoint_id,
    checkpoints.description,
    checkpoints.creation_time,
    logins.username,
    checkpoint_count.count
   FROM checkpoints,
    checkpoint_count,
    logins
  WHERE checkpoints.creator = logins.id AND checkpoints.checkpoint_id = checkpoint_count.checkpoint_id
  ORDER BY checkpoints.creation_time;
  
CREATE VIEW fleet_summary AS
 SELECT fleets.fleet_id AS id,
    characters.name AS fc,
    fleets.title,
    fleet_checkpoints.count AS checkpoints,
    fleet_checkpoints.last_updated,
    fleet_participation.count AS members
   FROM fleets,
    characters,
    fleet_checkpoints,
    fleet_participation
  WHERE ((fleets.fc_character_id = characters.character_id) AND (fleets.fleet_id = fleet_checkpoints.fleet_id) AND (fleets.fleet_id = fleet_participation.fleet_id));

