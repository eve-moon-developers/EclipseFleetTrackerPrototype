--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

-- Started on 2017-02-14 02:37:12

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12387)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2246 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_with_oids = false;

--
-- TOC entry 185 (class 1259 OID 16739)
-- Name: characters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE characters (
    character_id integer NOT NULL,
    name character(128),
    last_reference timestamp without time zone
);


--
-- TOC entry 186 (class 1259 OID 16742)
-- Name: fleets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE fleets (
    fleet_id integer NOT NULL,
    fc_character_id integer,
    title character(128) NOT NULL,
    fleet_type integer,
    description text,
    composition text,
    creation_time timestamp without time zone DEFAULT timezone('utc'::text, now()),
    update_time timestamp without time zone,
    member_count integer DEFAULT 0,
    update_count integer DEFAULT 0,
    fleet_creator integer NOT NULL
);


--
-- TOC entry 187 (class 1259 OID 16751)
-- Name: basic_fleets; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW basic_fleets AS
 SELECT fleets.fleet_id,
    characters.name AS fc_name,
    fleets.title AS fleet_title
   FROM fleets,
    characters
  WHERE (fleets.fc_character_id = characters.character_id);


--
-- TOC entry 188 (class 1259 OID 16755)
-- Name: characters_character_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE characters_character_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2247 (class 0 OID 0)
-- Dependencies: 188
-- Name: characters_character_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE characters_character_id_seq OWNED BY characters.character_id;


--
-- TOC entry 194 (class 1259 OID 16777)
-- Name: paps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE paps (
    pap_id bigint NOT NULL,
    character_id integer NOT NULL,
    checkpoint_id integer NOT NULL
);


--
-- TOC entry 206 (class 1259 OID 16978)
-- Name: checkpoint_count; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW checkpoint_count AS
 SELECT paps.checkpoint_id,
    count(*) AS count
   FROM paps
  GROUP BY paps.checkpoint_id;


--
-- TOC entry 189 (class 1259 OID 16757)
-- Name: checkpoints; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE checkpoints (
    checkpoint_id integer NOT NULL,
    fleet_id integer NOT NULL,
    creation_time timestamp without time zone NOT NULL,
    description text,
    creator integer NOT NULL
);


--
-- TOC entry 198 (class 1259 OID 16790)
-- Name: logins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE logins (
    username character(128) NOT NULL,
    hash character(60) NOT NULL,
    rank integer,
    created timestamp with time zone,
    modified timestamp with time zone,
    id integer NOT NULL,
    last_login timestamp without time zone
);


--
-- TOC entry 207 (class 1259 OID 17011)
-- Name: checkpoint_details; Type: VIEW; Schema: public; Owner: -
--

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
  WHERE ((checkpoints.creator = logins.id) AND (checkpoints.checkpoint_id = checkpoint_count.checkpoint_id))
  ORDER BY checkpoints.creation_time;


--
-- TOC entry 190 (class 1259 OID 16763)
-- Name: checkpoints_checkpoint_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE checkpoints_checkpoint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2248 (class 0 OID 0)
-- Dependencies: 190
-- Name: checkpoints_checkpoint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE checkpoints_checkpoint_id_seq OWNED BY checkpoints.checkpoint_id;


--
-- TOC entry 191 (class 1259 OID 16765)
-- Name: fleet_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE fleet_categories (
    type_id integer NOT NULL,
    name character(128) NOT NULL,
    description text NOT NULL
);


--
-- TOC entry 192 (class 1259 OID 16771)
-- Name: fleet_catagories_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fleet_catagories_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2249 (class 0 OID 0)
-- Dependencies: 192
-- Name: fleet_catagories_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fleet_catagories_type_id_seq OWNED BY fleet_categories.type_id;


--
-- TOC entry 193 (class 1259 OID 16773)
-- Name: fleet_checkpoints; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW fleet_checkpoints AS
 SELECT fleets.fleet_id,
    count(checkpoints.checkpoint_id) AS count,
    max(checkpoints.creation_time) AS last_updated
   FROM (fleets
     LEFT JOIN checkpoints ON ((fleets.fleet_id = checkpoints.fleet_id)))
  GROUP BY fleets.fleet_id;


