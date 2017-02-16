--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: characters; Type: TABLE; Schema: public; Owner: wcj
--

CREATE TABLE characters (
    character_id integer NOT NULL,
    name character(128),
    last_reference timestamp without time zone
);


ALTER TABLE characters OWNER TO wcj;

--
-- Name: fleets_fleet_id_seq; Type: SEQUENCE; Schema: public; Owner: wcj
--

CREATE SEQUENCE fleets_fleet_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE fleets_fleet_id_seq OWNER TO wcj;

--
-- Name: fleets; Type: TABLE; Schema: public; Owner: wcj
--

CREATE TABLE fleets (
    fleet_id integer DEFAULT nextval('fleets_fleet_id_seq'::regclass) NOT NULL,
    fc_character_id integer,
    title character(128) NOT NULL,
    fleet_type integer,
    description text,
    composition text,
    creation_time timestamp with time zone DEFAULT timezone('utc'::text, now()),
    update_time timestamp with time zone,
    member_count integer DEFAULT 0,
    update_count integer DEFAULT 0,
    fleet_creator integer NOT NULL
);


ALTER TABLE fleets OWNER TO wcj;

--
-- Name: basic_fleets; Type: VIEW; Schema: public; Owner: wcj
--

CREATE VIEW basic_fleets AS
 SELECT fleets.fleet_id,
    characters.name AS fc_name,
    fleets.title AS fleet_title
   FROM fleets,
    characters
  WHERE (fleets.fc_character_id = characters.character_id);


ALTER TABLE basic_fleets OWNER TO wcj;

--
-- Name: characters_character_id_seq; Type: SEQUENCE; Schema: public; Owner: wcj
--

CREATE SEQUENCE characters_character_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE characters_character_id_seq OWNER TO wcj;

--
-- Name: characters_character_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wcj
--

ALTER SEQUENCE characters_character_id_seq OWNED BY characters.character_id;


--
-- Name: paps; Type: TABLE; Schema: public; Owner: wcj
--

CREATE TABLE paps (
    pap_id bigint NOT NULL,
    character_id integer NOT NULL,
    checkpoint_id integer NOT NULL
);


ALTER TABLE paps OWNER TO wcj;

--
-- Name: checkpoint_count; Type: VIEW; Schema: public; Owner: fleettool
--

CREATE VIEW checkpoint_count AS
 SELECT paps.checkpoint_id,
    count(*) AS count
   FROM paps
  GROUP BY paps.checkpoint_id;


ALTER TABLE checkpoint_count OWNER TO fleettool;

--
-- Name: checkpoints; Type: TABLE; Schema: public; Owner: wcj
--

CREATE TABLE checkpoints (
    checkpoint_id integer NOT NULL,
    fleet_id integer NOT NULL,
    creation_time timestamp with time zone NOT NULL,
    description text,
    creator integer NOT NULL
);


ALTER TABLE checkpoints OWNER TO wcj;

--
-- Name: logins; Type: TABLE; Schema: public; Owner: wcj
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


ALTER TABLE logins OWNER TO wcj;

--
-- Name: checkpoint_details; Type: VIEW; Schema: public; Owner: wcj
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


ALTER TABLE checkpoint_details OWNER TO wcj;

--
-- Name: checkpoints_checkpoint_id_seq; Type: SEQUENCE; Schema: public; Owner: wcj
--

CREATE SEQUENCE checkpoints_checkpoint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE checkpoints_checkpoint_id_seq OWNER TO wcj;

--
-- Name: checkpoints_checkpoint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wcj
--

ALTER SEQUENCE checkpoints_checkpoint_id_seq OWNED BY checkpoints.checkpoint_id;


--
-- Name: fleet_categories; Type: TABLE; Schema: public; Owner: wcj
--

CREATE TABLE fleet_categories (
    type_id integer NOT NULL,
    name character(128) NOT NULL,
    description text NOT NULL
);


ALTER TABLE fleet_categories OWNER TO wcj;

--
-- Name: fleet_catagories_type_id_seq; Type: SEQUENCE; Schema: public; Owner: wcj
--

CREATE SEQUENCE fleet_catagories_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE fleet_catagories_type_id_seq OWNER TO wcj;

--
-- Name: fleet_catagories_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wcj
--

ALTER SEQUENCE fleet_catagories_type_id_seq OWNED BY fleet_categories.type_id;


--
-- Name: fleet_checkpoints; Type: VIEW; Schema: public; Owner: wcj
--

CREATE VIEW fleet_checkpoints AS
 SELECT fleets.fleet_id,
    count(checkpoints.checkpoint_id) AS count,
    max(checkpoints.creation_time) AS last_updated
   FROM (fleets
     LEFT JOIN checkpoints ON ((fleets.fleet_id = checkpoints.fleet_id)))
  GROUP BY fleets.fleet_id;


ALTER TABLE fleet_checkpoints OWNER TO wcj;

--
-- Name: fleet_participation; Type: VIEW; Schema: public; Owner: wcj
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


ALTER TABLE fleet_participation OWNER TO wcj;

--
-- Name: fleet_details; Type: VIEW; Schema: public; Owner: wcj
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


ALTER TABLE fleet_details OWNER TO wcj;

--
-- Name: fleet_summary; Type: VIEW; Schema: public; Owner: wcj
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


ALTER TABLE fleet_summary OWNER TO wcj;

--
-- Name: logins_id_seq; Type: SEQUENCE; Schema: public; Owner: wcj
--

CREATE SEQUENCE logins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE logins_id_seq OWNER TO wcj;

--
-- Name: logins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wcj
--

ALTER SEQUENCE logins_id_seq OWNED BY logins.id;


--
-- Name: members_fleets; Type: TABLE; Schema: public; Owner: wcj
--

CREATE TABLE members_fleets (
    name character(128),
    character_id integer,
    fleet_participation bigint
);

ALTER TABLE ONLY members_fleets REPLICA IDENTITY NOTHING;


ALTER TABLE members_fleets OWNER TO wcj;

--
-- Name: members_paps; Type: TABLE; Schema: public; Owner: wcj
--

CREATE TABLE members_paps (
    character_id integer,
    name character(128),
    pap_count bigint
);

ALTER TABLE ONLY members_paps REPLICA IDENTITY NOTHING;


