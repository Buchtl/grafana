--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Debian 16.9-1.pgdg120+1)
-- Dumped by pg_dump version 17.5 (Ubuntu 17.5-0ubuntu0.25.04.1)

-- Started on 2025-07-26 16:04:24 CEST

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 16385)
-- Name: grafana_file; Type: TABLE; Schema: public; Owner: app
--

CREATE TABLE public.grafana_file (
    creation_date timestamp without time zone NOT NULL,
    size integer NOT NULL
);


ALTER TABLE public.grafana_file OWNER TO app;

--
-- TOC entry 3345 (class 0 OID 16385)
-- Dependencies: 215
-- Data for Name: grafana_file; Type: TABLE DATA; Schema: public; Owner: app
--

COPY public.grafana_file (creation_date, size) FROM stdin;
2025-07-25 06:23:52.899231	5000
2025-07-26 06:23:59.13001	4000
2025-07-24 07:09:49.193354	6000
2025-07-22 06:24:04.625707	1000
2025-07-21 06:23:52.899231	3000
2025-07-20 06:23:52.899231	7500
2025-07-25 06:25:52.899231	5300
2025-07-26 02:09:44.131377	7000
2025-07-26 12:09:44.131377	5000
2025-07-26 07:09:44.131377	8000
\.


-- Completed on 2025-07-26 16:04:24 CEST

--
-- PostgreSQL database dump complete
--

