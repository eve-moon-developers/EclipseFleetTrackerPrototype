--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.5
-- Dumped by pg_dump version 9.5.5

-- Started on 2017-01-18 17:15:07 CST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12485)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2334 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 181 (class 1259 OID 16426)
-- Name: characters; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE characters (
    character_id integer NOT NULL,
    name character(128),
    last_reference timestamp without time zone
);


ALTER TABLE characters OWNER TO fleettool;

--
-- TOC entry 182 (class 1259 OID 16429)
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
-- TOC entry 183 (class 1259 OID 16438)
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
-- TOC entry 184 (class 1259 OID 16442)
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
-- TOC entry 2336 (class 0 OID 0)
-- Dependencies: 184
-- Name: characters_character_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE characters_character_id_seq OWNED BY characters.character_id;


--
-- TOC entry 185 (class 1259 OID 16444)
-- Name: checkpoints; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE checkpoints (
    checkpoint_id integer NOT NULL,
    fleet_id integer NOT NULL,
    "creation_time" timestamp without time zone NOT NULL,
    description text
);


ALTER TABLE checkpoints OWNER TO fleettool;

--
-- TOC entry 186 (class 1259 OID 16450)
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
-- TOC entry 2337 (class 0 OID 0)
-- Dependencies: 186
-- Name: checkpoints_checkpoint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE checkpoints_checkpoint_id_seq OWNED BY checkpoints.checkpoint_id;


--
-- TOC entry 187 (class 1259 OID 16452)
-- Name: fleet_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE fleet_categories (
    type_id integer NOT NULL,
    name character(128) NOT NULL,
    description text NOT NULL
);


ALTER TABLE fleet_categories OWNER TO fleettool;

--
-- TOC entry 188 (class 1259 OID 16458)
-- Name: fleet_catagories_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE fleet_catagories_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE fleet_catagories_type_id_seq OWNER TO fleettool;

--
-- TOC entry 2339 (class 0 OID 0)
-- Dependencies: 188
-- Name: fleet_catagories_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE fleet_catagories_type_id_seq OWNED BY fleet_categories.type_id;


--
-- TOC entry 189 (class 1259 OID 16460)
-- Name: fleet_checkpoints; Type: VIEW; Schema: public; Owner: fleettool
--

CREATE VIEW fleet_checkpoints AS
 SELECT fleets.fleet_id,
    count(checkpoints.checkpoint_id) AS count,
    max(checkpoints."creation_time") AS last_updated
   FROM (fleets
     LEFT JOIN checkpoints ON ((fleets.fleet_id = checkpoints.fleet_id)))
  GROUP BY fleets.fleet_id;


ALTER TABLE fleet_checkpoints OWNER TO fleettool;

--
-- TOC entry 190 (class 1259 OID 16464)
-- Name: paps; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE paps (
    pap_id bigint NOT NULL,
    character_id integer NOT NULL,
    checkpoint_id integer NOT NULL
);


ALTER TABLE paps OWNER TO fleettool;

--
-- TOC entry 191 (class 1259 OID 16467)
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
-- TOC entry 192 (class 1259 OID 16471)
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
-- TOC entry 193 (class 1259 OID 16475)
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
-- TOC entry 2343 (class 0 OID 0)
-- Dependencies: 193
-- Name: fleets_fleet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE fleets_fleet_id_seq OWNED BY fleets.fleet_id;


--
-- TOC entry 194 (class 1259 OID 16477)
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
-- TOC entry 195 (class 1259 OID 16480)
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
-- TOC entry 2344 (class 0 OID 0)
-- Dependencies: 195
-- Name: logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE logins_id_seq OWNED BY logins.id;


--
-- TOC entry 198 (class 1259 OID 16536)
-- Name: members_fleets; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE members_fleets (
    name character(128),
    character_id integer,
    fleet_participation bigint
);

ALTER TABLE ONLY members_fleets REPLICA IDENTITY NOTHING;


ALTER TABLE members_fleets OWNER TO fleettool;

--
-- TOC entry 199 (class 1259 OID 16540)
-- Name: members_paps; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE members_paps (
    character_id integer,
    name character(128),
    pap_count bigint
);

ALTER TABLE ONLY members_paps REPLICA IDENTITY NOTHING;


ALTER TABLE members_paps OWNER TO fleettool;

--
-- TOC entry 200 (class 1259 OID 16544)
-- Name: members_summary; Type: VIEW; Schema: public; Owner: fleettool
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