ALTER TABLE members_paps OWNER TO wcj;

--
-- Name: members_summary; Type: VIEW; Schema: public; Owner: wcj
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


ALTER TABLE members_summary OWNER TO wcj;

--
-- Name: pap_count; Type: TABLE; Schema: public; Owner: wcj
--

CREATE TABLE pap_count (
    name character(128),
    pap_count bigint
);

ALTER TABLE ONLY pap_count REPLICA IDENTITY NOTHING;


ALTER TABLE pap_count OWNER TO wcj;

--
-- Name: paps_pap_id_seq; Type: SEQUENCE; Schema: public; Owner: wcj
--

CREATE SEQUENCE paps_pap_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE paps_pap_id_seq OWNER TO wcj;

--
-- Name: paps_pap_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wcj
--

ALTER SEQUENCE paps_pap_id_seq OWNED BY paps.pap_id;


--
-- Name: characters character_id; Type: DEFAULT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY characters ALTER COLUMN character_id SET DEFAULT nextval('characters_character_id_seq'::regclass);


--
-- Name: checkpoints checkpoint_id; Type: DEFAULT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY checkpoints ALTER COLUMN checkpoint_id SET DEFAULT nextval('checkpoints_checkpoint_id_seq'::regclass);


--
-- Name: fleet_categories type_id; Type: DEFAULT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY fleet_categories ALTER COLUMN type_id SET DEFAULT nextval('fleet_catagories_type_id_seq'::regclass);


--
-- Name: logins id; Type: DEFAULT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY logins ALTER COLUMN id SET DEFAULT nextval('logins_id_seq'::regclass);


--
-- Name: paps pap_id; Type: DEFAULT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY paps ALTER COLUMN pap_id SET DEFAULT nextval('paps_pap_id_seq'::regclass);


--
-- Data for Name: characters; Type: TABLE DATA; Schema: public; Owner: wcj
--