--
-- TOC entry 195 (class 1259 OID 16780)
-- Name: fleet_participation; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW fleet_participation AS
 SELECT fleets.fleet_id,
    count(uni_paps.character_id) AS count
   FROM (fleets
     LEFT JOIN ( SELECT DISTINCT checkpoints.fleet_id,
            paps.character_id
           FROM paps,
            checkpoints
          WHERE (paps.checkpoint_id = checkpoints.checkpoint_id)) uni_paps ON ((fleets.fleet_id = uni_paps.fleet_id)))
  GROUP BY fleets.fleet_id;


--
-- TOC entry 205 (class 1259 OID 16974)
-- Name: fleet_details; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW fleet_details AS
 SELECT fleets.fleet_id AS id,
    characters.name AS fc,
    fleets.title,
    fleets.description,
    fleets.creation_time,
    fleets.update_time,
    fleet_checkpoints.count AS checkpoints,
    fleet_checkpoints.last_updated,
    fleet_participation.count AS members,
    logins.username AS creator
   FROM fleets,
    characters,
    logins,
    fleet_checkpoints,
    fleet_participation
  WHERE ((fleets.fc_character_id = characters.character_id) AND (fleets.fleet_id = fleet_checkpoints.fleet_id) AND (fleets.fleet_id = fleet_participation.fleet_id) AND (fleets.fleet_creator = logins.id));


--
-- TOC entry 196 (class 1259 OID 16784)
-- Name: fleet_summary; Type: VIEW; Schema: public; Owner: -
--

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


--
-- TOC entry 197 (class 1259 OID 16788)
-- Name: fleets_fleet_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE fleets_fleet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2250 (class 0 OID 0)
-- Dependencies: 197
-- Name: fleets_fleet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE fleets_fleet_id_seq OWNED BY fleets.fleet_id;


--
-- TOC entry 199 (class 1259 OID 16793)
-- Name: logins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2251 (class 0 OID 0)
-- Dependencies: 199
-- Name: logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE logins_id_seq OWNED BY logins.id;


--
-- TOC entry 200 (class 1259 OID 16795)
-- Name: members_fleets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE members_fleets (
    name character(128),
    character_id integer,
    fleet_participation bigint
);

ALTER TABLE ONLY members_fleets REPLICA IDENTITY NOTHING;


--
-- TOC entry 201 (class 1259 OID 16798)
-- Name: members_paps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE members_paps (
    character_id integer,
    name character(128),
    pap_count bigint
);

ALTER TABLE ONLY members_paps REPLICA IDENTITY NOTHING;


--
-- TOC entry 202 (class 1259 OID 16801)
-- Name: members_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW members_summary AS
 SELECT characters.character_id,
    characters.name,
    members_paps.pap_count,
    members_fleets.fleet_participation
   FROM characters,
    members_paps,
    members_fleets
  WHERE ((characters.character_id = members_paps.character_id) AND (characters.character_id = members_fleets.character_id));


--
-- TOC entry 203 (class 1259 OID 16805)
-- Name: pap_count; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pap_count (
    name character(128),
    pap_count bigint
);

ALTER TABLE ONLY pap_count REPLICA IDENTITY NOTHING;


--
-- TOC entry 204 (class 1259 OID 16808)
-- Name: paps_pap_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE paps_pap_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2252 (class 0 OID 0)
-- Dependencies: 204
-- Name: paps_pap_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE paps_pap_id_seq OWNED BY paps.pap_id;


--
-- TOC entry 2079 (class 2604 OID 16810)
-- Name: characters character_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY characters ALTER COLUMN character_id SET DEFAULT nextval('characters_character_id_seq'::regclass);


--
-- TOC entry 2084 (class 2604 OID 16811)
-- Name: checkpoints checkpoint_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY checkpoints ALTER COLUMN checkpoint_id SET DEFAULT nextval('checkpoints_checkpoint_id_seq'::regclass);


--
-- TOC entry 2085 (class 2604 OID 16812)
-- Name: fleet_categories type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fleet_categories ALTER COLUMN type_id SET DEFAULT nextval('fleet_catagories_type_id_seq'::regclass);


--
-- TOC entry 2083 (class 2604 OID 16813)
-- Name: fleets fleet_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY fleets ALTER COLUMN fleet_id SET DEFAULT nextval('fleets_fleet_id_seq'::regclass);


--
-- TOC entry 2087 (class 2604 OID 16814)
-- Name: logins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY logins ALTER COLUMN id SET DEFAULT nextval('logins_id_seq'::regclass);


--
-- TOC entry 2086 (class 2604 OID 16815)
-- Name: paps pap_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY paps ALTER COLUMN pap_id SET DEFAULT nextval('paps_pap_id_seq'::regclass);


