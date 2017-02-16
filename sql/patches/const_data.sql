--Create the fleet descriptions.
INSERT INTO fleet_categories (name, description)
    VALUES ('Strat Op', 'A fleet of the highest priority ordered by senior leadership.');
INSERT INTO fleet_categories (name, description)
    VALUES ('Offensive Fleet', 'A fleet with a targetted mission of agression against another entity.');
INSERT INTO fleet_categories (name, description)
    VALUES ('Defense Fleet', 'A fleet to defend MOON or allied assets, space, or members.');
INSERT INTO fleet_categories (name, description)
    VALUES ('Response Fleet', 'A fleet formed in response to an act of agression by another entity.');
INSERT INTO fleet_categories (name, description)
    VALUES ('Roaming Fleet', 'A fleet formed to seek out and engage other entities.');
INSERT INTO fleet_categories (name, description)
    VALUES ('Standing Fleet', 'A fleet formed for standard in pocket operations.');
INSERT INTO fleet_categories (name, description)
    VALUES ('PVE Fleet', 'A fleet formed to facilitate PVE.');
INSERT INTO fleet_categories (name, description)
    VALUES ('Indy Fleet', 'A fleet formed to facilitate industry or mining.');
INSERT INTO fleet_categories (name, description)
    VALUES ('Logistics Fleet', 'A fleet formed to facilitate logistics.');
INSERT INTO fleet_categories (name, description)
    VALUES ('Other', 'A fleet formed for some other reason. Please specify clearly in the description.');

--Create the ranks.
INSERT INTO user_ranks (rank_id, name, description)
    VALUES (1, 'Observer', 'A read only user.');
INSERT INTO user_ranks (rank_id, name, description)
    VALUES (2, 'Trainee', 'Can create fleets. Can update fleets they created.');
INSERT INTO user_ranks (rank_id, name, description)
    VALUES (3, 'JrFC', 'Can create fleets. Can update fleets they created.');
INSERT INTO user_ranks (rank_id, name, description)
    VALUES (5, 'FC', 'Can create fleets. Can update ANY fleet. Can delete their own fleets.');
INSERT INTO user_ranks (rank_id, name, description)
    VALUES (6, 'Tech', 'Can create fleets. Can update ANY fleet. Can delete their own fleets. Acts as a reported for the fleet so the FC doesn\'t have to.');
INSERT INTO user_ranks (rank_id, name, description)
    VALUES (7, 'Officer', 'Can create fleets. Can update ANY fleet. Can delete their own fleets.');
INSERT INTO user_ranks (rank_id, name, description)
    VALUES (9, 'SrFC', 'Can create fleets. Can update ANY fleet. Can delete ANY fleet.');
INSERT INTO user_ranks (rank_id, name, description)
    VALUES (10, 'Skymarshal', 'Can create fleets. Can update ANY fleet. Can delete ANY fleet. Can add / edit users.');
INSERT INTO user_ranks (rank_id, name, description)
    VALUES (25, 'Admin', 'Can create fleets. Can update ANY fleet. Can delete ANY fleet. Can add / edit users.');
INSERT INTO user_ranks (rank_id, name, description)
    VALUES (100, 'Super-Admin', 'Can create fleets. Can update ANY fleet. Can delete ANY fleet. Can add / edit admins.');