COPY characters (character_id, name, last_reference) FROM stdin;
26	MaD Shazih                                                                                                                      	2017-02-15 05:33:30.782589
6	Anton Uitra                                                                                                                     	\N
436	Kuroh Raven                                                                                                                     	\N
8	Aurther Wolf                                                                                                                    	\N
50	Bolt Thunderfuk                                                                                                                 	2017-02-16 03:38:00.997315
11	Chease Filet Hungry                                                                                                             	\N
707	Avi Cerae                                                                                                                       	2017-02-16 03:38:00.996885
28	Marco Tazinas                                                                                                                   	2017-02-16 03:38:01.022936
18	Draela Minayin                                                                                                                  	2017-02-16 03:38:01.012931
16	ediride                                                                                                                         	\N
19	FeMalogalotalotim                                                                                                               	\N
20	FliipSide                                                                                                                       	\N
22	Katerina Farquhar                                                                                                               	\N
23	Kuwapa Neardieu                                                                                                                 	\N
38	Taor Malek                                                                                                                      	2017-02-14 20:17:24.189495
1	Forceful Peacekeeper                                                                                                            	2017-02-15 05:33:30.744266
29	Michael James Burn                                                                                                              	\N
4	abandonship                                                                                                                     	2017-02-14 20:59:21.998566
35	Stephanie Drazzhar                                                                                                              	\N
36	Stonie Bandit                                                                                                                   	\N
37	Tallitar                                                                                                                        	\N
41	VAN ALLERBERGER                                                                                                                 	\N
43	Quasar                                                                                                                          	\N
44	1337 asain Sirober                                                                                                              	\N
42	Wiggleskilla                                                                                                                    	2017-02-14 18:06:07.677826
47	Andrew Bituwy                                                                                                                   	\N
5	Aodh Biffle                                                                                                                     	2017-02-14 02:42:50.524572
51	Botterdief Tsero                                                                                                                	\N
49	Apollo Habalu                                                                                                                   	\N
40	Valerian Moore                                                                                                                  	2017-02-14 20:59:22.042768
17	Eyes Serine                                                                                                                     	2017-02-14 02:42:50.557571
34	Sona Darkstar                                                                                                                   	2017-02-16 03:38:01.040117
46	Alison Woolyworm                                                                                                                	2017-02-14 20:59:22.000135
625	Ian Alaavese                                                                                                                    	\N
21	Jonar Crighton                                                                                                                  	2017-02-16 03:38:01.013562
655	Sebastian Tapper                                                                                                                	\N
64	Enna Elios                                                                                                                      	2017-02-15 05:33:30.82295
15	DILLIGAF Lars                                                                                                                   	2017-02-14 08:16:16.747634
3	Reverz                                                                                                                          	2017-02-16 03:38:01.02417
24	Lady Xarinia Constantine                                                                                                        	2017-02-16 03:38:01.022713
9	BC Tank                                                                                                                         	2017-02-14 20:59:22.005619
67	Florida Bud                                                                                                                     	\N
68	Hannah Smith                                                                                                                    	\N
86	Spacial Anomally                                                                                                                	\N
57	Cynreth Falkenwacht                                                                                                             	2017-02-14 20:59:22.012406
70	Jack Crescend                                                                                                                   	2017-02-14 20:59:22.01883
78	Moosha Hilanen                                                                                                                  	2017-02-15 15:23:33.95386
25	Liam Angelus                                                                                                                    	2017-02-14 20:59:22.027897
87	sphodromantis Dethahal                                                                                                          	2017-02-14 20:59:22.04117
626	Conan U'Brien                                                                                                                   	\N
633	Theoris Toralen                                                                                                                 	\N
649	Edirolll                                                                                                                        	\N
56	Cynosarus-Rex                                                                                                                   	2017-02-15 05:33:30.814789
671	Ruprect                                                                                                                         	\N
439	Anna Mataran                                                                                                                    	2017-02-14 18:06:07.624468
7	Arturos OG                                                                                                                      	2017-02-16 03:38:00.996537
12	Cheldon87 Panda                                                                                                                 	2017-02-16 03:38:01.005037
73	kuroh raven                                                                                                                     	2017-02-14 18:06:07.653057
14	Crasse Solette                                                                                                                  	2017-02-16 03:38:01.004926
454	sillah                                                                                                                          	2017-02-14 18:06:07.664087
711	colgat                                                                                                                          	2017-02-16 03:38:01.006907
30	Nanaki Iga                                                                                                                      	2017-02-16 03:38:01.023283
53	brona Ellecon                                                                                                                   	2017-02-14 20:59:22.006854
71	JayMiie                                                                                                                         	\N
88	Suny Sunshine                                                                                                                   	\N
91	UnakUbiecNaLami                                                                                                                 	\N
72	Kazuto Kanashi                                                                                                                  	2017-02-14 16:41:34.853208
89	Thorbain Charante                                                                                                               	2017-02-14 08:16:35.663458
59	DarkForce Lemmont                                                                                                               	2017-02-16 03:38:01.005982
58	Destrin Nite                                                                                                                    	2017-02-16 03:38:01.0097
441	Alex Novoross                                                                                                                   	2017-02-14 18:06:07.628236
60	Diana Blowfish                                                                                                                  	2017-02-16 03:38:01.011949
726	Ni Jien                                                                                                                         	2017-02-16 03:38:01.023449
641	Motreda Sekuiya                                                                                                                 	\N
65	Felix Sorotoro                                                                                                                  	\N
66	FilithyMelinal Das                                                                                                              	2017-02-16 03:38:01.012357
445	AutoStop                                                                                                                        	2017-02-14 18:06:07.624676
727	RaiderJohn Anasasi                                                                                                              	2017-02-16 03:38:01.024603
93	Yushini                                                                                                                         	2017-02-16 03:38:01.042225
81	PH Woolyworm                                                                                                                    	2017-02-14 20:59:22.03047
643	Johnny Retalin                                                                                                                  	\N
661	Calaeus Fira                                                                                                                    	\N
674	Capt Saveahoe savahoetribe                                                                                                      	\N
126	Nikolas Teslaa                                                                                                                  	2017-02-15 05:33:30.852491
69	Haub Wads                                                                                                                       	\N
94	Vanblade                                                                                                                        	\N
446	homerrrr                                                                                                                        	2017-02-14 17:15:31.875031
642	Jacob Dio                                                                                                                       	\N
666	Deadly Hobs                                                                                                                     	\N
684	True Random                                                                                                                     	\N
33	Rosta Kylikvel                                                                                                                  	2017-02-16 03:38:01.024089
76	Lloride                                                                                                                         	\N
730	Skip Tu Malou                                                                                                                   	2017-02-16 03:38:01.039376
451	Marco Esquandolaz                                                                                                               	2017-02-14 18:06:07.661854
644	Grynwald                                                                                                                        	\N
27	Michael Degrasse                                                                                                                	2017-02-16 03:38:01.023683
39	Tony Brimstone                                                                                                                  	2017-02-16 03:38:01.040079
32	Ricklan Veno                                                                                                                    	2017-02-14 20:59:22.036833
84	sk3iron                                                                                                                         	2017-02-14 20:59:22.03908
647	Sehkmet Khanid                                                                                                                  	\N
98	Gilyne Rance                                                                                                                    	2017-02-15 05:33:30.816897
686	Lady Corinia Constantine                                                                                                        	\N
79	Naga Zin                                                                                                                        	\N
96	Mark9385 Algaert                                                                                                                	\N
97	Easiest Money                                                                                                                   	\N
455	Soladron Khamsi                                                                                                                 	\N
101	Awubis Akiga                                                                                                                    	\N
102	Vildana Aryan                                                                                                                   	\N
103	Tranah Kenstark                                                                                                                 	\N
104	Piddle My Diddle                                                                                                                	\N
105	Kycillia Le Cruze                                                                                                               	\N
106	Conrad VonSteiner                                                                                                               	\N
108	Myopisis                                                                                                                        	\N
111	Jordi Ramon Biel                                                                                                                	\N
113	Faith Crystila                                                                                                                  	\N
114	Calder Asanari                                                                                                                  	\N
115	Beelzebub Morningstar                                                                                                           	\N
116	Exentia Traylen                                                                                                                 	\N
142	Soladron Rin                                                                                                                    	2017-02-14 16:41:34.860689
92	Wanted4life                                                                                                                     	2017-02-14 18:06:07.673977
123	Nassire Anzomi                                                                                                                  	\N
112	Daniel McMann                                                                                                                   	2017-02-15 05:33:30.745522
125	Asintra                                                                                                                         	\N
732	Skraal Naereeis                                                                                                                 	2017-02-16 03:38:01.039566
127	Victor Kingslayer                                                                                                               	\N
139	Mist Sterling                                                                                                                   	2017-02-15 05:33:30.763144
133	Morgiana LeFay                                                                                                                  	\N
140	Salina Light                                                                                                                    	\N
107	Roxei Nalo                                                                                                                      	2017-02-14 08:16:35.698816
122	Sgt Jigy                                                                                                                        	2017-02-14 08:16:16.734483
132	Ba'el Khagah                                                                                                                    	2017-02-14 06:32:22.978066
128	Zeen Marley                                                                                                                     	2017-02-15 05:33:30.815468
135	Adriana Berucci                                                                                                                 	2017-02-14 06:32:22.993864
99	SureFire                                                                                                                        	2017-02-15 05:33:30.833564
137	Ian Jaynara                                                                                                                     	2017-02-14 06:42:14.693448
141	Deimos Dragoon                                                                                                                  	2017-02-15 05:33:30.798121
131	Grabdeez Nutz                                                                                                                   	2017-02-15 05:33:30.85231
129	Menori Diarc                                                                                                                    	2017-02-14 08:16:35.692736
121	Matthew Holman                                                                                                                  	2017-02-14 08:16:35.658095
134	Ormand Aldant                                                                                                                   	2017-02-14 06:42:14.65782
136	Talgaris Alduin                                                                                                                 	2017-02-15 05:33:30.778722
654	TheCr0wned                                                                                                                      	\N
110	Aleccia Abella                                                                                                                  	2017-02-14 08:16:16.730568
138	itsdylan Wilson                                                                                                                 	2017-02-14 08:16:16.737785
109	Matthias Lafisques                                                                                                              	2017-02-14 08:16:16.745159
143	Benny Styx                                                                                                                      	2017-02-14 08:16:35.662958
667	Daxin Orckiller                                                                                                                 	\N
120	Sieverts                                                                                                                        	2017-02-15 05:33:30.864106
144	Tealip Voong                                                                                                                    	\N
147	Cat Danderbeard                                                                                                                 	\N
159	Doherty778                                                                                                                      	\N
171	Dujavi Haberdash                                                                                                                	\N
173	Rez Drazdir                                                                                                                     	\N
189	Lee Osuere                                                                                                                      	\N
208	Alix Standaert                                                                                                                  	\N
204	Diergot                                                                                                                         	2017-02-16 03:38:01.011257
458	your waifu                                                                                                                      	2017-02-14 18:06:07.678617
191	Awakened One                                                                                                                    	2017-02-14 06:42:14.651155
124	Nano Hagane                                                                                                                     	2017-02-14 06:42:14.656812
175	Gleb Surov                                                                                                                      	2017-02-14 06:42:14.69238
203	N S Inkura                                                                                                                      	2017-02-15 05:33:30.796047
145	catsking Echerie                                                                                                                	2017-02-15 05:33:30.798385
672	Omar al-Nakrar                                                                                                                  	\N
682	Dimetri Vaundervult                                                                                                             	\N
198	Vaer Grukker                                                                                                                    	2017-02-14 08:16:35.659871
747	IskFiend                                                                                                                        	\N
146	Atrox DeGrande                                                                                                                  	2017-02-14 08:16:35.690881
205	Lopan Allas-Rui                                                                                                                 	2017-02-15 05:33:30.834159
158	pipsqueak Kanjus                                                                                                                	2017-02-15 05:33:30.853474
196	Nebur Sinak                                                                                                                     	2017-02-15 05:33:30.860799
695	Ysa nazur                                                                                                                       	\N
117	Teckmark Azrael                                                                                                                 	2017-02-14 06:32:22.913458
149	Valla Aulmais                                                                                                                   	\N
459	                                                                                                                                	\N
152	Karshia Chelien                                                                                                                 	2017-02-16 03:38:01.014099
178	Xavia Ronuken                                                                                                                   	2017-02-15 05:33:30.746177
156	Twomuch95                                                                                                                       	\N
157	Charon Galish                                                                                                                   	\N
161	Rock Sucker2                                                                                                                    	\N
166	Que Ess                                                                                                                         	\N
167	Truthful Liar                                                                                                                   	\N
168	Remkal Valeu                                                                                                                    	\N
170	aralikin                                                                                                                        	\N
172	Darel Botee                                                                                                                     	\N
179	Waylinn Nightbreed                                                                                                              	\N
219	Edisni                                                                                                                          	2017-02-15 05:33:30.74759
183	Adruxus Faux                                                                                                                    	\N
186	Fae Soul                                                                                                                        	\N
188	Rodriguez Neo Matrix                                                                                                            	\N
190	Anna Asad                                                                                                                       	\N
193	Juggernaut Fidard                                                                                                               	\N
197	Bear Issier                                                                                                                     	\N
200	Kane Blacknife                                                                                                                  	\N
202	Ty'Sha Calderos                                                                                                                 	\N
207	Anita Whiplash                                                                                                                  	\N
210	Ritterman Kollonister                                                                                                           	\N
162	Susan Kavees                                                                                                                    	2017-02-15 05:33:30.754801
163	Slowenc vonLaibach                                                                                                              	2017-02-15 05:33:30.780715
184	Peter Tlaw                                                                                                                      	2017-02-15 05:33:30.815843
194	Crazed Jesster                                                                                                                  	2017-02-14 08:16:35.705387
201	Pikk Pirkibo                                                                                                                    	2017-02-15 05:33:30.830734
176	Todsten Grukker                                                                                                                 	2017-02-15 05:33:30.831707
215	Gryd                                                                                                                            	2017-02-14 06:42:14.655528
213	Anakin Skylander                                                                                                                	2017-02-14 06:42:14.656434
217	ikbenhet vaneenander                                                                                                            	2017-02-14 06:42:14.657654
192	David Apollo                                                                                                                    	2017-02-15 05:33:30.834195
692	Emily Solytte                                                                                                                   	\N
164	Khaloyan Drogo                                                                                                                  	2017-02-15 05:33:30.861006
195	Mirsa Kaed                                                                                                                      	2017-02-15 05:33:30.865567
209	Indaira                                                                                                                         	2017-02-14 08:16:16.727349
174	Diesel Doris                                                                                                                    	2017-02-14 08:16:16.750903
211	Alice AliceRuiz                                                                                                                 	2017-02-14 08:16:35.662066
180	Arandalia Frostmonger                                                                                                           	2017-02-15 05:33:30.865929
165	Tweekrog Puntkuncher                                                                                                            	2017-02-14 08:16:35.691291
721	Kido Wads                                                                                                                       	2017-02-16 03:38:01.024489
760	Shijo Kingo                                                                                                                     	\N
257	drmockingjay homegrown                                                                                                          	2017-02-14 06:42:14.71058
460	Kuro                                                                                                                            	\N
225	Julius Au Terra                                                                                                                 	2017-02-15 05:33:30.799233
226	Rashed Pilock                                                                                                                   	2017-02-14 06:42:14.666037
263	Majyenta Centuris                                                                                                               	2017-02-14 06:42:14.720231
333	Julia Tesla                                                                                                                     	2017-02-14 08:16:35.686502
237	Zap Hendar                                                                                                                      	2017-02-14 08:16:35.711796
473	Hidan Kado                                                                                                                      	2017-02-14 18:06:07.640626
255	Valkeryies 1                                                                                                                    	2017-02-15 05:33:30.863512
329	Eddie Anninen                                                                                                                   	2017-02-15 05:33:30.865692
227	Alexis Vemane                                                                                                                   	2017-02-14 06:42:14.666916
256	Ithaniel Issier                                                                                                                 	2017-02-14 06:42:14.710245
330	Doerito Bag                                                                                                                     	2017-02-14 08:16:35.679527
351	Kimeko Kasshinryu                                                                                                               	2017-02-14 08:16:35.698969
476	Kondyor Massif                                                                                                                  	2017-02-14 20:17:24.175211
243	Mei Jing                                                                                                                        	2017-02-14 06:42:14.693788
254	Kayser Allier                                                                                                                   	2017-02-14 06:42:14.710239
260	Aragon Deninard                                                                                                                 	2017-02-14 06:42:14.719249
331	Botterdief KellyS                                                                                                               	2017-02-14 08:16:35.664517
340	Black Bauerson                                                                                                                  	2017-02-14 08:16:35.690357
356	HonestAbe Verum                                                                                                                 	2017-02-14 08:16:35.701637
228	Cojesuses Angeli                                                                                                                	2017-02-14 20:59:22.009004
477	KiTeRiK                                                                                                                         	2017-02-14 20:59:22.027376
249	ELiothVal Tivianne                                                                                                              	2017-02-14 06:42:14.708538
229	Scotty D                                                                                                                        	2017-02-14 08:16:16.739725
262	bmw7 bmw7                                                                                                                       	2017-02-14 08:16:16.746807
336	Zhuzhen Hakado                                                                                                                  	2017-02-14 08:16:35.687615
349	Bahran Kronos                                                                                                                   	2017-02-14 08:16:35.698363
481	Panizia                                                                                                                         	2017-02-14 18:06:07.662738
363	Diver Uanid                                                                                                                     	2017-02-15 05:33:30.754434
230	Well Stellar                                                                                                                    	2017-02-14 06:42:14.677061
339	Itenis Otsito                                                                                                                   	2017-02-14 08:16:35.690712
348	Zaney Aideron                                                                                                                   	2017-02-14 08:16:35.698219
543	Srash Bringer                                                                                                                   	2017-02-14 20:59:22.041946
231	Nelsonn McCaw                                                                                                                   	2017-02-14 06:42:14.690542
245	MASTERKILLER3                                                                                                                   	2017-02-14 06:42:14.700955
354	Rock Sucker1                                                                                                                    	2017-02-14 08:16:35.701317
546	stilett mark                                                                                                                    	\N
342	JustSome0ne                                                                                                                     	2017-02-15 05:33:30.798905
232	Fredrick Nosbusch                                                                                                               	2017-02-14 06:42:14.685455
150	Syn Elberen                                                                                                                     	2017-02-14 06:42:14.709721
347	Anakin Deces                                                                                                                    	2017-02-14 08:16:35.69807
353	Eduardo Argentum                                                                                                                	2017-02-14 08:16:35.699587
550	test                                                                                                                            	\N
551	sdfsfsfffs                                                                                                                      	\N
233	Grandmashands                                                                                                                   	2017-02-14 06:42:14.69019
381	Annie Stauber                                                                                                                   	\N
360	Dejah Thoriss                                                                                                                   	2017-02-14 08:16:35.705635
552	fasf                                                                                                                            	\N
261	Ashura Irtoov                                                                                                                   	2017-02-14 06:42:14.719806
558	Christy Gengod                                                                                                                  	\N
234	keyboredninja                                                                                                                   	2017-02-15 05:33:30.819114
361	Suzie Arbosa                                                                                                                    	2017-02-15 05:33:30.830574
155	Klarynth Deathsong                                                                                                              	2017-02-14 06:42:14.708129
362	Slattea Grape                                                                                                                   	2017-02-14 08:16:35.711004
570	Leksys                                                                                                                          	2017-02-14 20:59:22.027662
235	Gunther Lange                                                                                                                   	2017-02-15 05:33:30.774001
244	Ehlr0y Galaxy                                                                                                                   	2017-02-14 06:42:14.693871
259	Kanine Alduin                                                                                                                   	2017-02-14 06:42:14.711456
377	Ragiri Regyri                                                                                                                   	\N
573	Patric Oneill                                                                                                                   	2017-02-14 20:59:22.028686
240	Minerva DeCivire                                                                                                                	2017-02-15 05:33:30.754225
366	BLOCKHEAD                                                                                                                       	2017-02-15 05:33:30.75594
578	Tirael VonRisfeld                                                                                                               	\N
367	Bagnan Omar                                                                                                                     	\N
151	Abyssinia Mernher                                                                                                               	2017-02-14 08:16:35.699065
373	Grisdale                                                                                                                        	\N
247	Lord Eddard Lars                                                                                                                	2017-02-14 08:16:35.660221
10	Bran Rhi                                                                                                                        	2017-02-16 03:38:01.003696
13	Dark Fellah                                                                                                                     	2017-02-14 20:59:22.014885
221	Dana Nebula                                                                                                                     	2017-02-15 05:33:30.815675
374	Oj Hattotheside                                                                                                                 	2017-02-15 05:33:30.819847
376	Tojan Horse                                                                                                                     	\N
604	Petr Barviainen                                                                                                                 	\N
222	Ben Kenshin                                                                                                                     	2017-02-15 05:33:30.798001
606	Raymond Renski                                                                                                                  	\N
182	V ivi D                                                                                                                         	2017-02-15 05:33:30.865964
100	Akalikto                                                                                                                        	2017-02-15 05:33:30.866321
220	Sheny Atild                                                                                                                     	2017-02-14 06:42:14.661883
385	Anstia Jakuard                                                                                                                  	\N
609	Sozace                                                                                                                          	\N
327	Red Yaahmon                                                                                                                     	2017-02-14 08:16:35.663445
346	TheDestroyer940 Matthews                                                                                                        	2017-02-14 08:16:35.690639
617	Taranee Rhode                                                                                                                   	\N
683	Mateusz Rinah                                                                                                                   	\N
316	William Stonebrook                                                                                                              	2017-02-16 03:38:01.039913
343	Avidius Thiesant                                                                                                                	2017-02-14 08:16:35.691152
620	lane kagu                                                                                                                       	\N
320	Eldurian Gavriel                                                                                                                	2017-02-15 05:33:30.783915
660	Triatt Ohmiras                                                                                                                  	\N
676	Chronotides Hayes                                                                                                               	\N
321	Morgana VanHelsing                                                                                                              	2017-02-14 08:16:35.660064
337	Orsino Askold                                                                                                                   	2017-02-14 08:16:35.689035
621	Iris Xedus                                                                                                                      	\N
657	Jupiter Joness                                                                                                                  	\N
623	God Yvormes                                                                                                                     	\N
634	Spaztic Savior                                                                                                                  	\N
650	Defiance Severasse                                                                                                              	\N
328	DFib Arbosa                                                                                                                     	2017-02-15 05:33:30.805107
624	Lu Sloth                                                                                                                        	\N
130	Maxim Beddelver                                                                                                                 	2017-02-14 08:16:16.72769
118	edigal                                                                                                                          	2017-02-15 05:33:30.780224
640	Turbofox Isu                                                                                                                    	\N
679	Siarhei Tankian                                                                                                                 	\N
\.


