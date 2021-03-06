--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: golden_record; Type: TABLE; Schema: public; Owner: myuser; Tablespace: 
--

CREATE TABLE golden_record (
    questions_id uuid,
    questions_minresponses integer,
    questions_maxresponses integer,
    questions_required boolean,
    questions_surveyid bigint,
    questions_label character varying(300),
    questions_status character varying(50),
    questions_imageid bigint,
    questions_questioncode integer,
    questions_etl_time timestamp without time zone,
    questions_questionposition integer,
    questions_externalsystemid integer,
    questions_metadata hstore,
    choices_id uuid,
    choices_questionid uuid,
    choices_type character varying(50),
    choices_value character varying(140),
    choices_label character varying(300),
    choices_active boolean,
    choices_imageid bigint,
    choices_choiceposition integer,
    choices_style character varying(10),
    choices_etl_time timestamp without time zone,
    choices_externalsystemid integer,
    choices_metadata hstore,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO myuser;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY golden_record (questions_id, questions_minresponses, questions_maxresponses, questions_required, questions_surveyid, questions_label, questions_status, questions_imageid, questions_questioncode, questions_etl_time, questions_questionposition, questions_externalsystemid, questions_metadata, choices_id, choices_questionid, choices_type, choices_value, choices_label, choices_active, choices_imageid, choices_choiceposition, choices_style, choices_etl_time, choices_externalsystemid, choices_metadata, type, branch) FROM stdin;
b94f781b-5301-48a1-b941-55008e450feb	0	0	f	1083	What is his or her role in choosing a solution?	ENABLED	2000	0	2016-12-28 00:00:00	6	60		01d3192b-fe58-44ff-a6f5-0e84268424fd	b94f781b-5301-48a1-b941-55008e450feb	SIMPLE_CHOICE	Not Applicable	Not Applicable	t	393	3	\N	2017-12-08 00:00:00	48		satisfied	PH3
f006e9bb-fd84-45d6-91ef-84230f903f35	0	0	t	619	What is the timeframe for choosing a solution?	ENABLED	706	0	2016-12-28 00:00:00	5	60		03cc073c-9bbb-4104-a492-d49b09b7274c	f006e9bb-fd84-45d6-91ef-84230f903f35	SIMPLE_CHOICE	Not Applicable	Not Applicable	t	2000	2	\N	2017-01-30 22:48:43.801035	48		satisfied	PH2
088b8518-c7eb-4d8c-9a09-a23f45c9cebe	0	1	f	5	Notes	ENABLED	2000	4	2016-12-28 00:00:00	1	60		9226daa0-e965-47ac-9bd4-765a3cf8a52a	088b8518-c7eb-4d8c-9a09-a23f45c9cebe	LONG_TEXT	Enter Response Here.		t	2000	2	\N	2017-12-08 00:00:00	57		satisfied	PH1
1e682c5c-6986-45a8-bb18-469dc5d9340f	0	0	f	5	Lead Score	ENABLED	2000	0	2016-12-07 11:23:54.362387	0	76		ff76cb05-9c6e-4348-909c-791252df4b77	1e682c5c-6986-45a8-bb18-469dc5d9340f	NUMERIC	\N	\N	t	2000	2	GOLD	2017-12-08 00:00:00	102		satisfied	PH0
1e682c5c-6986-45a8-bb18-469dc5d9340f	0	0	f	5	Lead Score	ENABLED	2000	0	2016-12-28 00:00:00	0	60		ff76cb05-9c6e-4348-909c-791252df4b77	1e682c5c-6986-45a8-bb18-469dc5d9340f	NUMERIC	\N	\N	f	2000	2	GOLD	2017-12-08 00:00:00	102		excluded	
\.


--
-- PostgreSQL database dump complete
--

