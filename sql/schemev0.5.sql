--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

-- Started on 2017-01-18 14:42:15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 185 (class 1259 OID 16538)
-- Name: characters; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE characters (
    character_id integer NOT NULL,
    name character(128),
    last_reference timestamp without time zone
);


ALTER TABLE characters OWNER TO fleettool;

--
-- TOC entry 189 (class 1259 OID 16551)
-- Name: fleets; Type: TABLE; Schema: public; Owner: fleettool
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
    fleet_creator integer
);


ALTER TABLE fleets OWNER TO fleettool;

--
-- TOC entry 195 (class 1259 OID 16683)
-- Name: basic_fleets; Type: VIEW; Schema: public; Owner: fleettool
--

CREATE VIEW basic_fleets AS
 SELECT fleets.fleet_id,
    characters.name AS fc_name,
    fleets.title AS fleet_title
   FROM fleets,
    characters
  WHERE (fleets.fc_character_id = characters.character_id);


ALTER TABLE basic_fleets OWNER TO fleettool;

--
-- TOC entry 186 (class 1259 OID 16541)
-- Name: characters_character_id_seq; Type: SEQUENCE; Schema: public; Owner: fleettool
--

CREATE SEQUENCE characters_character_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE characters_character_id_seq OWNER TO fleettool;

--
-- TOC entry 2213 (class 0 OID 0)
-- Dependencies: 186
-- Name: characters_character_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE characters_character_id_seq OWNED BY characters.character_id;


--
-- TOC entry 193 (class 1259 OID 16669)
-- Name: checkpoints; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE checkpoints (
    checkpoint_id integer NOT NULL,
    fleet_id integer NOT NULL,
    "time" time without time zone NOT NULL,
    description text
);


ALTER TABLE checkpoints OWNER TO fleettool;

--
-- TOC entry 194 (class 1259 OID 16672)
-- Name: checkpoints_checkpoint_id_seq; Type: SEQUENCE; Schema: public; Owner: fleettool
--

CREATE SEQUENCE checkpoints_checkpoint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE checkpoints_checkpoint_id_seq OWNER TO fleettool;

--
-- TOC entry 2214 (class 0 OID 0)
-- Dependencies: 194
-- Name: checkpoints_checkpoint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE checkpoints_checkpoint_id_seq OWNED BY checkpoints.checkpoint_id;


--
-- TOC entry 187 (class 1259 OID 16543)
-- Name: fleet_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE fleet_categories (
    type_id integer NOT NULL,
    name character(128) NOT NULL,
    description text NOT NULL
);


ALTER TABLE fleet_categories OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 16549)
-- Name: fleet_catagories_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE fleet_catagories_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE fleet_catagories_type_id_seq OWNER TO postgres;

--
-- TOC entry 2216 (class 0 OID 0)
-- Dependencies: 188
-- Name: fleet_catagories_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE fleet_catagories_type_id_seq OWNED BY fleet_categories.type_id;


--
-- TOC entry 200 (class 1259 OID 16726)
-- Name: fleet_checkpoints; Type: VIEW; Schema: public; Owner: fleettool
--

CREATE VIEW fleet_checkpoints AS
 SELECT fleets.fleet_id,
    count(checkpoints.checkpoint_id) AS count,
    max(checkpoints."time") AS last_updated
   FROM (fleets
     LEFT JOIN checkpoints ON ((fleets.fleet_id = checkpoints.fleet_id)))
  GROUP BY fleets.fleet_id;


ALTER TABLE fleet_checkpoints OWNER TO fleettool;

--
-- TOC entry 197 (class 1259 OID 16695)
-- Name: paps; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE paps (
    pap_id bigint NOT NULL,
    character_id integer NOT NULL,
    checkpoint_id integer NOT NULL
);


ALTER TABLE paps OWNER TO fleettool;

--
-- TOC entry 199 (class 1259 OID 16718)
-- Name: fleet_participation; Type: VIEW; Schema: public; Owner: fleettool
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


ALTER TABLE fleet_participation OWNER TO fleettool;

--
-- TOC entry 201 (class 1259 OID 16734)
-- Name: fleet_summary; Type: VIEW; Schema: public; Owner: fleettool
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


ALTER TABLE fleet_summary OWNER TO fleettool;

--
-- TOC entry 190 (class 1259 OID 16560)
-- Name: fleets_fleet_id_seq; Type: SEQUENCE; Schema: public; Owner: fleettool
--

CREATE SEQUENCE fleets_fleet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE fleets_fleet_id_seq OWNER TO fleettool;

--
-- TOC entry 2217 (class 0 OID 0)
-- Dependencies: 190
-- Name: fleets_fleet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE fleets_fleet_id_seq OWNED BY fleets.fleet_id;


--
-- TOC entry 191 (class 1259 OID 16562)
-- Name: logins; Type: TABLE; Schema: public; Owner: fleettool
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


ALTER TABLE logins OWNER TO fleettool;

--
-- TOC entry 192 (class 1259 OID 16565)
-- Name: logins_id_seq; Type: SEQUENCE; Schema: public; Owner: fleettool
--

CREATE SEQUENCE logins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE logins_id_seq OWNER TO fleettool;

--
-- TOC entry 2218 (class 0 OID 0)
-- Dependencies: 192
-- Name: logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE logins_id_seq OWNED BY logins.id;


--
-- TOC entry 198 (class 1259 OID 16702)
-- Name: pap_count; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE pap_count (
    name character(128),
    pap_count bigint
);