--
-- Name: characters_character_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wcj
--

SELECT pg_catalog.setval('characters_character_id_seq', 766, true);


--
-- Data for Name: checkpoints; Type: TABLE DATA; Schema: public; Owner: wcj
--

COPY checkpoints (checkpoint_id, fleet_id, creation_time, description, creator) FROM stdin;
2	2	2017-02-13 19:48:53.646476-06		1
3	3	2017-02-13 20:42:50.620897-06		1
11	5	2017-02-14 10:41:34.879724-06	Entosis Op of 4 Timers	7
12	6	2017-02-14 11:15:31.917507-06	Filithy woke up and this shit was doing on, so I am reporting it as I see it from this time	5
13	6	2017-02-14 11:21:11.222725-06	Don't know if the first one worked making sure this logs 	5
14	6	2017-02-14 12:06:07.700727-06	test 3?	5
15	7	2017-02-14 12:46:15.749782-06	fsdafs	5
16	6	2017-02-14 20:17:24.205735-06	20:17	5
17	6	2017-02-14 20:59:22.055378-06	20:59	5
19	11	2017-02-16 03:34:53.10183-06	Undocking	5
20	11	2017-02-16 03:38:01.059558-06	Actually leaving now	5
\.


--
-- Name: checkpoints_checkpoint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wcj
--

