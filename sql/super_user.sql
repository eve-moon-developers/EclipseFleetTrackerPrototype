-- Create the master user. Cannot be logged into.
INSERT INTO logins (username, hash, rank, created) 
    VALUES ('wcj', '', 100, now() at time zone 'utc');