ALTER TABLE members_summary OWNER TO fleettool;

--
-- TOC entry 196 (class 1259 OID 16482)
-- Name: pap_count; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE pap_count (
    name character(128),
    pap_count bigint
);

ALTER TABLE ONLY pap_count REPLICA IDENTITY NOTHING;


ALTER TABLE pap_count OWNER TO fleettool;

--
-- TOC entry 197 (class 1259 OID 16485)
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
-- TOC entry 2348 (class 0 OID 0)
-- Dependencies: 197
-- Name: paps_pap_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE paps_pap_id_seq OWNED BY paps.pap_id;


--
-- TOC entry 2174 (class 2604 OID 16487)
-- Name: character_id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY characters ALTER COLUMN character_id SET DEFAULT nextval('characters_character_id_seq'::regclass);


--
-- TOC entry 2179 (class 2604 OID 16488)
-- Name: checkpoint_id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY checkpoints ALTER COLUMN checkpoint_id SET DEFAULT nextval('checkpoints_checkpoint_id_seq'::regclass);


--
-- TOC entry 2180 (class 2604 OID 16489)
-- Name: type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fleet_categories ALTER COLUMN type_id SET DEFAULT nextval('fleet_catagories_type_id_seq'::regclass);


--
-- TOC entry 2178 (class 2604 OID 16490)
-- Name: fleet_id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets ALTER COLUMN fleet_id SET DEFAULT nextval('fleets_fleet_id_seq'::regclass);


--
-- TOC entry 2182 (class 2604 OID 16491)
-- Name: id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY logins ALTER COLUMN id SET DEFAULT nextval('logins_id_seq'::regclass);


--
-- TOC entry 2181 (class 2604 OID 16492)
-- Name: pap_id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY paps ALTER COLUMN pap_id SET DEFAULT nextval('paps_pap_id_seq'::regclass);


--
-- TOC entry 2184 (class 2606 OID 16494)
-- Name: characters_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (character_id);


--
-- TOC entry 2193 (class 2606 OID 16496)
-- Name: checkpoints_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY checkpoints
    ADD CONSTRAINT checkpoints_pkey PRIMARY KEY (checkpoint_id);


--
-- TOC entry 2195 (class 2606 OID 16498)
-- Name: fleet_catagories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fleet_categories
    ADD CONSTRAINT fleet_catagories_pkey PRIMARY KEY (type_id);


--
-- TOC entry 2191 (class 2606 OID 16500)
-- Name: fleet_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fleet_pkey PRIMARY KEY (fleet_id);


--
-- TOC entry 2199 (class 2606 OID 16502)
-- Name: id_unique; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY logins
    ADD CONSTRAINT id_unique UNIQUE (id);


--
-- TOC entry 2201 (class 2606 OID 16504)
-- Name: login_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY logins
    ADD CONSTRAINT login_pkey PRIMARY KEY (username);


--
-- TOC entry 2186 (class 2606 OID 16506)
-- Name: name_unique; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT name_unique UNIQUE (name);


--
-- TOC entry 2197 (class 2606 OID 16508)
-- Name: paps_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY paps
    ADD CONSTRAINT paps_pkey PRIMARY KEY (pap_id);


--
-- TOC entry 2187 (class 1259 OID 16509)
-- Name: fki_creator_id_constraint; Type: INDEX; Schema: public; Owner: fleettool
--

CREATE INDEX fki_creator_id_constraint ON fleets USING btree (fleet_creator);


--
-- TOC entry 2188 (class 1259 OID 16510)
-- Name: fki_fc_id_constraint; Type: INDEX; Schema: public; Owner: fleettool
--

CREATE INDEX fki_fc_id_constraint ON fleets USING btree (fc_character_id);


--
-- TOC entry 2189 (class 1259 OID 16511)
-- Name: fki_fleet_type_fkey; Type: INDEX; Schema: public; Owner: fleettool
--

CREATE INDEX fki_fleet_type_fkey ON fleets USING btree (fleet_type);


--
-- TOC entry 2323 (class 2618 OID 16512)
-- Name: _RETURN; Type: RULE; Schema: public; Owner: fleettool
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
-- TOC entry 2324 (class 2618 OID 16539)
-- Name: _RETURN; Type: RULE; Schema: public; Owner: fleettool
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
-- TOC entry 2325 (class 2618 OID 16543)
-- Name: _RETURN; Type: RULE; Schema: public; Owner: fleettool
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
-- TOC entry 2202 (class 2606 OID 16513)
-- Name: creator_id_constraint; Type: FK CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT creator_id_constraint FOREIGN KEY (fleet_creator) REFERENCES logins(id);