SELECT pg_catalog.setval('checkpoints_checkpoint_id_seq', 20, true);


--
-- Name: fleet_catagories_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wcj
--

SELECT pg_catalog.setval('fleet_catagories_type_id_seq', 10, true);


--
-- Data for Name: fleet_categories; Type: TABLE DATA; Schema: public; Owner: wcj
--

COPY fleet_categories (type_id, name, description) FROM stdin;
1	Strat Op                                                                                                                        	A fleet of the highest priority ordered by senior leadership.
2	Offensive Fleet                                                                                                                 	A fleet with a targetted mission of agression against another entity.
3	Defense Fleet                                                                                                                   	A fleet to defend MOON or allied assets, space, or members.
4	Response Fleet                                                                                                                  	A fleet formed in response to an act of agression by another entity.
5	Roaming Fleet                                                                                                                   	A fleet formed to seek out and engage other entities.
6	Standing Fleet                                                                                                                  	A fleet formed for standard in pocket operations.
7	PVE Fleet                                                                                                                       	A fleet formed to facilitate PVE.
8	Indy Fleet                                                                                                                      	A fleet formed to facilitate industry or mining.
9	Logistics Fleet                                                                                                                 	A fleet formed to facilitate logistics.
10	Other                                                                                                                           	A fleet formed for some other reason. Please specify clearly in the description.
\.


