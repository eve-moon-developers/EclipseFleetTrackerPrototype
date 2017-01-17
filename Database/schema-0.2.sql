--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

-- Started on 2017-01-17 15:24:23

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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2171 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 185 (class 1259 OID 16397)
-- Name: characters; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE characters (
    character_id integer NOT NULL,
    name character(128),
    last_reference timestamp without time zone
);


ALTER TABLE characters OWNER TO fleettool;

--
-- TOC entry 189 (class 1259 OID 16445)
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
-- TOC entry 2172 (class 0 OID 0)
-- Dependencies: 189
-- Name: characters_character_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE characters_character_id_seq OWNED BY characters.character_id;


--
-- TOC entry 193 (class 1259 OID 16528)
-- Name: fleet_catagories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE fleet_catagories (
    type_id integer NOT NULL,
    name character(128) NOT NULL,
    description text NOT NULL
);


ALTER TABLE fleet_catagories OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 16526)
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
-- TOC entry 2173 (class 0 OID 0)
-- Dependencies: 192
-- Name: fleet_catagories_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE fleet_catagories_type_id_seq OWNED BY fleet_catagories.type_id;


--
-- TOC entry 186 (class 1259 OID 16400)
-- Name: fleets; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE fleets (
    fleet_id integer NOT NULL,
    fc_character_id integer,
    title character(128) NOT NULL,
    importance integer,
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
-- TOC entry 190 (class 1259 OID 16459)
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
-- TOC entry 2174 (class 0 OID 0)
-- Dependencies: 190
-- Name: fleets_fleet_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE fleets_fleet_id_seq OWNED BY fleets.fleet_id;


--
-- TOC entry 188 (class 1259 OID 16406)
-- Name: logins; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE logins (
    username character(128) NOT NULL,
    hash character(60) NOT NULL,
    rank integer,
    created timestamp with time zone,
    modified timestamp with time zone,
    id integer NOT NULL
);


ALTER TABLE logins OWNER TO fleettool;

--
-- TOC entry 191 (class 1259 OID 16485)
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
-- TOC entry 2175 (class 0 OID 0)
-- Dependencies: 191
-- Name: logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE logins_id_seq OWNED BY logins.id;


--
-- TOC entry 187 (class 1259 OID 16403)
-- Name: paps; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE paps (
);


ALTER TABLE paps OWNER TO fleettool;

--
-- TOC entry 2025 (class 2604 OID 16447)
-- Name: characters character_id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY characters ALTER COLUMN character_id SET DEFAULT nextval('characters_character_id_seq'::regclass);


--
-- TOC entry 2031 (class 2604 OID 16531)
-- Name: fleet_catagories type_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fleet_catagories ALTER COLUMN type_id SET DEFAULT nextval('fleet_catagories_type_id_seq'::regclass);


--
-- TOC entry 2026 (class 2604 OID 16461)
-- Name: fleets fleet_id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets ALTER COLUMN fleet_id SET DEFAULT nextval('fleets_fleet_id_seq'::regclass);


--
-- TOC entry 2030 (class 2604 OID 16487)
-- Name: logins id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY logins ALTER COLUMN id SET DEFAULT nextval('logins_id_seq'::regclass);


--
-- TOC entry 2033 (class 2606 OID 16452)
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (character_id);


--
-- TOC entry 2045 (class 2606 OID 16536)
-- Name: fleet_catagories fleet_catagories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY fleet_catagories
    ADD CONSTRAINT fleet_catagories_pkey PRIMARY KEY (type_id);


--
-- TOC entry 2039 (class 2606 OID 16466)
-- Name: fleets fleet_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fleet_pkey PRIMARY KEY (fleet_id);


--
-- TOC entry 2041 (class 2606 OID 16493)
-- Name: logins id_unique; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY logins
    ADD CONSTRAINT id_unique UNIQUE (id);


--
-- TOC entry 2043 (class 2606 OID 16432)
-- Name: logins login_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY logins
    ADD CONSTRAINT login_pkey PRIMARY KEY (username);


--
-- TOC entry 2035 (class 2606 OID 16474)
-- Name: characters name_unique; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT name_unique UNIQUE (name);


--
-- TOC entry 2036 (class 1259 OID 16499)
-- Name: fki_creator_id_constraint; Type: INDEX; Schema: public; Owner: fleettool
--

CREATE INDEX fki_creator_id_constraint ON fleets USING btree (fleet_creator);


--
-- TOC entry 2037 (class 1259 OID 16472)
-- Name: fki_fc_id_constraint; Type: INDEX; Schema: public; Owner: fleettool
--

CREATE INDEX fki_fc_id_constraint ON fleets USING btree (fc_character_id);


--
-- TOC entry 2047 (class 2606 OID 16494)
-- Name: fleets creator_id_constraint; Type: FK CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT creator_id_constraint FOREIGN KEY (fleet_creator) REFERENCES logins(id);


--
-- TOC entry 2046 (class 2606 OID 16467)
-- Name: fleets fc_id_constraint; Type: FK CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fc_id_constraint FOREIGN KEY (fc_character_id) REFERENCES characters(character_id);


-- Completed on 2017-01-17 15:24:23

--
-- PostgreSQL database dump complete
--