ALTER TABLE ONLY pap_count REPLICA IDENTITY NOTHING;


ALTER TABLE pap_count OWNER TO fleettool;

--
-- TOC entry 196 (class 1259 OID 16693)
-- Name: paps_pap_id_seq; Type: SEQUENCE; Schema: public; Owner: fleettool
--

CREATE SEQUENCE paps_pap_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE paps_pap_id_seq OWNER TO fleettool;

--
-- TOC entry 2219 (class 0 OID 0)
-- Dependencies: 196
-- Name: paps_pap_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE paps_pap_id_seq OWNED BY paps.pap_id;


--
-- TOC entry 2054 (class 2604 OID 16570)
-- Name: characters character_id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY characters ALTER COLUMN character_id SET DEFAULT nextval('characters_character_id_seq'::regclass);


--
-- TOC entry 2061 (class 2604 OID 16674)
-- Name: checkpoints checkpoint_id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY checkpoints ALTER COLUMN checkpoint_id SET DEFAULT nextval('checkpoints_checkpoint_id_seq'::regclass);


--
-- TOC entry 2055 (class 2604 OID 16571)
-- Name: fleet_categories type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fleet_categories ALTER COLUMN type_id SET DEFAULT nextval('fleet_catagories_type_id_seq'::regclass);


--
-- TOC entry 2059 (class 2604 OID 16572)
-- Name: fleets fleet_id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets ALTER COLUMN fleet_id SET DEFAULT nextval('fleets_fleet_id_seq'::regclass);


--
-- TOC entry 2060 (class 2604 OID 16573)
-- Name: logins id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY logins ALTER COLUMN id SET DEFAULT nextval('logins_id_seq'::regclass);


--
-- TOC entry 2062 (class 2604 OID 16698)
-- Name: paps pap_id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY paps ALTER COLUMN pap_id SET DEFAULT nextval('paps_pap_id_seq'::regclass);


--
-- TOC entry 2064 (class 2606 OID 16575)
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (character_id);


--
-- TOC entry 2079 (class 2606 OID 16682)
-- Name: checkpoints checkpoints_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY checkpoints
    ADD CONSTRAINT checkpoints_pkey PRIMARY KEY (checkpoint_id);


--
-- TOC entry 2068 (class 2606 OID 16577)
-- Name: fleet_categories fleet_catagories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fleet_categories
    ADD CONSTRAINT fleet_catagories_pkey PRIMARY KEY (type_id);


--
-- TOC entry 2073 (class 2606 OID 16579)
-- Name: fleets fleet_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fleet_pkey PRIMARY KEY (fleet_id);


--
-- TOC entry 2075 (class 2606 OID 16581)
-- Name: logins id_unique; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY logins
    ADD CONSTRAINT id_unique UNIQUE (id);


--
-- TOC entry 2077 (class 2606 OID 16583)
-- Name: logins login_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY logins
    ADD CONSTRAINT login_pkey PRIMARY KEY (username);


--
-- TOC entry 2066 (class 2606 OID 16585)
-- Name: characters name_unique; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT name_unique UNIQUE (name);


--
-- TOC entry 2081 (class 2606 OID 16700)
-- Name: paps paps_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY paps
    ADD CONSTRAINT paps_pkey PRIMARY KEY (pap_id);


--
-- TOC entry 2069 (class 1259 OID 16586)
-- Name: fki_creator_id_constraint; Type: INDEX; Schema: public; Owner: fleettool
--

CREATE INDEX fki_creator_id_constraint ON fleets USING btree (fleet_creator);


--
-- TOC entry 2070 (class 1259 OID 16587)
-- Name: fki_fc_id_constraint; Type: INDEX; Schema: public; Owner: fleettool
--

CREATE INDEX fki_fc_id_constraint ON fleets USING btree (fc_character_id);


--
-- TOC entry 2071 (class 1259 OID 16603)
-- Name: fki_fleet_type_fkey; Type: INDEX; Schema: public; Owner: fleettool
--

CREATE INDEX fki_fleet_type_fkey ON fleets USING btree (fleet_type);


--
-- TOC entry 2203 (class 2618 OID 16705)
-- Name: pap_count _RETURN; Type: RULE; Schema: public; Owner: fleettool
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
-- TOC entry 2082 (class 2606 OID 16588)
-- Name: fleets creator_id_constraint; Type: FK CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT creator_id_constraint FOREIGN KEY (fleet_creator) REFERENCES logins(id);


--
-- TOC entry 2083 (class 2606 OID 16593)
-- Name: fleets fc_id_constraint; Type: FK CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fc_id_constraint FOREIGN KEY (fc_character_id) REFERENCES characters(character_id);


--
-- TOC entry 2084 (class 2606 OID 16598)
-- Name: fleets fleet_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fleet_type_fkey FOREIGN KEY (fleet_type) REFERENCES fleet_categories(type_id);


--
-- TOC entry 2212 (class 0 OID 0)
-- Dependencies: 3
-- Name: public; Type: ACL; Schema: -; Owner: fleettool
--

REVOKE ALL ON SCHEMA public FROM postgres;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO fleettool;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 2215 (class 0 OID 0)
-- Dependencies: 187
-- Name: fleet_categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE fleet_categories TO fleettool;


-- Completed on 2017-01-18 14:42:15

--
-- PostgreSQL database dump complete
--