--
-- Data for Name: fleets; Type: TABLE DATA; Schema: public; Owner: wcj
--

COPY fleets (fleet_id, fc_character_id, title, fleet_type, description, composition, creation_time, update_time, member_count, update_count, fleet_creator) FROM stdin;
2	3	ferox ospreys                                                                                                                   	1		ferox ospreys	2017-02-14 01:48:34.020741-06	2017-02-14 01:48:34.020741-06	0	0	1
3	43	Svipuls                                                                                                                         	1		1337 asain Sirober\nabandonship\nAlison Woolyworm\nAndrew Bituwy\nAodh Biffle\nApollo Habalu\nArturos OG\nBolt Thunderfuk\nBotterdief Tsero\nbrona Ellecon\nCheldon87 Panda\nCrasse Solette\nCynosarus-Rex\nCynreth Falkenwacht\nDarkForce Lemmont\nDestrin Nite\nDiana Blowfish\nDILLIGAF Lars\nDraela Minayin\nEnna Elios\nEyes Serine\nFelix Sorotoro\nFilithyMelinal Das\nFlorida Bud\nHannah Smith\nHaub Wads\nJack Crescend\nJayMiie\nKazuto Kanashi\nkuroh raven\nLady Xarinia Constantine\nLiam Angelus\nLloride\nMichael Degrasse\nMoosha Hilanen\nNaga Zin\nNanaki Iga\nPH Woolyworm\nReverz\nRicklan Veno\nsk3iron\nSona Darkstar\nSpacial Anomally\nsphodromantis Dethahal\nSuny Sunshine\nThorbain Charante\nTony Brimstone\nUnakUbiecNaLami\nVanblade\nWanted4life\nYushini	2017-02-14 01:54:17.856735-06	2017-02-14 01:54:17.856735-06	0	0	1
5	436	Strattop War                                                                                                                    	1	Entosis%20Op%20for%20O3L-95	Caracals\nOspreys\nEntosis Drakes	2017-02-14 16:25:21.928658-06	2017-02-14 16:25:21.928658-06	0	0	7
6	460	Entosis shit                                                                                                                    	1	Kuro%20being%20weird%20and%20stupid%20	Carcals ospreys w/ tackle	2017-02-14 17:15:07.382966-06	2017-02-14 17:15:07.382966-06	0	0	5
7	550	test                                                                                                                            	3	fsdf	fas	2017-02-14 18:46:09.642386-06	2017-02-14 18:46:09.642386-06	0	0	5
8	3	EVERYONE GET IN THIS FLEET                                                                                                      	1	Glorious%20leader%20Reverz%20logs%20in%20valentines%20day%20to%20lead%20the%20fight%20against%20the%20infidels%20of%20Darwinism%20and%20slap%20the%20monkeys%20around	1337 asain Sirober\nArturos OG\nAvi Cerae\nBC Tank\nCheldon87 Panda\nChristy Gengod\nCrasse Solette\nDILLIGAF Lars\nFelix Sorotoro\nFeMalogalotalotim\nFilithyMelinal Das\nJadon Godeth\nMalogalotalotim2\nMichael Degrasse\nNanaki Iga\nNi Jien\nRaiderJohn Anasasi\nReverz\nRicklan Veno\nsk3iron\nSkip Tu Malou\nSoladron Khamsi\nSona Darkstar\nTony Brimstone\nViktor Klev\nYushini	2017-02-15 04:04:08.293819-06	2017-02-15 04:04:08.293819-06	0	0	5
10	78	Strat OP important af                                                                                                           	1	Moosha%20Fleet%20	Alex Novoross\nAlison Woolyworm\nAnna Mataran\nAutoStop\nBC Tank\nCataleya Angelus\ncolgat\nFilithyMelinal Das\nKondyor Massif\nLiam Angelus\nMoosha Hilanen\nmshtsh\nSuny Sunshine\nWilliam Stonebrook	2017-02-15 15:23:33.96782-06	2017-02-15 15:23:33.96782-06	0	0	5
11	3	0-W TCU                                                                                                                         	1	The%20Eddar%20Rolls%20him%20self%20leads%20the%20flet%20to%20take%20%200-W%20TCU	ferox carcals ospey support	2017-02-16 03:27:31.60072-06	2017-02-16 03:27:31.60072-06	0	0	5
\.


