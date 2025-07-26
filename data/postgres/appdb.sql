--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Debian 14.18-1.pgdg120+1)
-- Dumped by pg_dump version 17.5 (Ubuntu 17.5-0ubuntu0.25.04.1)

-- Started on 2025-07-26 15:32:29 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: app
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO app;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 209 (class 1259 OID 16385)
-- Name: grafana_file; Type: TABLE; Schema: public; Owner: app
--

CREATE TABLE public.grafana_file (
    creation_date timestamp without time zone NOT NULL,
    size integer NOT NULL
);


ALTER TABLE public.grafana_file OWNER TO app;

--
-- TOC entry 3328 (class 0 OID 16385)
-- Dependencies: 209
-- Data for Name: grafana_file; Type: TABLE DATA; Schema: public; Owner: app
--

COPY public.grafana_file (creation_date, size) FROM stdin;
2025-07-25 06:23:52.899231	5000
2025-07-26 06:23:59.13001	4000
2025-07-24 07:09:49.193354	6000
2025-07-22 06:24:04.625707	1000
2023-07-26 07:09:44.131377	8000
2025-07-21 06:23:52.899231	3000
2025-07-20 06:23:52.899231	7500
2025-07-25 06:25:52.899231	5300
2023-07-26 02:09:44.131377	7000
2023-07-26 12:09:44.131377	5000
\.


--
-- TOC entry 3334 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: app
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2025-07-26 15:32:29 CEST

--
-- PostgreSQL database dump complete
--