--
-- TOC entry 2203 (class 2606 OID 16518)
-- Name: fc_id_constraint; Type: FK CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fc_id_constraint FOREIGN KEY (fc_character_id) REFERENCES characters(character_id);


--
-- TOC entry 2204 (class 2606 OID 16523)
-- Name: fleet_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fleet_type_fkey FOREIGN KEY (fleet_type) REFERENCES fleet_categories(type_id);


--
-- TOC entry 2333 (class 0 OID 0)
-- Dependencies: 7
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO fleettool;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- TOC entry 2335 (class 0 OID 0)
-- Dependencies: 183
-- Name: basic_fleets; Type: ACL; Schema: public; Owner: fleettool
--

REVOKE ALL ON TABLE basic_fleets FROM PUBLIC;
REVOKE ALL ON TABLE basic_fleets FROM fleettool;
GRANT ALL ON TABLE basic_fleets TO fleettool;
GRANT ALL ON TABLE basic_fleets TO PUBLIC;


--
-- TOC entry 2338 (class 0 OID 0)
-- Dependencies: 187
-- Name: fleet_categories; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE fleet_categories FROM PUBLIC;
REVOKE ALL ON TABLE fleet_categories FROM postgres;
GRANT ALL ON TABLE fleet_categories TO fleettool;
GRANT ALL ON TABLE fleet_categories TO fleettool;


--
-- TOC entry 2340 (class 0 OID 0)
-- Dependencies: 189
-- Name: fleet_checkpoints; Type: ACL; Schema: public; Owner: fleettool
--

REVOKE ALL ON TABLE fleet_checkpoints FROM PUBLIC;
REVOKE ALL ON TABLE fleet_checkpoints FROM fleettool;
GRANT ALL ON TABLE fleet_checkpoints TO fleettool;
GRANT ALL ON TABLE fleet_checkpoints TO PUBLIC;


--
-- TOC entry 2341 (class 0 OID 0)
-- Dependencies: 191
-- Name: fleet_participation; Type: ACL; Schema: public; Owner: fleettool
--

REVOKE ALL ON TABLE fleet_participation FROM PUBLIC;
REVOKE ALL ON TABLE fleet_participation FROM fleettool;
GRANT ALL ON TABLE fleet_participation TO fleettool;
GRANT ALL ON TABLE fleet_participation TO PUBLIC;


--
-- TOC entry 2342 (class 0 OID 0)
-- Dependencies: 192
-- Name: fleet_summary; Type: ACL; Schema: public; Owner: fleettool
--

REVOKE ALL ON TABLE fleet_summary FROM PUBLIC;
REVOKE ALL ON TABLE fleet_summary FROM fleettool;
GRANT ALL ON TABLE fleet_summary TO fleettool;
GRANT ALL ON TABLE fleet_summary TO PUBLIC;


--
-- TOC entry 2345 (class 0 OID 0)
-- Dependencies: 198
-- Name: members_fleets; Type: ACL; Schema: public; Owner: fleettool
--

REVOKE ALL ON TABLE members_fleets FROM PUBLIC;
REVOKE ALL ON TABLE members_fleets FROM fleettool;
GRANT ALL ON TABLE members_fleets TO fleettool;
GRANT ALL ON TABLE members_fleets TO PUBLIC;


--
-- TOC entry 2346 (class 0 OID 0)
-- Dependencies: 199
-- Name: members_paps; Type: ACL; Schema: public; Owner: fleettool
--

REVOKE ALL ON TABLE members_paps FROM PUBLIC;
REVOKE ALL ON TABLE members_paps FROM fleettool;
GRANT ALL ON TABLE members_paps TO fleettool;
GRANT ALL ON TABLE members_paps TO PUBLIC;


--
-- TOC entry 2347 (class 0 OID 0)
-- Dependencies: 196
-- Name: pap_count; Type: ACL; Schema: public; Owner: fleettool
--

REVOKE ALL ON TABLE pap_count FROM PUBLIC;
REVOKE ALL ON TABLE pap_count FROM fleettool;
GRANT ALL ON TABLE pap_count TO fleettool;
GRANT ALL ON TABLE pap_count TO PUBLIC;


-- Completed on 2017-01-18 17:15:07 CST

--
-- PostgreSQL database dump complete
--