--
-- Name: fleets_fleet_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wcj
--

SELECT pg_catalog.setval('fleets_fleet_id_seq', 11, true);


--
-- Data for Name: logins; Type: TABLE DATA; Schema: public; Owner: wcj
--

COPY logins (username, hash, rank, created, modified, id, last_login) FROM stdin;
Columbus                                                                                                                        	$2a$10$N1XyuvcYVvrYTb/.VkWPgOIh5q99QoPEf6TuhbDeNmHh59vzKMsUW	10	2017-02-14 01:34:17.106267-06	\N	9	\N
Forceful_Peacekeeper                                                                                                            	$2a$10$PpgVSmOcajCfkrh61cKjm..04e.wpRzIe6UBYKKs5U07zu9rpu/Fy	10	2017-02-14 01:21:43.946529-06	\N	2	2017-02-15 05:32:47.375833
FilithyMelinal_Das                                                                                                              	$2a$10$rju4VxlnbUO7vIXJysUjouqeHedF55FzYttPyxRicw/pFeTq6D08O	10	2017-02-14 01:25:31.615485-06	\N	5	2017-02-16 03:23:18.572861
DILLIGAF_Lars                                                                                                                   	$2a$10$oGqP.XIHwXqaJ3VMLCTk7.BGBlDO2sW2Y3rnEOUliev0orzuJU9v.	10	2017-02-14 18:28:48.827593-06	2017-02-14 18:28:52.904863-06	13	2017-02-16 03:25:38.274786
root                                                                                                                            	                                                            	100	2017-02-14 01:18:49.660771-06	\N	1	\N
ZZEZ_Murika                                                                                                                     	$2a$10$mWjXoN0A7jetc6djwEmAwOoAIR.xu1cOXPBLucTZxLg6qn/RwA3O2	5	2017-02-14 01:27:28.730265-06	\N	7	2017-02-14 16:22:31.758252
Maise_Mackenzie                                                                                                                 	$2a$10$9URHlChl.4kMEFG25ZKRPOSKdVqN8v.HX8k4Jmry9HJFnuwHBgZzO	5	2017-02-14 01:35:39.210719-06	\N	10	\N
1337_asain_Sirober                                                                                                              	$2a$10$EguxQwfI7eI8b8vuQ2mhKeozZv5a3y0179sYSaT6KOcJNxYK0VwTu	10	2017-02-14 01:52:00.378847-06	2017-02-14 06:30:47.390515-06	11	\N
Enna_Elios                                                                                                                      	$2a$10$5xzHTEHq3e5niC6/9II9oequCpW8mNgEfNaoS9f1iwOBk.KnaRTZG	10	2017-02-14 01:24:36.39253-06	\N	4	2017-02-14 09:33:05.729598
Edirolll                                                                                                                        	$2a$10$KOBUA5jzAep4DYPOujAAdOR6PrIcJv.8GxSVAHHA.TsWXRsUtbU2q	10	2017-02-14 01:23:49.367393-06	\N	3	\N
Quasar_Enderas                                                                                                                  	$2a$10$Ojo8Ej/3yGjR3oLResvmf./ZEDCItvSL6ryBKOjKhpkLZ9Ze7hmUq	5	2017-02-14 01:26:34.593739-06	\N	6	\N
Que_Ess                                                                                                                         	$2a$10$AqpHkt892Ct3n/pDejiMu.YAeO6Oe8BX39dljc6H0ElNGvpqhwYse	10	2017-02-14 01:31:19.290034-06	2017-02-14 18:40:47.274406-06	8	2017-02-14 18:41:28.28283
\.


--
-- Name: logins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wcj
--

SELECT pg_catalog.setval('logins_id_seq', 15, true);


--
-- Data for Name: paps; Type: TABLE DATA; Schema: public; Owner: wcj
--

