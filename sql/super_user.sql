-- Create the master user. Cannot be logged into.
INSERT INTO logins (username, hash, rank, created) 
    VALUES ('root', '', 100, now() at time zone 'utc');
