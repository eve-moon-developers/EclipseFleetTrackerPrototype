--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

-- Started on 2017-01-14 10:02:36

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
-- TOC entry 2151 (class 0 OID 0)
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
-- TOC entry 2152 (class 0 OID 0)
-- Dependencies: 189
-- Name: characters_character_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fleettool
--

ALTER SEQUENCE characters_character_id_seq OWNED BY characters.character_id;


--
-- TOC entry 186 (class 1259 OID 16400)
-- Name: fleets; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE fleets (
    fleet_id integer NOT NULL,
    fc_character_id integer,
    title character(128),
    importance integer,
    description text,
    composition text
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
-- TOC entry 2153 (class 0 OID 0)
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
    modified timestamp with time zone
);


ALTER TABLE logins OWNER TO fleettool;

--
-- TOC entry 187 (class 1259 OID 16403)
-- Name: paps; Type: TABLE; Schema: public; Owner: fleettool
--

CREATE TABLE paps (
);


ALTER TABLE paps OWNER TO fleettool;

--
-- TOC entry 2016 (class 2604 OID 16447)
-- Name: characters character_id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY characters ALTER COLUMN character_id SET DEFAULT nextval('characters_character_id_seq'::regclass);


--
-- TOC entry 2017 (class 2604 OID 16461)
-- Name: fleets fleet_id; Type: DEFAULT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets ALTER COLUMN fleet_id SET DEFAULT nextval('fleets_fleet_id_seq'::regclass);


--
-- TOC entry 2019 (class 2606 OID 16452)
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (character_id);


--
-- TOC entry 2024 (class 2606 OID 16466)
-- Name: fleets fleet_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fleet_pkey PRIMARY KEY (fleet_id);


--
-- TOC entry 2026 (class 2606 OID 16432)
-- Name: logins login_pkey; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY logins
    ADD CONSTRAINT login_pkey PRIMARY KEY (username);


--
-- TOC entry 2021 (class 2606 OID 16474)
-- Name: characters name_unique; Type: CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT name_unique UNIQUE (name);


--
-- TOC entry 2022 (class 1259 OID 16472)
-- Name: fki_fc_id_constraint; Type: INDEX; Schema: public; Owner: fleettool
--

CREATE INDEX fki_fc_id_constraint ON fleets USING btree (fc_character_id);


--
-- TOC entry 2027 (class 2606 OID 16467)
-- Name: fleets fc_id_constraint; Type: FK CONSTRAINT; Schema: public; Owner: fleettool
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fc_id_constraint FOREIGN KEY (fc_character_id) REFERENCES characters(character_id);


-- Completed on 2017-01-14 10:02:36

--
-- PostgreSQL database dump complete
--