COPY paps (pap_id, character_id, checkpoint_id) FROM stdin;
2	6	2
3	4	2
4	11	2
5	7	2
6	5	2
7	12	2
8	9	2
9	8	2
10	13	2
11	15	2
12	14	2
13	16	2
14	17	2
15	18	2
16	10	2
17	19	2
18	20	2
19	21	2
20	22	2
21	23	2
22	24	2
23	25	2
24	26	2
25	28	2
26	27	2
27	29	2
28	30	2
29	3	2
30	32	2
31	33	2
32	34	2
33	35	2
34	36	2
35	37	2
36	38	2
37	39	2
38	40	2
39	41	2
40	42	2
41	44	3
42	4	3
43	47	3
44	5	3
45	49	3
46	50	3
47	7	3
48	46	3
49	51	3
50	53	3
51	12	3
52	14	3
53	57	3
54	56	3
55	59	3
56	58	3
57	15	3
58	64	3
59	65	3
60	67	3
61	69	3
62	71	3
63	72	3
64	73	3
65	66	3
66	18	3
67	17	3
68	68	3
69	60	3
70	70	3
71	24	3
72	25	3
73	76	3
74	27	3
75	78	3
76	79	3
77	30	3
78	81	3
79	3	3
80	32	3
81	84	3
82	34	3
83	86	3
84	87	3
85	89	3
86	88	3
87	39	3
88	91	3
89	94	3
90	92	3
91	93	3
432	4	11
433	441	11
434	445	11
435	50	11
436	9	11
437	14	11
438	439	11
439	13	11
440	18	11
441	446	11
442	451	11
443	73	11
444	70	11
445	72	11
446	58	11
447	28	11
448	32	11
449	454	11
450	455	11
451	142	11
452	42	11
453	458	11
454	459	11
455	441	12
456	4	12
457	439	12
458	445	12
459	9	12
460	50	12
461	228	12
462	14	12
464	18	12
463	13	12
465	446	12
466	66	12
467	58	12
468	70	12
469	473	12
470	477	12
471	476	12
472	73	12
473	451	12
474	28	12
475	481	12
476	32	12
477	84	12
478	92	12
479	454	12
480	39	12
481	42	12
482	458	12
483	4	13
484	439	13
485	445	13
486	228	13
488	14	13
487	50	13
489	58	13
490	13	13
491	441	13
492	9	13
493	18	13
494	66	13
495	473	13
496	477	13
497	70	13
498	476	13
499	73	13
500	451	13
501	28	13
502	27	13
503	481	13
504	32	13
505	454	13
506	84	13
507	39	13
508	92	13
509	42	13
510	458	13
511	4	14
512	9	14
513	441	14
514	53	14
515	445	14
516	14	14
517	473	14
518	439	14
519	66	14
520	50	14
521	228	14
522	18	14
523	13	14
524	58	14
525	70	14
526	477	14
527	476	14
529	25	14
552	14	16
572	38	16
587	13	17
600	32	17
700	711	19
716	727	19
735	66	20
752	34	20
530	451	14
553	228	16
567	81	16
588	18	17
603	87	17
701	14	19
717	3	19
736	707	20
740	721	20
531	481	14
554	13	16
568	32	16
589	66	17
591	477	17
702	59	19
713	27	19
737	21	20
739	152	20
754	316	20
532	32	14
555	18	16
563	570	16
703	60	19
712	28	19
738	12	20
753	39	20
533	27	14
556	60	16
566	573	16
704	58	19
715	726	19
534	454	14
542	316	14
557	58	16
564	25	16
705	204	19
723	316	19
535	84	14
558	57	16
570	87	16
706	21	19
721	39	19
536	87	14
559	66	16
707	66	19
718	33	19
537	543	14
560	70	16
561	477	16
708	18	19
538	546	14
575	4	17
590	70	17
605	40	17
709	152	19
722	93	19
539	40	14
543	458	14
576	46	17
599	606	17
724	7	20
746	3	20
540	92	14
577	7	17
595	570	17
725	50	20
743	27	20
755	93	20
541	42	14
578	9	17
597	604	17
726	59	20
744	727	20
544	552	15
579	50	17
593	78	17
727	10	20
747	33	20
545	551	15
580	53	17
604	543	17
728	747	20
741	24	20
546	46	16
571	543	16
581	10	17
594	30	17
729	711	20
749	760	20
547	4	16
573	578	16
582	14	17
601	84	17
695	707	19
710	721	19
730	14	20
742	28	20
548	9	16
562	476	16
583	228	17
592	25	17
696	7	19
719	732	19
731	58	20
750	730	20
549	50	16
574	40	16
584	58	17
602	609	17
697	10	19
714	30	19
732	60	20
745	30	20
550	558	16
565	30	16
585	57	17
598	81	17
698	50	19
711	24	19
733	204	20
751	732	20
551	53	16
569	84	16
586	60	17
596	573	17
699	12	19
720	730	19
734	18	20
748	726	20
528	73	14
\.


--
-- Name: paps_pap_id_seq; Type: SEQUENCE SET; Schema: public; Owner: wcj
--

SELECT pg_catalog.setval('paps_pap_id_seq', 755, true);


--
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (character_id);


--
-- Name: checkpoints checkpoints_pkey; Type: CONSTRAINT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY checkpoints
    ADD CONSTRAINT checkpoints_pkey PRIMARY KEY (checkpoint_id);


--
-- Name: fleet_categories fleet_catagories_pkey; Type: CONSTRAINT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY fleet_categories
    ADD CONSTRAINT fleet_catagories_pkey PRIMARY KEY (type_id);


--
-- Name: fleets fleet_pkey; Type: CONSTRAINT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fleet_pkey PRIMARY KEY (fleet_id);


--
-- Name: logins id_unique; Type: CONSTRAINT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY logins
    ADD CONSTRAINT id_unique UNIQUE (id);


--
-- Name: logins login_pkey; Type: CONSTRAINT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY logins
    ADD CONSTRAINT login_pkey PRIMARY KEY (username);


--
-- Name: characters name_unique; Type: CONSTRAINT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT name_unique UNIQUE (name);


--
-- Name: paps paps_pkey; Type: CONSTRAINT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY paps
    ADD CONSTRAINT paps_pkey PRIMARY KEY (pap_id);


--
-- Name: fki_creator_id_constraint; Type: INDEX; Schema: public; Owner: wcj
--

CREATE INDEX fki_creator_id_constraint ON fleets USING btree (fleet_creator);


--
-- Name: fki_fc_id_constraint; Type: INDEX; Schema: public; Owner: wcj
--

CREATE INDEX fki_fc_id_constraint ON fleets USING btree (fc_character_id);


--
-- Name: fki_fleet_type_fkey; Type: INDEX; Schema: public; Owner: wcj
--

CREATE INDEX fki_fleet_type_fkey ON fleets USING btree (fleet_type);


--
-- Name: pap_count _RETURN; Type: RULE; Schema: public; Owner: wcj
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
-- Name: members_fleets _RETURN; Type: RULE; Schema: public; Owner: wcj
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
-- Name: members_paps _RETURN; Type: RULE; Schema: public; Owner: wcj
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
-- Name: checkpoints creator_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY checkpoints
    ADD CONSTRAINT creator_fkey FOREIGN KEY (creator) REFERENCES logins(id);


--
-- Name: fleets creator_id_constraint; Type: FK CONSTRAINT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT creator_id_constraint FOREIGN KEY (fleet_creator) REFERENCES logins(id);


--
-- Name: fleets fc_id_constraint; Type: FK CONSTRAINT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fc_id_constraint FOREIGN KEY (fc_character_id) REFERENCES characters(character_id);


--
-- Name: fleets fleet_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: wcj
--

ALTER TABLE ONLY fleets
    ADD CONSTRAINT fleet_type_fkey FOREIGN KEY (fleet_type) REFERENCES fleet_categories(type_id);


--
-- PostgreSQL database dump complete
--