--
-- TOC entry 2089 (class 2606 OID 16817)
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (character_id);


--
-- TOC entry 2098 (class 2606 OID 16819)
-- Name: checkpoints checkpoints_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY checkpoints
    ADD CONSTRAINT checkpoints_pkey PRIMARY KEY (checkpoint_id);


--
-- TOC entry 2101 (class 2606 OID 16821)
-- Name: fleet_categories fleet_catagories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fleet_categories
    ADD CONSTRAINT fleet_catagories_pkey PRIMARY KEY (type_id);


--
-- TOC entry 2096 (class 2606 OID 16823)
-- Name: fleets fleet_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fleet_pkey PRIMARY KEY (fleet_id);


--
-- TOC entry 2105 (class 2606 OID 16825)
-- Name: logins id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY logins
    ADD CONSTRAINT id_unique UNIQUE (id);


--
-- TOC entry 2107 (class 2606 OID 16827)
-- Name: logins login_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY logins
    ADD CONSTRAINT login_pkey PRIMARY KEY (username);


--
-- TOC entry 2091 (class 2606 OID 16829)
-- Name: characters name_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT name_unique UNIQUE (name);


--
-- TOC entry 2103 (class 2606 OID 16831)
-- Name: paps paps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY paps
    ADD CONSTRAINT paps_pkey PRIMARY KEY (pap_id);


--
-- TOC entry 2099 (class 1259 OID 17001)
-- Name: fki_creator_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_creator_fkey ON checkpoints USING btree (creator);


--
-- TOC entry 2092 (class 1259 OID 16832)
-- Name: fki_creator_id_constraint; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_creator_id_constraint ON fleets USING btree (fleet_creator);


--
-- TOC entry 2093 (class 1259 OID 16833)
-- Name: fki_fc_id_constraint; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_fc_id_constraint ON fleets USING btree (fc_character_id);


--
-- TOC entry 2094 (class 1259 OID 16834)
-- Name: fki_fleet_type_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_fleet_type_fkey ON fleets USING btree (fleet_type);


--
-- TOC entry 2234 (class 2618 OID 16835)
-- Name: pap_count _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE RULE "_RETURN" AS
    ON SELECT TO pap_count DO INSTEAD  SELECT characters.name,
    count(*) AS pap_count
   FROM characters,
    paps
  WHERE (characters.character_id = paps.character_id)
  GROUP BY characters.character_id
  ORDER BY (count(*)) DESC;


--
-- TOC entry 2235 (class 2618 OID 16836)
-- Name: members_fleets _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE RULE "_RETURN" AS
    ON SELECT TO members_fleets DO INSTEAD  SELECT characters.name,
    characters.character_id,
    count(*) AS fleet_participation
   FROM ( SELECT DISTINCT checkpoints.fleet_id,
            paps.character_id
           FROM paps,
            checkpoints
          WHERE (paps.checkpoint_id = checkpoints.checkpoint_id)) fleet_participation,
    characters
  WHERE (fleet_participation.character_id = characters.character_id)
  GROUP BY characters.character_id;


--
-- TOC entry 2236 (class 2618 OID 16837)
-- Name: members_paps _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE RULE "_RETURN" AS
    ON SELECT TO members_paps DO INSTEAD  SELECT characters.character_id,
    characters.name,
    count(*) AS pap_count
   FROM characters,
    paps
  WHERE (paps.character_id = characters.character_id)
  GROUP BY characters.character_id;


--
-- TOC entry 2111 (class 2606 OID 17002)
-- Name: checkpoints creator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY checkpoints
    ADD CONSTRAINT creator_fkey FOREIGN KEY (creator) REFERENCES logins(id);


--
-- TOC entry 2108 (class 2606 OID 16838)
-- Name: fleets creator_id_constraint; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT creator_id_constraint FOREIGN KEY (fleet_creator) REFERENCES logins(id);


--
-- TOC entry 2109 (class 2606 OID 16843)
-- Name: fleets fc_id_constraint; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fc_id_constraint FOREIGN KEY (fc_character_id) REFERENCES characters(character_id);


--
-- TOC entry 2110 (class 2606 OID 16848)
-- Name: fleets fleet_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fleet_type_fkey FOREIGN KEY (fleet_type) REFERENCES fleet_categories(type_id);


-- Completed on 2017-02-14 02:37:12

--
-- PostgreSQL database dump complete
--

