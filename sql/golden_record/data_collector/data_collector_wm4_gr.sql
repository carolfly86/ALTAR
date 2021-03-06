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
    index_stats_instance_id smallint,
    index_stats_dbname name,
    index_stats_schemaname name,
    index_stats_relname name,
    index_stats_idxname name,
    index_stats_bloat_ratio numeric,
    index_stats_size_mb numeric,
    index_stats_idx_scan bigint,
    index_stats_idx_tup_read bigint,
    index_stats_idx_tup_fetch bigint,
    index_stats_idx_blks_hit_ratio numeric,
    index_stats_stat_id integer,
    type character varying(30),
    branch character varying(30)
);


ALTER TABLE golden_record OWNER TO myuser;

--
-- Data for Name: golden_record; Type: TABLE DATA; Schema: public; Owner: myuser
--

COPY golden_record (index_stats_instance_id, index_stats_dbname, index_stats_schemaname, index_stats_relname, index_stats_idxname, index_stats_bloat_ratio, index_stats_size_mb, index_stats_idx_scan, index_stats_idx_tup_read, index_stats_idx_tup_fetch, index_stats_idx_blks_hit_ratio, index_stats_stat_id, type, branch) FROM stdin;
147	sync_engine_stg1	public	qrtz_fired_triggers	idx_qrtz_ft_tg	98.4251968503937	0.99	2012	28192	4463	0.999994427054951	2606	excluded	
147	obp	obp	qrtz_scheduler_state	qrtz_scheduler_state_pkey	0	0.01	0	0	0	0.999890097812946	2492	satisfied	PH0
200	workflow_s442	public	databasechangeloglock	pk_databasechangeloglock	8	2	6	6	6	0.833333333333333	227363	satisfied	PH1
141	abstract_management	public	email	pk_email	51	93	0	0	0	-1	119547	satisfied	PH2
\.


--
-- PostgreSQL database dump complete
--

