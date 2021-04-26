--
-- PostgreSQL database dump
--

-- Dumped from database version 13.1 (Ubuntu 13.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 13.1 (Ubuntu 13.1-1.pgdg20.04+1)

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
-- Name: actualizarestadoactividad(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.actualizarestadoactividad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
begin
    IF (new.task_pending = 0 and old.state='pendiente') then 
		update activities  
		set state = 'finalizada' 
		where id = old.id;
	END IF;
	IF (not new.task_pending = 0 and old.state='finalizada') then 
    	update activities  
		set state = 'pendiente' 
		where id = old.id;
	END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION public.actualizarestadoactividad() OWNER TO root;

--
-- Name: actualizarestadoworkplan(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.actualizarestadoworkplan() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
begin
    IF (new.activity_pending = 0 and old.state='pendiente') then 
		update work_plans  
		set state = 'finalizada' 
		where id = old.id;
	END IF;
	IF (not new.activity_pending = 0 and old.state='finalizada') then 
    	update work_plans  
		set state = 'pendiente' 
		where id = old.id;
	END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION public.actualizarestadoworkplan() OWNER TO root;

--
-- Name: actualizarnumeroactividades(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.actualizarnumeroactividades() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	pending integer;
	finished integer;
begin
    IF (old.state = 'pendiente' and new.state='finalizada') then 
    	pending = (select activity_pending from work_plans where id = old.work_plan_id);
    	finished = (select activity_finished from work_plans where id = old.work_plan_id);
		update work_plans  
		set activity_pending = pending -1,
		activity_finished = finished +1 
		where id = old.work_plan_id;
	END IF;
	IF (old.state = 'finalizada' and new.state='pendiente') then 
    	pending = (select activity_pending from work_plans where id = old.work_plan_id);
    	finished = (select activity_finished from work_plans where id = old.work_plan_id);
		update work_plans  
		set activity_pending = pending +1,
		activity_finished = finished -1 
		where id = old.work_plan_id;
	END IF;

    RETURN NEW;
END
$$;


ALTER FUNCTION public.actualizarnumeroactividades() OWNER TO root;

--
-- Name: actualizarnumerotareas(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.actualizarnumerotareas() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	pending integer;
	finished integer;
begin
    IF (old.state = 'proceso' and new.state='finalizada') then 
    	pending = (select task_pending from activities where id = old.activity_id);
    	finished = (select task_finished from activities where id = old.activity_id);
		update activities  
		set task_pending = pending -1,
		task_finished = finished +1 
		where id = old.activity_id;
	END IF;
	IF (old.state = 'pendiente' and new.state='finalizada') then 
    	pending = (select task_pending from activities where id = old.activity_id);
    	finished = (select task_finished from activities where id = old.activity_id);
		update activities  
		set task_pending = pending -1,
		task_finished = finished +1 
		where id = old.activity_id;
	END IF;
	IF (old.state = 'finalizada' and new.state='proceso') then 
    	pending = (select task_pending from activities where id = old.activity_id);
    	finished = (select task_finished from activities where id = old.activity_id);
		update activities  
		set task_pending = pending +1,
		task_finished = finished -1 
		where id = old.activity_id;
	END IF;
	IF (old.state = 'finalizada' and new.state='pendiente') then 
    	pending = (select task_pending from activities where id = old.activity_id);
    	finished = (select task_finished from activities where id = old.activity_id);
		update activities  
		set task_pending = pending +1,
		task_finished = finished -1 
		where id = old.activity_id;
	END IF;

    RETURN NEW;
END
$$;


ALTER FUNCTION public.actualizarnumerotareas() OWNER TO root;

--
-- Name: eliminarnumeroactividades(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.eliminarnumeroactividades() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	pending integer;
	finished integer;
begin
	IF (old.state = 'pendiente' ) then 
		pending = (select activity_pending from work_plans where id = old.work_plan_id);
		update work_plans  
		set activity_pending = pending -1
		where id = old.work_plan_id;
	END IF;
	IF (old.state = 'finalizada') then 
		finished = (select activity_finished from work_plans where id = old.work_plan_id);
		update work_plans  
		set activity_finished = finished -1
		where id = old.work_plan_id;
	END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION public.eliminarnumeroactividades() OWNER TO root;

--
-- Name: eliminarnumerotareas(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.eliminarnumerotareas() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	pending integer;
	finished integer;
begin
	IF (old.state = 'proceso' or old.state = 'pendiente' ) then 
		pending = (select task_pending from activities where id = old.activity_id);
		update activities  
		set task_pending = pending -1
		where id = old.activity_id;
	END IF;
	IF (old.state = 'finalizada') then 
		finished = (select task_finished from activities where id = old.activity_id);
		update activities  
		set task_finished = finished -1
		where id = old.activity_id;
	END IF;
    RETURN NEW;
END
$$;


ALTER FUNCTION public.eliminarnumerotareas() OWNER TO root;

--
-- Name: insertarnumeroactividades(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.insertarnumeroactividades() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	pending integer;
	ida integer;
begin
	ida = new.work_plan_id;
	pending = (select activity_pending from work_plans where id = ida);
	update work_plans  
	set activity_pending = pending +1
	where id = ida;
    RETURN NEW;
END
$$;


ALTER FUNCTION public.insertarnumeroactividades() OWNER TO root;

--
-- Name: insertarnumerotareas(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.insertarnumerotareas() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	pending integer;
	ida integer;
begin
	ida = new.activity_id;
	pending = (select task_pending from activities where id = ida);
	update activities set task_pending = pending +1	where id = ida;
    RETURN NEW;
END
$$;


ALTER FUNCTION public.insertarnumerotareas() OWNER TO root;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.active_storage_attachments OWNER TO root;

--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.active_storage_attachments_id_seq OWNER TO root;

--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


ALTER TABLE public.active_storage_blobs OWNER TO root;

--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.active_storage_blobs_id_seq OWNER TO root;

--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


ALTER TABLE public.active_storage_variant_records OWNER TO root;

--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.active_storage_variant_records_id_seq OWNER TO root;

--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: activities; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.activities (
    id bigint NOT NULL,
    title character varying,
    state character varying,
    start_date date,
    end_date date,
    close_date date,
    task_pending integer,
    task_finished integer,
    work_plan_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.activities OWNER TO root;

--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.activities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.activities_id_seq OWNER TO root;

--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.activities_id_seq OWNED BY public.activities.id;


--
-- Name: admins; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.admins (
    id bigint NOT NULL,
    email character varying,
    name character varying,
    first_lastname character varying,
    second_lastname character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.admins OWNER TO root;

--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admins_id_seq OWNER TO root;

--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO root;

--
-- Name: commentaries; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.commentaries (
    id bigint NOT NULL,
    message text,
    issuer_id integer,
    issuer_date date,
    state character varying,
    activity_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.commentaries OWNER TO root;

--
-- Name: commentaries_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.commentaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.commentaries_id_seq OWNER TO root;

--
-- Name: commentaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.commentaries_id_seq OWNED BY public.commentaries.id;


--
-- Name: professor_summaries; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.professor_summaries (
    id bigint NOT NULL,
    professor_id integer,
    name character varying,
    first_lastname character varying,
    second_lastname character varying,
    grade character varying,
    email character varying,
    avatar character varying,
    num_tesis integer,
    num_tesis_med double precision,
    asignadas integer,
    dias_rev_med double precision,
    academic boolean,
    num_tesis_abandonadas integer,
    tiempo_final_med double precision,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    topicos character varying[] DEFAULT '{}'::character varying[],
    num_tesis_tot integer,
    grade_name character varying
);


ALTER TABLE public.professor_summaries OWNER TO root;

--
-- Name: professor_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.professor_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.professor_summaries_id_seq OWNER TO root;

--
-- Name: professor_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.professor_summaries_id_seq OWNED BY public.professor_summaries.id;


--
-- Name: proposals; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.proposals (
    id bigint NOT NULL,
    student_id integer,
    professor_id integer,
    topic_id integer,
    topic_name character varying,
    title character varying,
    summary text,
    rute_document character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    semester integer,
    year integer,
    student_name character varying,
    professor_name character varying,
    file integer
);


ALTER TABLE public.proposals OWNER TO root;

--
-- Name: proposals_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.proposals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.proposals_id_seq OWNER TO root;

--
-- Name: proposals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.proposals_id_seq OWNED BY public.proposals.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO root;

--
-- Name: student_summaries; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.student_summaries (
    id bigint NOT NULL,
    student_id integer,
    name character varying,
    first_lastname character varying,
    second_lastname character varying,
    year_income integer,
    email character varying,
    program_id integer,
    program_name character varying,
    num_temas integer,
    num_guias integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.student_summaries OWNER TO root;

--
-- Name: student_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.student_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.student_summaries_id_seq OWNER TO root;

--
-- Name: student_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.student_summaries_id_seq OWNED BY public.student_summaries.id;


--
-- Name: tasks; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.tasks (
    id bigint NOT NULL,
    title character varying,
    state character varying,
    start_date date,
    end_date date,
    close_date date,
    activity_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.tasks OWNER TO root;

--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tasks_id_seq OWNER TO root;

--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- Name: thesis_summaries; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.thesis_summaries (
    id bigint NOT NULL,
    thesis_id integer,
    thype_id integer,
    topic character varying,
    program_id integer,
    status character varying,
    year integer,
    semester integer,
    dias_rev integer,
    student_name character varying,
    student_first_lastname character varying,
    student_second_lastname character varying,
    guia_name character varying,
    guia_first_lastname character varying,
    guia_second_lastname character varying,
    title character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    guide_id integer,
    guia_email character varying,
    student_email character varying
);


ALTER TABLE public.thesis_summaries OWNER TO root;

--
-- Name: thesis_summaries_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.thesis_summaries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.thesis_summaries_id_seq OWNER TO root;

--
-- Name: thesis_summaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.thesis_summaries_id_seq OWNED BY public.thesis_summaries.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO root;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO root;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: work_plans; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.work_plans (
    id bigint NOT NULL,
    state character varying,
    trabajo_titulacion boolean,
    activity_pending integer,
    activity_finished integer,
    thesis_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.work_plans OWNER TO root;

--
-- Name: work_plans_id_seq; Type: SEQUENCE; Schema: public; Owner: root
--

CREATE SEQUENCE public.work_plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.work_plans_id_seq OWNER TO root;

--
-- Name: work_plans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: root
--

ALTER SEQUENCE public.work_plans_id_seq OWNED BY public.work_plans.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.activities ALTER COLUMN id SET DEFAULT nextval('public.activities_id_seq'::regclass);


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: commentaries id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.commentaries ALTER COLUMN id SET DEFAULT nextval('public.commentaries_id_seq'::regclass);


--
-- Name: professor_summaries id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.professor_summaries ALTER COLUMN id SET DEFAULT nextval('public.professor_summaries_id_seq'::regclass);


--
-- Name: proposals id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.proposals ALTER COLUMN id SET DEFAULT nextval('public.proposals_id_seq'::regclass);


--
-- Name: student_summaries id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.student_summaries ALTER COLUMN id SET DEFAULT nextval('public.student_summaries_id_seq'::regclass);


--
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- Name: thesis_summaries id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.thesis_summaries ALTER COLUMN id SET DEFAULT nextval('public.thesis_summaries_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: work_plans id; Type: DEFAULT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.work_plans ALTER COLUMN id SET DEFAULT nextval('public.work_plans_id_seq'::regclass);


--
-- Data for Name: active_storage_attachments; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.active_storage_attachments (id, name, record_type, record_id, blob_id, created_at) FROM stdin;
2	file	Proposal	11	2	2021-04-11 22:30:20.933111
3	file	Proposal	12	3	2021-04-11 22:47:31.271692
4	file	Proposal	13	4	2021-04-11 22:49:00.08665
5	fileTest	Proposal	14	5	2021-04-11 22:56:46.067961
6	fileTest	Proposal	15	6	2021-04-11 23:03:45.161307
7	file	Proposal	16	7	2021-04-11 23:06:09.969341
8	file	Proposal	17	8	2021-04-11 23:10:32.076718
9	fileTest	Proposal	28	9	2021-04-11 23:31:41.63627
10	fileTest	Proposal	29	10	2021-04-11 23:33:39.689894
11	fileTest	Proposal	30	11	2021-04-11 23:39:49.189872
12	fileTest	Proposal	31	12	2021-04-11 23:40:21.155144
13	fileTest	Proposal	32	13	2021-04-11 23:42:47.791792
14	fileTest	Proposal	33	14	2021-04-11 23:46:48.156753
15	fileTest	Proposal	34	15	2021-04-11 23:51:26.260074
16	fileTest	Proposal	35	16	2021-04-11 23:51:48.853488
17	fileTest	Proposal	36	17	2021-04-13 23:37:09.135008
\.


--
-- Data for Name: active_storage_blobs; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.active_storage_blobs (id, key, filename, content_type, metadata, service_name, byte_size, checksum, created_at) FROM stdin;
2	kkcp3wzf3yiq15qc0oo4tzmegu4x	WhatsApp Image 2021-01-15 at 23.22.40.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	51214	pWJ2XHKeG15lBP8quBXc9g==	2021-04-11 22:30:20.903894
3	tldctz93ha2x1h382qrq2gtbgz2y	Tesis.pdf	application/pdf	{"identified":true,"analyzed":true}	local	1935302	pNobuNaPFnC2QXmFXGjbHA==	2021-04-11 22:47:31.268015
4	cn2ms958n5rrum6kk6fbr41exa4h	Tesis.pdf	application/pdf	{"identified":true,"analyzed":true}	local	1935302	pNobuNaPFnC2QXmFXGjbHA==	2021-04-11 22:49:00.083642
5	viump9c3gglsuehupstx7tofbyyk	Tesis.pdf	application/pdf	{"identified":true,"analyzed":true}	local	1935302	pNobuNaPFnC2QXmFXGjbHA==	2021-04-11 22:56:46.06407
6	06e186canubp9lrjqbp5pjyy6rdl	Tesis.pdf	application/pdf	{"identified":true,"analyzed":true}	local	1935302	pNobuNaPFnC2QXmFXGjbHA==	2021-04-11 23:03:45.156176
7	5mc4u5ctka8qppczpt5b1iu40kgx	Tesis.pdf	application/pdf	{"identified":true,"analyzed":true}	local	1935302	pNobuNaPFnC2QXmFXGjbHA==	2021-04-11 23:06:09.965763
8	y2x017p8zao5zjm6ow2a01cbj60w	Tesis.pdf	application/pdf	{"identified":true,"analyzed":true}	local	1935302	pNobuNaPFnC2QXmFXGjbHA==	2021-04-11 23:10:32.073507
9	ipvtgdnlrur2ff6pf0bmq06n2kyf	WhatsApp Image 2021-01-15 at 23.22.40.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	51214	pWJ2XHKeG15lBP8quBXc9g==	2021-04-11 23:31:41.59967
10	e33x2o39lptyz5tbnkarjwpwdb0a	WhatsApp Image 2021-01-15 at 23.22.40.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	51214	pWJ2XHKeG15lBP8quBXc9g==	2021-04-11 23:33:39.643234
11	60fv6rdc51fp7c6vfvn86vyxw78s	WhatsApp Image 2021-01-15 at 23.22.40.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	51214	pWJ2XHKeG15lBP8quBXc9g==	2021-04-11 23:39:49.18591
12	swifr5ppmnmfjlettbwry8dgznro	WhatsApp Image 2021-01-15 at 23.22.40.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	51214	pWJ2XHKeG15lBP8quBXc9g==	2021-04-11 23:40:21.151496
13	b7obi6hx1594jjt9b38ydy9a6l55	WhatsApp Image 2021-01-15 at 23.22.40.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	51214	pWJ2XHKeG15lBP8quBXc9g==	2021-04-11 23:42:47.788202
14	4aoav683c8nvuai6ud2i5ix7n4dc	WhatsApp Image 2021-01-15 at 23.22.40.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	51214	pWJ2XHKeG15lBP8quBXc9g==	2021-04-11 23:46:48.147977
15	bb6clcquy1drtgekcmao5x94a7g1	WhatsApp Image 2021-01-15 at 23.22.40.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	51214	pWJ2XHKeG15lBP8quBXc9g==	2021-04-11 23:51:26.255702
16	yi3b35074bjckkjq0zuyjy2ae3aw	WhatsApp Image 2021-01-15 at 23.22.40.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	51214	pWJ2XHKeG15lBP8quBXc9g==	2021-04-11 23:51:48.848991
17	8yktxm36ygm7yrk8ik0sg001wdro	WhatsApp Image 2021-01-15 at 23.22.40.jpeg	image/jpeg	{"identified":true}	local	51214	pWJ2XHKeG15lBP8quBXc9g==	2021-04-13 23:37:09.056558
\.


--
-- Data for Name: active_storage_variant_records; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.active_storage_variant_records (id, blob_id, variation_digest) FROM stdin;
\.


--
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.activities (id, title, state, start_date, end_date, close_date, task_pending, task_finished, work_plan_id, created_at, updated_at) FROM stdin;
106	actividad 1	pendiente	2020-03-24	2020-03-24	\N	0	0	50	2021-04-25 22:32:40.792146	2021-04-25 22:32:40.792146
\.


--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.admins (id, email, name, first_lastname, second_lastname, created_at, updated_at) FROM stdin;
1	cristian.sepulveda.co@usach.cl	cristian	Adm	Min	2021-03-03 04:09:06	2021-03-03 04:09:06
\.


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2021-03-02 01:35:27.591272	2021-03-02 01:35:27.591272
\.


--
-- Data for Name: commentaries; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.commentaries (id, message, issuer_id, issuer_date, state, activity_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: professor_summaries; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.professor_summaries (id, professor_id, name, first_lastname, second_lastname, grade, email, avatar, num_tesis, num_tesis_med, asignadas, dias_rev_med, academic, num_tesis_abandonadas, tiempo_final_med, created_at, updated_at, topicos, num_tesis_tot, grade_name) FROM stdin;
792	7	J.	L.	Jara	1	jljara@usach.cl	https://www.informatica.usach.cl/multimedia/academico_jara_thumb.jpg	8	1	0	0	f	5	1.3	2021-04-10 17:56:16.236837	2021-04-11 04:57:43.418226	{1}	8	Doctorado
793	8	Fernanda	Kri	Amar	2	fernanda.kri@usach.cl	https://www.informatica.usach.cl/multimedia/academico_kri_thumb.jpg	0	0	8	0	f	5	1.3	2021-04-10 17:56:16.300991	2021-04-10 17:57:45.895496	{1}	0	Magíster
789	4	Violeta	Chang	Camacho	1	violeta.chang@usach.cl	https://www.informatica.usach.cl/multimedia/IMG_0425-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:16.112371	2021-04-10 17:57:45.810419	{1}	0	Doctorado
795	10	Mauricio	Marín		1	mauricio.marin@usach.cl	https://www.informatica.usach.cl/multimedia/Foto-Doctorado-1-100x100.png	1	0.5	0	0	f	5	1.3	2021-04-10 17:56:16.346577	2021-04-11 05:04:53.668068	{3}	1	Doctorado
798	13	Víctor	Parada	Daza	1	victor.parada@usach.cl	https://www.informatica.usach.cl/multimedia/academico_parada-100x100-1388775647.jpg	14	1.4	0	0	f	5	1.3	2021-04-10 17:56:16.500447	2021-04-11 05:04:53.722021	{2,4}	14	Doctorado
797	12	Rosa	Muñoz	Calanchie	1	rosa.munoz@usach.cl	https://www.informatica.usach.cl/multimedia/academico_munoz_thumb.jpg	19	2.38	6	0	f	5	1.3	2021-04-10 17:56:16.394419	2021-04-11 05:14:03.163212	{}	19	Doctorado
803	18	Manuel	Villalobos	Cid	1	manuel.villalobos@usach.cl	https://www.informatica.usach.cl/multimedia/manuel-villalobos-100x100.jpeg	2	1	11	0	f	5	1.3	2021-04-10 17:56:16.580052	2021-04-11 04:57:43.590528	{}	2	Doctorado
799	14	Alcides	Quispe	Sanca	1	alcides.quispe@usach.cl	https://www.informatica.usach.cl/multimedia/FotoAQS-100x100.jpg	14	1.4	0	0	f	5	1.3	2021-04-10 17:56:16.511731	2021-04-11 05:04:53.748741	{}	14	Doctorado
800	15	Fernando	Rannou	Fuentes	3	fernando.rannou@usach.cl	https://www.informatica.usach.cl/multimedia/academico_rannou_thumb.jpg	5	1.25	0	0	f	5	1.3	2021-04-10 17:56:16.533521	2021-04-11 05:04:53.767251	{}	5	Civil
796	11	Leonel	Medina	Daza	1	leonel.medina@usach.cl	https://www.informatica.usach.cl/multimedia/LeoMedina.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:16.368476	2021-04-10 17:57:45.961746	{6}	0	Doctorado
801	16	Pablo	Román	Asenjo	1	pablo.roman.a@usach.cl	https://www.informatica.usach.cl/multimedia/proman-cara-100x100.png	1	0.5	0	0	f	5	1.3	2021-04-10 17:56:16.546444	2021-04-11 05:04:53.791748	{1,5}	1	Doctorado
787	2	Carolina	Bonacic	Castro	1	carolina.bonacic@usach.cl	https://www.informatica.usach.cl/multimedia/academico_bonacic_thumb.jpg	13	1.3	9	0	f	5	1.3	2021-04-10 17:56:16.067003	2021-04-11 05:04:53.524938	{3,5}	13	Doctorado
804	19	Mónica	Villanueva	Ilufi	3	monica.villanueva@usach.cl	https://www.informatica.usach.cl/multimedia/academico_villanueva_thumb.jpg	19	1.9	0	0	f	5	1.3	2021-04-10 17:56:16.600131	2021-04-11 05:04:53.826099	{}	19	Civil
806	21	Francisco	Acuña	Castillo	4	francisco.acuna@usach.cl		1	0.5	0	0	f	5	1.3	2021-04-10 17:56:16.633316	2021-04-11 05:04:53.853832	{}	1	Ejecución
790	5	Roberto	González	Ibáñez	1	cristian@dalt.cl	https://www.informatica.usach.cl/multimedia/academico_gonzalez_thumb.jpg	27	2.7	5	0	f	5	1.3	2021-04-10 17:56:16.134912	2021-04-11 05:04:53.573453	{}	27	Doctorado
802	17	Juan	Tapia	Farias	1	juan.example@usach.cl	https://www.informatica.usach.cl/multimedia/foto2-1-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:16.566583	2021-04-10 17:57:46.097289	{}	0	Doctorado
810	25	Arturo	Álvarez	Cea	3	arturo.alvarez@usach.cl	https://www.informatica.usach.cl/multimedia/183670_10150109326204941_2483555_n-100x100.jpg	6	0.75	0	0	f	5	1.3	2021-04-10 17:56:16.70023	2021-04-11 05:04:53.899347	{}	6	Civil
813	28	Felipe	Bello	Robles	1	felipe.bello@usach.cl	https://www.informatica.usach.cl/multimedia/fbello-1-100x100.jpg	1	0.5	0	0	f	5	1.3	2021-04-10 17:56:16.745503	2021-04-11 05:04:53.947179	{}	1	Doctorado
805	20	Cristóbal	Acosta	Jurado	2	cristobal.acosta@usach.cl	https://www.informatica.usach.cl/multimedia/cris-web1-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:16.612654	2021-04-10 17:57:46.161795	{2}	0	Magíster
794	9	Edmundo	Leiva-Lobos		1	edmundo.leiva@usach.cl	https://www.informatica.usach.cl/multimedia/academico_leiva_thumb.jpg	11	1.38	0	0	f	5	1.3	2021-04-10 17:56:16.323704	2021-04-11 05:14:03.127763	{2}	11	Doctorado
807	22	Víctor	Araya	Sánchez	2	victor.arayas@usach.cl	https://www.informatica.usach.cl/multimedia/Víctor-Araya-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:16.645752	2021-04-10 17:57:46.207772	{}	0	Magíster
808	23	Pamela	Aguirre	Guzmán	2	pamela.aguirre@usach.cl	https://www.informatica.usach.cl/multimedia/67762_10151186112789615_143124181_n-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:16.666507	2021-04-10 17:57:46.22658	{5}	0	Magíster
809	24	José	Allende	Reiher	3	jose.allendere@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:16.679616	2021-04-10 17:57:46.250143	{}	0	Civil
788	3	Max	Chacón	Pacheco	1	max.chacon@usach.cl	https://www.informatica.usach.cl/multimedia/fotomax-100x100.jpg	1	0.5	0	0	f	5	1.3	2021-04-10 17:56:16.089648	2021-04-11 05:04:53.546185	{6}	1	Doctorado
811	26	Fabián	Arismendi	Ferrada	3	fabian.arismendi@usach.cl	https://www.informatica.usach.cl/multimedia/ZK5Zj8Z0-100x100.jpeg	0	0	0	0	f	5	1.3	2021-04-10 17:56:16.7124	2021-04-10 17:57:46.293957	{}	0	Civil
812	27	Diego	Ávila	Orellana	4	diego.avila@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:16.733277	2021-04-10 17:57:46.315446	{}	0	Ejecución
791	6	Mario	Inostroza-Ponta		1	mario.inostroza@usach.cl	https://www.informatica.usach.cl/multimedia/academico_inostroza_thumb.jpg	3	0.5	0	0	f	5	1.3	2021-04-10 17:56:16.165876	2021-04-11 05:04:53.607827	{6}	3	Doctorado
814	29	Luis	Berríos	Peña	2	luis.berrios.p@gmail.com	https://www.informatica.usach.cl/multimedia/LUIS-BERRIOS-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:16.766416	2021-04-10 17:57:46.361492	{}	0	Magíster
815	30	Jaime	Calcagno	Bastidas	3	jaime.calcagno@mail.udp.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:16.778228	2021-04-10 17:57:46.38184	{}	0	Civil
817	32	Miguel	Cárcamo	Vásquez	2	miguel.carcamo@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:16.8229	2021-04-10 17:57:46.428688	{}	0	Magíster
818	33	Gerardo	Cerda	Neumann	2	gcerda.usach@gmail.com		0	0	0	0	f	5	1.3	2021-04-10 17:56:16.844527	2021-04-10 17:57:46.448991	{}	0	Magíster
819	34	Alejandro	Cisterna	Villalobos	4	Alejandro.Cisterna@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:16.867003	2021-04-10 17:57:46.476014	{}	0	Ejecución
820	35	Isidro	Cornejo	Espinoza	4	isidro.cornejo@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:16.877975	2021-04-10 17:57:46.495338	{}	0	Ejecución
821	36	Ricardo	Corbinaud	Pérez	2	ricardo.corbinaud@usach.cl , ricardo.corbinaud@gmail.com		0	0	0	0	f	5	1.3	2021-04-10 17:56:16.889561	2021-04-10 17:57:46.525145	{}	0	Magíster
822	37	Julian	Cortes	Momberg	2	Jcortes56@gmail.com		0	0	0	0	f	5	1.3	2021-04-10 17:56:16.911199	2021-04-10 17:57:46.54023	{}	0	Magíster
823	38	Eliana	Covarrubias	Gatica	1	eliana.covarrubias@usach.cl 		0	0	0	0	f	5	1.3	2021-04-10 17:56:16.922287	2021-04-10 17:57:46.564244	{}	0	Doctorado
824	39	Diego	Escobar	Lagos	2	diego.escobarla@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:16.944438	2021-04-10 17:57:46.581258	{}	0	Magíster
825	40	Víctor	Flores	Sánchez	2	victor.floress@usach.cl	https://www.informatica.usach.cl/multimedia/10752119_10204449049281498_1033936195_n-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:16.967239	2021-04-10 17:57:46.60536	{}	0	Magíster
826	41	Felipe	Fuentes	Bravo	2	felipe.fuentesb@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:16.987819	2021-04-10 17:57:46.629281	{}	0	Magíster
827	42	Jorge	Fuentes	Tapia	2	jorge.example@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.011871	2021-04-10 17:57:46.648222	{}	0	Magíster
828	43	Daniel	Gacitúa	Vásquez	4	daniel.gacitua@usach.cl	https://www.informatica.usach.cl/multimedia/dgacitua-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.034246	2021-04-10 17:57:46.672398	{}	0	Ejecución
829	44	Carlos	González	Cortés	3	carlos.gonzalez.c@usach.cl	https://www.informatica.usach.cl/multimedia/cgonzalez_foto_ss-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.055034	2021-04-10 17:57:46.694506	{}	0	Civil
830	45	Sara	González	Gallo	1	sara.gonzalez@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.078697	2021-04-10 17:57:46.714323	{}	0	Doctorado
831	46	Marco	González	Ibáñez	2	marco.gonzaib@gmail.com		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.100158	2021-04-10 17:57:46.727201	{}	0	Magíster
832	47	Gastón	González	Vuscovic	3	gaston6711@gmail.com	https://www.informatica.usach.cl/multimedia/foto-gaston-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.111327	2021-04-10 17:57:46.749606	{}	0	Civil
833	48	Felipe	Gormaz	Arancibia	3	felipe.gormaz@usach.cl	https://www.informatica.usach.cl/multimedia/IMG_3794-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.132996	2021-04-10 17:57:46.773692	{}	0	Civil
840	55	Jacqueline	Köhler	Casasempere	2	jacqueline.kohler@usach.cl	https://www.informatica.usach.cl/multimedia/perfil-100x100.jpg	2	0.5	0	0	f	5	1.3	2021-04-10 17:56:17.267531	2021-04-11 05:04:54.200138	{}	2	Magíster
835	50	Jorge	Guzmán	Ramírez	2	prof.jorge.guzman@gmail.com		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.165698	2021-04-10 17:57:46.814486	{}	0	Magíster
836	51	Luciano	Hidalgo	Sepúlveda	2	luciano.hidalgo@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.178443	2021-04-10 17:57:46.827679	{}	0	Magíster
837	52	Juan	Iturbe	Araya	2	jiturbe@usach.cl	https://www.informatica.usach.cl/multimedia/iturbe-100x100.jpg	5	0.83	0	0	f	5	1.3	2021-04-10 17:56:17.199928	2021-04-11 05:14:03.466745	{}	5	Magíster
834	49	Aldo	Guerra	González	2	aldo.guerra@usach.cl	https://www.informatica.usach.cl/multimedia/20190508_210156-100x100.jpg	1	0.5	0	0	f	5	1.3	2021-04-10 17:56:17.14496	2021-04-11 05:04:54.106873	{}	1	Magíster
841	56	Sergio	Llanos	Araya	2	sllanosa@yahoo.com		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.288956	2021-04-10 17:57:46.926269	{}	0	Magíster
842	57	Manuel	Manríquez	López	3	manuel.manriquez@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.313692	2021-04-10 17:57:46.948807	{}	0	Civil
843	58	Francisco	Muñoz	Bravo	2	francisco.munoz.b@usach.cl	https://www.informatica.usach.cl/multimedia/1915632_10208384301462171_9147635453883306097_n-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.335108	2021-04-10 17:57:46.969919	{}	0	Magíster
844	59	José	Muñoz	Gamboa	1	josemunozgamboa@gmail.com	https://www.informatica.usach.cl/multimedia/JMG-Foto-perfil-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.354823	2021-04-10 17:57:46.994908	{}	0	Doctorado
845	60	José	Orellana	Núñez	2	jose.orellanan@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.378264	2021-04-10 17:57:47.015835	{}	0	Magíster
846	61	Juan	Padilla	Delgado	2	juan.padilla@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.401164	2021-04-10 17:57:47.03911	{}	0	Magíster
847	62	Víctor	Peña	Latorre	2	victorhugo.pena@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.422012	2021-04-10 17:57:47.059986	{}	0	Magíster
848	63	Rodrigo	Osorio	Contreras	3	rodrigo.osorio.c@usach.cl	https://www.informatica.usach.cl/multimedia/12.490.847-7-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.487609	2021-04-10 17:57:47.080967	{}	0	Civil
849	64	Paulo	Quinsacara	Jofré	2	paulo.quinsacara.jofre@gmail.com 		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.499713	2021-04-10 17:57:47.105088	{}	0	Magíster
850	65	Consuelo	Ramírez	Santibáñez	2	consuelo.ramirez@manquehue.net		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.512456	2021-04-10 17:57:47.31754	{}	0	Magíster
851	66	Andrés	Rice	Mora	2	andres.rice@usach.cl		5	0.83	0	0	f	5	1.3	2021-04-10 17:56:17.534361	2021-04-11 05:14:03.604511	{}	5	Magíster
852	67	Oscar	Rojas	Díaz	2	oscar.rojas.d@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.554997	2021-04-10 17:57:47.381657	{}	0	Magíster
838	53	Javier	Jara	Valencia	2	j.jara.v@gmail.com		2	0.5	0	0	f	5	1.3	2021-04-10 17:56:17.221724	2021-04-11 05:04:54.154977	{}	2	Magíster
785	0	Héctor	Antillanca	Espina	1	hector.antillanca@usach.cl	https://www.informatica.usach.cl/multimedia/academico_antillanca_thumb.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:16.011106	2021-04-10 17:57:45.719727	{}	0	Doctorado
816	31	Pablo	González	Cantergiani	2	pablo.gonzalezca@usach.cl	https://www.informatica.usach.cl/multimedia/Captura22-100x100.png	0	0	0	0	f	5	1.3	2021-04-10 17:56:16.799912	2021-04-10 17:57:46.406797	{}	0	Magíster
853	68	Lilian	Salazar	Bustamante	3	lilian.salazar@usach.cl	https://www.informatica.usach.cl/multimedia/unnamed-1-100x100.png	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.577939	2021-04-10 17:57:47.404917	{}	0	Civil
786	1	Gonzalo	Acuña	Leiva	1	gonzalo.acuna@usach.cl	https://www.informatica.usach.cl/multimedia/academico_acuna_thumb.jpg	4	0.67	0	0	f	5	1.3	2021-04-10 17:56:16.045714	2021-04-11 05:14:03.049636	{3}	4	Doctorado
855	70	Cristián	Sepúlveda	Sánchez	3	cristian.sepulvedas@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.621476	2021-04-10 17:57:47.446848	{}	0	Civil
856	71	Alejandro	Soto	Saavedra	3	alejandro.soto@usach.cl	https://www.informatica.usach.cl/multimedia/Captura-100x100.png	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.645103	2021-04-10 17:57:47.472274	{}	0	Civil
857	72	Viktor	Tapia	Vasquez	3	viktor.tapia@usach.cl		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.666258	2021-04-10 17:57:47.492346	{}	0	Civil
858	73	Luis	Veas	Castillo	2	luis.veasc@usach.cl	https://www.informatica.usach.cl/multimedia/lvc-100x100.png	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.686767	2021-04-10 17:57:47.51489	{}	0	Magíster
859	74	Daniel	Vega	Araya	2	daniel.vega.a@usach.cl	https://www.informatica.usach.cl/multimedia/DVega-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.699475	2021-04-10 17:57:47.536524	{}	0	Magíster
860	75	Carlos	Vera	Escobar	2	carlos_vera1988@gmail.com		0	0	0	0	f	5	1.3	2021-04-10 17:56:17.720316	2021-04-10 17:57:47.560976	{}	0	Magíster
861	76	Joaquín	Villagra	Pacheco	2	joaquin.villagra@usach.cl	https://www.informatica.usach.cl/multimedia/fotografia_perfil_web-100x100.jpeg	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.744138	2021-04-10 17:57:47.580518	{}	0	Magíster
862	77	Daniel	Wladdimiro	Cottet	2	daniel.wladdimiro@usach.cl	https://www.informatica.usach.cl/multimedia/pp-100x100.jpeg	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.765694	2021-04-10 17:57:47.605951	{}	0	Magíster
863	78	Álvaro	Yáñez	Carrizo	2	aayanezc@gmail.com	https://www.informatica.usach.cl/multimedia/WIN_20180105_15_16_35_Pro-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.77709	2021-04-10 17:57:47.625027	{}	0	Magíster
864	79	Freddy	Zavala	Garcia	2	freddy.zavala@usach.cl	https://www.informatica.usach.cl/multimedia/Foto-Freddy-Zavala-100x100.jpg	0	0	0	0	f	5	1.3	2021-04-10 17:56:17.78688	2021-04-10 17:57:47.648144	{}	0	Magíster
865	80	René	Zárate	Meneses	4	rene.zarate@usach.cl	https://www.informatica.usach.cl/multimedia/foto-rz-100x100.jpeg	0	0	0	0	t	5	1.3	2021-04-10 17:56:17.810275	2021-04-10 17:57:47.66978	{3}	0	Ejecución
839	54	Bruno	Jerardino	Wiesenborn	2	bruno.jerardino@usach.cl	https://www.informatica.usach.cl/multimedia/br1.elapdis-100x100.jpg	5	0.63	0	0	f	5	1.3	2021-04-10 17:56:17.245516	2021-04-11 05:14:03.499376	{}	5	Magíster
854	69	Luis	Ríos	Sepúlveda	2	luis.rios@usach.cl		15	1.88	0	0	f	5	1.3	2021-04-10 17:56:17.599021	2021-04-11 05:14:03.643719	{}	15	Magíster
866	81	Edgardo	Sepúlveda	Sariego	4	edgardo.sepulveda.s@usach.cl	https://www.informatica.usach.cl/multimedia/foto-rz-100x100.jpeg	4	0.67	0	0	f	5	1.3	2021-04-10 17:56:17.820458	2021-04-11 05:14:03.743651	{}	4	Ejecución
867	82	Arturo	Terra	Vásquez	4	arturo.terra.v@usach.cl	https://www.informatica.usach.cl/multimedia/foto-rz-100x100.jpeg	5	0.63	0	0	f	5	1.3	2021-04-10 17:56:17.844775	2021-04-11 05:14:03.767113	{}	5	Ejecución
869	84	Ricardo	Contreras	Sepúlveda	4	ricardo.contreras.s@usach.cl	https://www.informatica.usach.cl/multimedia/foto-rz-100x100.jpeg	2	1	0	0	f	5	1.3	2021-04-10 17:56:17.876683	2021-04-11 04:57:44.048193	{}	2	Ejecución
868	83	Nicolás	Hidalgo	Castillo	4	nicolas.hidalgo.c@usach.cl	https://www.informatica.usach.cl/multimedia/foto-rz-100x100.jpeg	2	0.5	0	0	f	5	1.3	2021-04-10 17:56:17.865079	2021-04-11 05:04:54.445167	{}	2	Ejecución
870	85	Irene	Zuccar	Parrini	4	irene.zuccar.p@usach.cl	https://www.informatica.usach.cl/multimedia/foto-rz-100x100.jpeg	1	0.5	0	0	f	5	1.3	2021-04-10 17:56:17.899395	2021-04-11 05:04:54.470021	{}	1	Ejecución
871	86	Cristóbal	Acosta	Jurado	4	cristobal.acosta.j@usach.cl	https://www.informatica.usach.cl/multimedia/foto-rz-100x100.jpeg	1	0.5	0	0	f	5	1.3	2021-04-10 17:56:17.921031	2021-04-11 05:04:54.488507	{}	1	Ejecución
\.


--
-- Data for Name: proposals; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.proposals (id, student_id, professor_id, topic_id, topic_name, title, summary, rute_document, created_at, updated_at, semester, year, student_name, professor_name, file) FROM stdin;
37	5	806	4	Redes y Seguridad	tituloooo	dsfsdfs		2021-04-19 02:43:04.555026	2021-04-23 20:53:08.020211	1	2020	Joaquín Abel Acuña Espinoza	Francisco Acuña Castillo	\N
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.schema_migrations (version) FROM stdin;
20210218140605
20210218141336
20210221200007
20210228024157
20210301171007
20210302232013
20210302234629
20210324235052
20210326200428
20210327205359
20210328214037
20210404190745
20210404223608
20210410002748
20210411165010
20210411172704
\.


--
-- Data for Name: student_summaries; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.student_summaries (id, student_id, name, first_lastname, second_lastname, year_income, email, program_id, program_name, num_temas, num_guias, created_at, updated_at) FROM stdin;
6	\N	Cristian Sepúlveda	\N	\N	\N	cristian@dalt.clfsdfs	\N	\N	\N	\N	2021-04-20 02:41:34.508948	2021-04-20 02:41:34.508948
10	4	Israel Gedeón Elías	Martínez	Montenegro	2012	israel.gedeonelias.martinez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:56.822469	2021-04-22 22:32:02.954431
11	5	Ian Isaí	Orellana	Cayupan	2011	ian.isai.orellana@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:56.845979	2021-04-22 22:32:02.978771
12	6	Diego Ignacio	Méndez	Lazo	2010	diego.ignacio.mendez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:56.864315	2021-04-22 22:32:03.000252
13	7	Carlos Felipe	Cáceres	Rodríguez	2012	carlos.felipe.caceres@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:56.875977	2021-04-22 22:32:03.022145
15	9	Marcelo Antonio	Acevedo	Pavez	2011	marcelo.antonio.acevedo@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:56.918913	2021-04-22 22:32:03.069253
16	10	Ana Karina	Villagrán	Ibarra	2010	ana.karina.villagran@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:56.950288	2021-04-22 22:32:03.089549
17	11	Luis Alfredo	Guerra	Aedo	2012	luis.alfredo.guerra@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:56.969015	2021-04-22 22:32:03.121751
19	13	Jonathan Iván	Catalán	Álvarez	2011	jonathan.ivan.catalan@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.009936	2021-04-22 22:32:03.169255
20	14	Catalina	Ortiz	Ugalde	2012	catalina.ortiz@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.029604	2021-04-22 22:32:03.189411
21	15	Sergio Andrés	Medina	Medel	2010	sergio.andres.medina@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.041492	2021-04-22 22:32:03.219925
23	17	Daniel Alejandro	Ravelo	Riveros	2012	daniel.alejandro.ravelo@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.082975	2021-04-22 22:32:03.266032
24	18	Claudio Nicolás	Rojas	Fuentealba	2008	claudio.nicolas.rojas@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.107474	2021-04-22 22:32:03.289032
25	19	Esteban Andrés	Abarca	Rubio	2008	esteban.andres.abarca@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.130002	2021-04-22 22:32:03.311286
26	20	Felipe Andrés	Valenzuela	Hernández	2008	felipe.andres.valenzuela@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.140988	2021-04-22 22:32:03.332522
28	22	Rodrigo Andrés	Monsalve	Lagos	2009	rodrigo.andres.monsalve@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.175456	2021-04-22 22:32:03.378605
29	23	Maximiliano	Hernández	San Martín	2009	maximiliano.hernandez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.198193	2021-04-22 22:32:03.399378
30	24	Esteban	Holtheuer	Rojas	2009	esteban.holtheuer@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.217867	2021-04-22 22:32:03.42055
31	25	Alex Omar	Gárate	Plaza	2008	alex.omar.garate@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.242445	2021-04-22 22:32:03.433001
33	27	Luis Ignacio	Garrido	Pardo	2010	luis.ignacio.garrido@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.275158	2021-04-22 22:32:03.479682
34	28	Felipe Javier	Piñeiro	Poblete	2008	felipe.javier.pineiro@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.286123	2021-04-22 22:32:03.499719
35	29	Diego Enrique	Olavarría	Úbeda	2008	diego.enrique.olavarria@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.308169	2021-04-22 22:32:03.534822
37	31	Gabriel Enrique	Salas	Puga	2008	gabriel.enrique.salas@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.345756	2021-04-22 22:32:03.577934
38	32	Alex Rodrigo	Mellado	Castillo	2008	alex.rodrigo.mellado@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.365504	2021-04-22 22:32:03.599843
39	33	María José	Córdova	Celedón	2010	maria.jose.cordova@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.387488	2021-04-22 22:32:03.620554
41	35	Rodrigo Alejandro	Ramírez	Garzo	2008	rodrigo.alejandro.ramirez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.430429	2021-04-22 22:32:03.671142
42	36	Valentino Andrés	Carmona	Victoriano	2008	valentino.andres.carmona@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.442075	2021-04-22 22:32:03.705149
44	38	Rodrigo Antonio Ismael	Martínez	Silva	2009	rodrigo.antonioismael.martinez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.474027	2021-04-22 22:32:03.764511
45	39	Ariel Esteban	Meriño	Mena	2008	ariel.esteban.merino@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.487013	2021-04-22 22:32:03.814275
47	41	Patricio Javier	Jara	Herrera	2008	patricio.javier.jara@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.529448	2021-04-22 22:32:03.933762
48	42	Ángel David	Garín	Morales	2008	angel.david.garin@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.54273	2021-04-22 22:32:03.954094
49	43	Matias Antonio	Lazos	Álvarez	2008	matias.antonio.lazos@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.562923	2021-04-22 22:32:03.977641
51	45	Luis Alberto	Loyola	Vidal	2010	luis.alberto.loyola@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.596391	2021-04-22 22:32:04.020426
52	46	Camilo Andrés	Correa	Ruz	2008	camilo.andres.correa@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.60972	2021-04-22 22:32:04.043303
53	47	Sebastián Andrés	Meneses	Núñez	2009	sebastian.andres.meneses@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.629206	2021-04-22 22:32:04.063089
55	49	Alberto Andrés	Toro	Figueroa	2008	alberto.andres.toro@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.675371	2021-04-22 22:32:04.110158
56	50	Paola Andrea	Ulloa	Besserer	2010	paola.andrea.ulloa@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.696203	2021-04-22 22:32:04.134207
57	51	Vasco Esteban	Vergara	Arellano	2010	vasco.esteban.vergara@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.708272	2021-04-22 22:32:04.155093
58	52	Rodrigo Andrés	Rivas	Reyes	2009	rodrigo.andres.rivas@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.728965	2021-04-22 22:32:04.179728
60	54	Francisco Javier	Vergara	Peña	2008	francisco.javier.vergara@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.76299	2021-04-22 22:32:04.219765
61	55	David Alberto	Hans	Castillo	2010	david.alberto.hans@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.776017	2021-04-22 22:32:04.240985
5	1	Joaquín Abel	Acuña	Espinoza	2012	cristian.sepulveda.co@gmail.com	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-07 01:31:20.652722	2021-04-22 22:45:24.095802
8	2	Ignacio Nicolás	Cuadra	Zamora	2011	ignacio.nicolas.cuadra@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:56.775905	2021-04-22 22:32:02.913791
65	59	Chien-Hung	Lin		2008	chien-hung.lin@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.857466	2021-04-22 22:32:04.329622
66	60	Daniel Ignacio	Brown	Madariaga	2010	daniel.ignacio.brown@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.877618	2021-04-22 22:32:04.354516
68	62	Esteban Agustín	González	Riveros	2009	esteban.agustin.gonzalez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.918049	2021-04-22 22:32:04.4
69	63	Juan Pablo	Vera	Riquelme	2010	juan.pablo.vera@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.942873	2021-04-22 22:32:04.419886
70	64	José Ignacio	Cortés	Tapia	2008	jose.ignacio.cortes@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.963607	2021-04-22 22:32:04.441295
72	66	Esteban Andrés	Ortiz	Cáceres	2009	esteban.andres.ortiz@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.018727	2021-04-22 22:32:04.486086
73	67	Jaime Alberto	Moreira	Gatica	2010	jaime.alberto.moreira@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.042593	2021-04-22 22:32:04.507168
75	69	Patricia Marcela	Riquelme	Jeldres	2009	patricia.marcela.riquelme@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.086564	2021-04-22 22:32:04.552221
76	70	Jaime Andrés	Vidal	Oliva	2011	jaime.andres.vidal@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.10996	2021-04-22 22:32:04.578307
77	71	Rodrigo Andrés	Yáñez	Gutiérrez	2010	rodrigo.andres.yanez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.129784	2021-04-22 22:32:04.602557
79	73	Matías Nicolás	Flores	Salas	2011	matias.nicolas.flores@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.17468	2021-04-22 22:32:04.645299
80	74	Andrés Mateo	Amengual	Burgos	2009	andres.mateo.amengual@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.197316	2021-04-22 22:32:04.670363
82	76	Ricardo Fabián	Zúñiga	Antiñirre	2009	ricardo.fabian.zuniga@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.241777	2021-04-22 22:32:04.733703
83	77	Álvaro Andrés	Maldonado	Pinto	2010	alvaro.andres.maldonado@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.264061	2021-04-22 22:32:04.755696
84	78	Claudia Irene	Guzmán	Silva	2010	claudia.irene.guzman@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.307738	2021-04-22 22:32:04.780455
85	79	Pablo Andrés	Murga	Salvatierra	2009	pablo.andres.murga@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.347132	2021-04-22 22:32:04.79901
87	81	Matías Alejandro	Calderón	Quezada	2011	matias.alejandro.calderon@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.395406	2021-04-22 22:32:04.845737
88	82	Moisés Rodrigo	Moraga	Rojas	2010	moises.rodrigo.moraga@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.417389	2021-04-22 22:32:04.866893
90	84	Leonardo Osvaldo	Pavez	Pérez	2009	leonardo.osvaldo.pavez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.461321	2021-04-22 22:32:04.920005
91	85	Elias Eliace	Sobarzo	del Pino	2011	elias.eliace.sobarzo@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.474596	2021-04-22 22:32:04.951205
92	86	Jennifer Carolina	Venegas	Sandoval	2011	jennifer.carolina.venegas@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.562521	2021-04-22 22:32:04.982376
93	87	Alan Brandon	Vergara	Bravo	2010	alan.brandon.vergara@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.583424	2021-04-22 22:32:05.012679
95	89	Oscar José Antonio	Pinto	Salazar	2011	oscar.joseantonio.pinto@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.617535	2021-04-22 22:32:05.054175
96	90	Hernán Maximiliano	Olmedo	Jara	2010	hernan.maximiliano.olmedo@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.642208	2021-04-22 22:32:05.074421
98	92	Nicole Macarena	Henríquez	Sepúlveda	2009	nicole.macarena.henriquez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.683442	2021-04-22 22:32:05.119434
99	93	Katherine Marcela	Liberona	Irarrázabal	2010	katherine.marcela.liberona@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.706142	2021-04-22 22:32:05.141196
100	94	Jonás Mauricio	Astudillo	Concha	2009	jonas.mauricio.astudillo@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.727863	2021-04-22 22:32:05.164473
102	96	Nicolás Andrés	Vásquez	Tobar	2010	nicolas.andres.vasquez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.761748	2021-04-22 22:32:05.20601
103	97	Angus Tafari Amado	Pollmann	Stocker	2010	angus.tafariamado.pollmann@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.784178	2021-04-22 22:32:05.230861
105	99	Marcial Natalio	Hernández	Sánchez	2008	marcial.natalio.hernandez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.841912	2021-04-22 22:32:05.291537
106	100	Jorge Eduardo	Rebolledo	González	2008	jorge.eduardo.rebolledo@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.860614	2021-04-22 22:32:05.331011
107	101	Jorge Francisco	Cabezas	Morales	2009	jorge.francisco.cabezas@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.884302	2021-04-22 22:32:05.355769
109	103	Benjamín Samuel Elías	Quintana	Oviedo	2007	benjamin.samuelelias.quintana@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.928774	2021-04-22 22:32:05.401365
110	104	Felipe Antonio	Iribarren	Viertel	2008	felipe.antonio.iribarren@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.948998	2021-04-22 22:32:05.433642
111	105	Joel Alain	Avalos	Pincheira	2009	joel.alain.avalos@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.961112	2021-04-22 22:32:05.452565
113	107	Armando Esteban	Rojas	Muñoz	2009	armando.esteban.rojas@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.993506	2021-04-22 22:32:05.499053
114	108	Leonardo Alexis	Cabrera	Lobos	2008	leonardo.alexis.cabrera@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.007334	2021-04-22 22:32:05.535736
115	109	Jorge Bermecides	Salazar	Castro	2007	jorge.bermecides.salazar@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.02722	2021-04-22 22:32:05.556625
117	111	Víctor Alonso	Reyes	Tapia	2008	victor.alonso.reyes@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.081161	2021-04-22 22:32:05.618274
118	112	Diego Antonio	Arenas	Riveros	2013	diego.antonio.arenas@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.09511	2021-04-22 22:32:05.64134
64	58	Daniel Fernando	Vargas	Mattheus	2009	daniel.fernando.vargas@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.832106	2021-04-22 22:32:04.309243
122	116	Camila Margarita	Márquez	Carrasco	2010	camila.margarita.marquez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.183213	2021-04-22 22:32:05.740589
123	117	Marcelo Hernán	Vega	Janhsen	2011	marcelo.hernan.vega@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.207775	2021-04-22 22:32:05.765904
125	119	David Ignacio	Aguilar	Borne	2007	david.ignacio.aguilar@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.260539	2021-04-22 22:32:05.806316
127	121	Juan Pablo	Reyes	Sepúlveda	2007	juan.pablo.reyes@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.327442	2021-04-22 22:32:05.859944
129	123	Bastian	Ganga	Peña	2009	bastian.ganga@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.407254	2021-04-22 22:32:05.919303
130	124	Javier Andrés	Henríquez	Acevedo	2008	javier.andres.henriquez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.428442	2021-04-22 22:32:05.94001
132	126	Luis Ignacio	Migryk	Tapia	2011	luis.ignacio.migryk@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.463741	2021-04-22 22:32:05.990006
133	127	Luis Felipe	Riquelme	Pradenas	2011	luis.felipe.riquelme@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.482826	2021-04-22 22:32:06.019149
134	128	Fernando Humberto	Briceño	Gómez	2013	fernando.humberto.briceno@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.505672	2021-04-22 22:32:06.045883
136	130	Víctor José	Lebil	Legue	2009	victor.jose.lebil@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.572991	2021-04-22 22:32:06.10718
137	131	Gabriel Osvaldo	Gómez	Abarca	2007	gabriel.osvaldo.gomez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.593597	2021-04-22 22:32:06.148292
139	133	Nicolás Emilio Antonio	Montenegro	Varela	2009	nicolas.emilioantonio.montenegro@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.629306	2021-04-22 22:32:06.198603
140	134	Martín Santiago	González	Sotomayor	2007	martin.santiago.gonzalez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.64979	2021-04-22 22:32:06.231395
142	136	Nicolás Ignacio	Rozas	Sepúlveda	2008	nicolas.ignacio.rozas@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.694315	2021-04-22 22:32:06.297464
143	137	Jorge Hernán	Valenzuela	Castro	2008	jorge.hernan.valenzuela@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.715274	2021-04-22 22:32:06.323171
144	138	Gustavo Alberto	Salvo	Lara	2007	gustavo.alberto.salvo@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.727934	2021-04-22 22:32:06.349926
145	139	Pablo Iván	González	Alarcón	2012	pablo.ivan.gonzalez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.73924	2021-04-22 22:32:06.379377
147	141	Germán	Bichon	Campos	2013	german.bichon@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.782026	2021-04-22 22:32:06.433034
148	142	Fernanda Paz	Retamal	Fernández	2011	fernanda.paz.retamal@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.794026	2021-04-22 22:32:06.451493
149	143	Diego Ignacio	Polanco	Berrios	2011	diego.ignacio.polanco@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.816401	2021-04-22 22:32:06.471393
151	145	Ariel Ignacio	Tirado	Maturana	2013	ariel.ignacio.tirado@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.86191	2021-04-22 22:32:06.517511
152	146	Sebastián Ignacio	Vallejos	Arroyo	2012	sebastian.ignacio.vallejos@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.882378	2021-04-22 22:32:06.542122
154	148	Javiera Fernanda	Sáez	León	2012	javiera.fernanda.saez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.916572	2021-04-22 22:32:06.585973
155	149	Mario Francisco	Álvarez	Molina	2010	mario.francisco.alvarez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.939534	2021-04-22 22:32:06.607017
157	151	Fabián Andrés	Gómez	Cuevas	2011	fabian.andres.gomez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.98261	2021-04-22 22:32:06.649743
158	152	Tomás Baruch	Gutiérrez	Lethaby	2013	tomas.baruch.gutierrez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.005136	2021-04-22 22:32:06.672599
160	154	Patricio Andrés	Rocco	Hernández	2012	patricio.andres.rocco@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.048942	2021-04-22 22:32:06.728998
161	155	Pamela Alejandra	Olea	Parra	2011	pamela.alejandra.olea@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.072683	2021-04-22 22:32:06.750998
162	156	Ángelo Jesús	Carlier	González	2011	angelo.jesus.carlier@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.092413	2021-04-22 22:32:06.771968
163	157	Maximiliano Antonio	Herrera	Rendic	2012	maximiliano.antonio.herrera@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.109086	2021-04-22 22:32:06.794949
164	158	Nelson Andrés	Jerez	Vidal	2010	nelson.andres.jerez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.134373	2021-04-22 22:32:06.820625
166	160	Benjamin Ignacio	Pastene	Pastene	2010	benjamin.ignacio.pastene@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.184098	2021-04-22 22:32:06.872154
167	161	Fernando Joaquín	Handal	Ocampo	2011	fernando.joaquin.handal@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.204754	2021-04-22 22:32:06.895378
168	162	Jaime Hernan	Pavez	Pavez	2010	jaime.hernan.pavez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.225665	2021-04-22 22:32:06.927233
170	164	Camilo Andrés	Torres	Sepúlveda	2009	camilo.andres.torres@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.26194	2021-04-22 22:32:06.986315
171	165	Luis Alberto	Tapia	Araya	2010	luis.alberto.tapia@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.284064	2021-04-22 22:32:07.006237
173	167	Marcelo Alejandro	Escobar	Muñoz	2009	marcelo.alejandro.escobar@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.328562	2021-04-22 22:32:07.052318
174	168	Francisco Ignacio	Avello	Barrera	2011	francisco.ignacio.avello@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.348559	2021-04-22 22:32:07.074593
175	169	Mauricio	Oyarzún	Sepúlveda	2012	mauricio.oyarzun@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.377244	2021-04-22 22:32:07.095973
121	115	Matías José	Vargas	Mora	2012	matias.jose.vargas@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.161616	2021-04-22 22:32:05.720844
179	173	Jonathan Esteban	Padilla	López	2010	jonathan.esteban.padilla@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.459565	2021-04-22 22:32:07.197635
180	174	Carlos	Torres	Pérez	2009	carlos.torres@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.480769	2021-04-22 22:32:07.217289
182	176	Christian Igancio	Zaballa	Rojas	2010	christian.igancio.zaballa@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.515207	2021-04-22 22:32:07.270891
183	177	Kevin Alexis	Canales	Bustamante	2011	kevin.alexis.canales@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.527006	2021-04-22 22:32:07.295976
185	179	Felipe Christopher	Vilches	Céspedes	2011	felipe.christopher.vilches@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.560992	2021-04-22 22:32:07.339947
186	180	Alberto Daniel	Garrido	Andrade	2009	alberto.daniel.garrido@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.58362	2021-04-22 22:32:07.360036
188	182	Patricio Alberto	Vargas	Pino	2011	patricio.alberto.vargas@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.628801	2021-04-22 22:32:07.40413
189	183	Oscar Ignacio	Carrasco	Madriaga	2009	oscar.ignacio.carrasco@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.649722	2021-04-22 22:32:07.431048
190	184	José Antonio	Camus	Godoy	2011	jose.antonio.camus@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.67318	2021-04-22 22:32:07.450321
192	186	Náyada	Hernández	Oyanedel	2011	nayada.hernandez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.714888	2021-04-22 22:32:07.494201
193	187	Alfonso Javier	Henríquez	Handy	2011	alfonso.javier.henriquez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.737551	2021-04-22 22:32:07.517432
195	189	Andrés Gonzalo	Silva	Díaz	2011	andres.gonzalo.silva@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.782891	2021-04-22 22:32:07.562051
196	190	Cristián Alejandro	Gómez	Ibáñez	2010	cristian.alejandro.gomez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.808421	2021-04-22 22:32:07.580744
197	191	Cristóbal Eduardo del	Fierro	Berrios	2011	cristobal.eduardodel.fierro@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.828225	2021-04-22 22:32:07.599191
199	193	Diego Ignacio	González	Arce	2011	diego.ignacio.gonzalez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.871443	2021-04-22 22:32:07.636713
200	194	María José	Vera	Pincheira	2011	maria.jose.vera@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.893772	2021-04-22 22:32:07.660404
202	196	Juan Pablo	Véliz	García	2012	juan.pablo.veliz@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.937602	2021-04-22 22:32:07.714805
203	197	Franco	Ramorino	Guzmán	2013	franco.ramorino@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.962527	2021-04-22 22:32:07.738073
204	198	Isaac	Silva	Luna	2011	isaac.silva@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.981851	2021-04-22 22:32:07.770582
205	199	Polett Andrea	Pizarro	Pérez	2012	polett.andrea.pizarro@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:01.003105	2021-04-22 22:32:07.795135
7	1	Joaquín Abel	Acuña	Espinoza	2012	joaquin.abel.acuna@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:56.697322	2021-04-22 22:32:02.88651
9	3	Diego Ignacio	Díaz	Márquez	2010	diego.ignacio.diaz@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:56.797889	2021-04-22 22:32:02.934601
14	8	Pablo Ricardo	Ulloa	Castro	2012	pablo.ricardo.ulloa@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:56.898702	2021-04-22 22:32:03.046351
18	12	Jorge Ricardo	Cocio	Palavecino	2012	jorge.ricardo.cocio@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:56.986335	2021-04-22 22:32:03.146519
22	16	Nicolás Salvador	Muñoz	Zarricueta	2010	nicolas.salvador.munoz@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.063199	2021-04-22 22:32:03.246192
27	21	José Miguel	Cabrera	Bravo	2008	jose.miguel.cabrera@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.15272	2021-04-22 22:32:03.35724
32	26	Esteban Alejandro	Gaete	Flores	2010	esteban.alejandro.gaete@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.263871	2021-04-22 22:32:03.454485
36	30	Mario Ignacio	Muñoz	Villegas	2010	mario.ignacio.munoz@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.320788	2021-04-22 22:32:03.554719
40	34	Marco Antonio	Morales	Pincheira	2008	marco.antonio.morales@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.409887	2021-04-22 22:32:03.645562
43	37	Mosheh-Efra Osvaldo	Landaeta	Sánchez	2009	mosheh-efra.osvaldo.landaeta@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.461913	2021-04-22 22:32:03.745719
46	40	Daniel Mariano	Gacitúa	Vásquez	2010	daniel.mariano.gacitua@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.509309	2021-04-22 22:32:03.875974
50	44	Claudio Domingo	Plaza	Aguirre	2008	claudio.domingo.plaza@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.576383	2021-04-22 22:32:04.001038
54	48	Sebastián Ignacio	Acevedo	Carrasco	2010	sebastian.ignacio.acevedo@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.652629	2021-04-22 22:32:04.086527
59	53	Jonathan Felipe	Salinas	Aburto	2009	jonathan.felipe.salinas@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.742245	2021-04-22 22:32:04.199422
62	56	Camilo Ignacio	Jiménez	Moreno	2009	camilo.ignacio.jimenez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:57.795586	2021-04-22 22:32:04.265762
63	57	Augusto Alejandro	Toledo	Pollmann	2010	augusto.alejandro.toledo@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.808219	2021-04-22 22:32:04.286007
67	61	Ian Daniel	Hermansen	Poblete	2010	ian.daniel.hermansen@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.897866	2021-04-22 22:32:04.377711
71	65	Qixiong	Xiao	Flores	2008	qixiong.xiao@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:57.995717	2021-04-22 22:32:04.464676
74	68	Celso Javier	Gutiérrez	Gálvez	2009	celso.javier.gutierrez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.062686	2021-04-22 22:32:04.534177
78	72	Yerko Israel	Pino	Garay	2010	yerko.israel.pino@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.152037	2021-04-22 22:32:04.623058
178	172	Patricio Oriel	González	Álvarez	2012	patricio.oriel.gonzalez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.442492	2021-04-22 22:32:07.172401
81	75	Fernanda Geraldine	Estay	Cabello	2011	fernanda.geraldine.estay@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.217854	2021-04-22 22:32:04.703325
86	80	Richard Robinson	Saldías	Sanhueza	2010	richard.robinson.saldias@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.376997	2021-04-22 22:32:04.820602
89	83	Claudio Alejandro	Hernández	Pezo	2011	claudio.alejandro.hernandez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.442054	2021-04-22 22:32:04.888218
94	88	Álvaro Pedro	Felmer	Pizarro	2011	alvaro.pedro.felmer@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.597347	2021-04-22 22:32:05.034941
97	91	Pablo Javier	Salinas	Cabañas	2009	pablo.javier.salinas@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.661551	2021-04-22 22:32:05.098227
101	95	Edgar Oladio	Gatica	Martínez	2011	edgar.oladio.gatica@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.740292	2021-04-22 22:32:05.187267
104	98	Gustavo Andrés	Curifuta	Poblete	2011	gustavo.andres.curifuta@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:58.810946	2021-04-22 22:32:05.255449
108	102	Camila Fernanda	Torres	Villanueva	2008	camila.fernanda.torres@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.906883	2021-04-22 22:32:05.380231
112	106	Mauricio Leonel	Carús	Flores	2007	mauricio.leonel.carus@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:58.972946	2021-04-22 22:32:05.480751
116	110	Fernando Antonio	Rodríguez	Herrera	2008	fernando.antonio.rodriguez@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.050183	2021-04-22 22:32:05.587226
119	113	Abraham Ignacio	Cerda	Iturra	2012	abraham.ignacio.cerda@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.116719	2021-04-22 22:32:05.666591
120	114	Javiera Andrea	Torres	Muñoz	2011	javiera.andrea.torres@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.141023	2021-04-22 22:32:05.691164
124	118	Adrián Esteban	Garrido	Goicovic	2009	adrian.esteban.garrido@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.242212	2021-04-22 22:32:05.783701
126	120	Cristopher Ernesto	Muñoz	Sandoval	2009	cristopher.ernesto.munoz@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.305362	2021-04-22 22:32:05.833743
128	122	Williams John	Soza	Ibarra	2008	williams.john.soza@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.3823	2021-04-22 22:32:05.889538
131	125	Raúl Andrés	Olivares	Pasten	2010	raul.andres.olivares@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.448985	2021-04-22 22:32:05.964276
135	129	Juan Pablo	Retamales	Lepe	2011	juan.pablo.retamales@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.527117	2021-04-22 22:32:06.07882
138	132	Pablo Ignacio	Morales	Román	2010	pablo.ignacio.morales@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.605283	2021-04-22 22:32:06.173247
141	135	Claudia Alejandra	Bustamante	Arce	2008	claudia.alejandra.bustamante@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.675534	2021-04-22 22:32:06.264723
146	140	Francisco Matías	Lagos	Sepúlveda	2012	francisco.matias.lagos@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.762292	2021-04-22 22:32:06.409656
150	144	Marcelo Nicolás	Muñoz	Muñoz	2013	marcelo.nicolas.munoz@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.840586	2021-04-22 22:32:06.49685
153	147	David Orión	Calistro	Cayuqueo	2012	david.orion.calistro@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:28:59.89376	2021-04-22 22:32:06.562607
156	150	Christian David	Vidal	Cerda	2013	christian.david.vidal@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:28:59.960914	2021-04-22 22:32:06.630335
159	153	Juan Cristián	Giglio	Gutiérrez	2012	juan.cristian.giglio@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.028128	2021-04-22 22:32:06.701194
165	159	Rodrigo Carlos	Cerda	Ruiz	2012	rodrigo.carlos.cerda@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.151766	2021-04-22 22:32:06.844381
169	163	María Constanza	Flores	González	2009	maria.constanza.flores@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.239021	2021-04-22 22:32:06.952522
172	166	Diego Iván	Miranda	Gipoulou	2009	diego.ivan.miranda@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.30796	2021-04-22 22:32:07.030729
176	170	Matías	Aguiló	Correa	2011	matias.aguilo@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.394521	2021-04-22 22:32:07.120207
177	171	Kevin Daniel	Farías	Sandoval	2011	kevin.daniel.farias@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.416701	2021-04-22 22:32:07.153121
181	175	Rodrigo Andrés	Cerda	Ponce	2009	rodrigo.andres.cerda@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.494306	2021-04-22 22:32:07.239225
184	178	Fabián Isaías	Urbina	Ampuero	2011	fabian.isaias.urbina@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.539243	2021-04-22 22:32:07.31658
187	181	Juan Manuel	Herrera	Vega	2010	juan.manuel.herrera@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.605064	2021-04-22 22:32:07.383376
191	185	Milton Jonnathan	Rosas	Paredes	2010	milton.jonnathan.rosas@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.694997	2021-04-22 22:32:07.471023
194	188	Alfredo Marcelino	López	Allende	2010	alfredo.marcelino.lopez@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.760627	2021-04-22 22:32:07.538025
198	192	Bryan Alfonso	Guzmán	Álvarez	2010	bryan.alfonso.guzman@usach.cl	3	Ingeniería Civil en Informática	1	1	2021-04-22 22:29:00.850753	2021-04-22 22:32:07.617919
201	195	René Ignacio	Zárate	Meneses	2012	rene.ignacio.zarate@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:00.917518	2021-04-22 22:32:07.6982
206	200	Juan Andrés	Barrera	Barril	2012	juan.andres.barrera@usach.cl	4	Ingeniería en Ejecución de Computación e Informática	1	1	2021-04-22 22:29:01.029654	2021-04-22 22:32:07.816057
\.


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.tasks (id, title, state, start_date, end_date, close_date, activity_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: thesis_summaries; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.thesis_summaries (id, thesis_id, thype_id, topic, program_id, status, year, semester, dias_rev, student_name, student_first_lastname, student_second_lastname, guia_name, guia_first_lastname, guia_second_lastname, title, created_at, updated_at, guide_id, guia_email, student_email) FROM stdin;
3251	51	2	Redes y Seguridad	4	CL	2016	1	0	Jaime Alberto	Moreira	Gatica	Alcides	Quispe	Sanca	Portal web de avisos clasificados para la compra y venta de bienes y servicios dentro de Chile	2021-03-28 20:33:14.640065	2021-03-28 20:33:14.640065	14	alcides.quispe@usach.cl	jaime.alberto.moreira@usach.cl
3250	50	1	Informática Educativa	3	OP	2016	2	0	Mario Ignacio	Muñoz	Villegas	Rosa	Muñoz	Calanchie	Objeto de aprendizaje para el estudio del marco de desarrollo de software SCRUM	2021-03-28 20:33:14.624796	2021-03-28 20:33:14.624796	12	rosa.munoz@usach.cl	cristian.sepulveda.co@gmail.com
3252	52	3	Biología y Medicina	4	OP	2016	1	0	Marco Antonio	Morales	Pincheira	Rosa	Muñoz	Calanchie	Desarrollo de objetos de aprendizaje para apoyar el estudio de la telefonía IP	2021-03-28 20:33:14.65838	2021-03-28 20:33:14.65838	12	rosa.munoz@usach.cl	marco.antonio.morales@usach.cl
3253	53	2	Interacción Humano-Computador	4	OP	2016	1	0	Pablo Ignacio	Morales	Román	Andrés	Rice	Mora	Apoyo mediante tecnologías de información al programa de apoyo a la pequeña y mediana minería PAMMA	2021-03-28 20:33:14.67671	2021-03-28 20:33:14.67671	66	andres.rice@usach.cl	pablo.ignacio.morales@usach.cl
3254	54	1	Interacción Humano-Computador	4	OP	2016	1	0	Nicolás Emilio Antonio	Montenegro	Varela	Alcides	Quispe	Sanca	Herramienta de apoyo en la selección de estudios primarios desde base de datos bibliográficas usando la técnica de Systematic Literature Review	2021-03-28 20:33:14.69351	2021-03-28 20:33:14.69351	14	alcides.quispe@usach.cl	nicolas.emilioantonio.montenegro@usach.cl
3255	55	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2016	2	0	Ariel Esteban	Meriño	Mena	Víctor	Parada	Daza	Reducción del tiempo de procesamiento de un algoritmo genético dinámico para el control de celosías móviles usando técnicas de aprendizaje automático	2021-03-28 20:33:14.715426	2021-03-28 20:33:14.715426	13	victor.parada@usach.cl	ariel.esteban.merino@usach.cl
3256	56	3	Sistemas Complejos	4	OP	2016	1	0	Sebastián Andrés	Meneses	Núñez	Roberto	González-Ibáñez		OpenGlove SDK: APis de alto nivel para C#, C++ Java y JavaScript	2021-03-28 20:33:14.736338	2021-03-28 20:33:14.736338	5		sebastian.andres.meneses@usach.cl
3257	57	2	Informática Educativa	4	OP	2016	1	0	Alex Rodrigo	Mellado	Castillo	Fernando	Rannou	Fuentes	Procedimiento y sistema informático para detectar necesidades de capacitación fundamentado en lo que describe la norma ISO 9001 sobre la gestión de los recursos humanos	2021-03-28 20:33:14.748937	2021-03-28 20:33:14.748937	15	fernando.rannou@usach.cl	alex.rodrigo.mellado@usach.cl
3258	58	3	Biología y Medicina	4	OP	2016	1	0	Rodrigo Antonio Ismael	Martínez	Silva	Roberto	González-Ibáñez		Rediseño del módulo de visualización de facturas y boletas	2021-03-28 20:33:14.770942	2021-03-28 20:33:14.770942	5		rodrigo.antonioismael.martinez@usach.cl
3259	59	1	Informática Educativa	3	OP	2016	2	0	Álvaro Andrés	Maldonado	Pinto	Edmundo	Leiva-Lobos		S-Box : un ambiente para analizar videos asociados al fenómeno de la sonrisa	2021-03-28 20:33:14.796159	2021-03-28 20:33:14.796159	9	edmundo.leiva@usach.cl	alvaro.andres.maldonado@usach.cl
3260	60	1	Informática Educativa	3	OP	2016	2	0	Luis Alberto	Loyola	Vidal	Fernando	Rannou	Fuentes	Sistema de monitoreo del rendimiento de conductores de una empresa de transporte público del Transantiago	2021-03-28 20:33:14.825846	2021-03-28 20:33:14.825846	15	fernando.rannou@usach.cl	luis.alberto.loyola@usach.cl
3261	61	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2016	2	0	Chien-Hung	Lin		Mónica	Villanueva	Ilufi	Enumeración de conjuntos independientes maximales en grafos sol	2021-03-28 20:33:14.888247	2021-03-28 20:33:14.888247	19	monica.villanueva@usach.cl	chien-hung.lin@usach.cl
3262	62	3	Redes y Seguridad	4	OP	2016	1	0	Matias Antonio	Lazos	Álvarez	Víctor	Parada	Daza	Interfaz web de monitoreo y reclamo de fallas de los cruces semaforizados de Santiago de Chile	2021-03-28 20:33:14.923148	2021-03-28 20:33:14.923148	13	victor.parada@usach.cl	matias.antonio.lazos@usach.cl
3263	63	1	Biología y Medicina	3	OP	2016	2	0	Mosheh-Efra Osvaldo	Landaeta	Sánchez	Carolina	Bonacic	Castro	Sistema web para la visualización temporal y geográfica de eventos en Twitter	2021-03-28 20:33:14.985721	2021-03-28 20:33:14.985721	2	carolina.bonacic@usach.cl	mosheh-efra.osvaldo.landaeta@usach.cl
3264	64	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2016	2	0	Camilo Ignacio	Jiménez	Moreno	Mario	Inostroza-Ponta		Algoritmo basado en GPU para apoyar el diseño de primers con enzimas de restricción para clonación molecular	2021-03-28 20:33:15.027363	2021-03-28 20:33:15.027363	6	mario.inostroza@usach.cl	camilo.ignacio.jimenez@usach.cl
3265	65	1	Interacción Humano-Computador	3	OP	2016	2	0	Patricio Javier	Jara	Herrera	Fernando	Rannou	Fuentes	Simulación basado en objetos concurrentes de las etapas físico-química y química del proceso de radiólisis del agua	2021-03-28 20:33:15.056471	2021-03-28 20:33:15.056471	15	fernando.rannou@usach.cl	patricio.javier.jara@usach.cl
3266	66	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2016	2	0	Esteban	Holtheuer	Rojas	Luis	Ríos	Sepúlveda	Desarrollo e implementación de Datamart para la gerencia comercial de una Asociación General de Fondos	2021-03-28 20:33:15.085356	2021-03-28 20:33:15.085356	69	luis.rios@usach.cl	esteban.holtheuer@usach.cl
3267	67	2	Informática Educativa	4	OP	2016	1	0	Ian Daniel	Hermansen	Poblete	Víctor	Parada	Daza	Composición musical utilizando programación genética	2021-03-28 20:33:15.107871	2021-03-28 20:33:15.107871	13	victor.parada@usach.cl	ian.daniel.hermansen@usach.cl
3268	68	1	Interacción Humano-Computador	3	OP	2016	2	0	David Alberto	Hans	Castillo	Rosa	Muñoz	Calanchie	MATLO.CSS : framework  CSS para el diseño gráfico de objetos de aprendizaje	2021-03-28 20:33:15.127439	2021-03-28 20:33:15.127439	12	rosa.munoz@usach.cl	david.alberto.hans@usach.cl
3269	69	1	Biología y Medicina	3	OP	2016	2	0	Celso Javier	Gutiérrez	Gálvez	Roberto	González-Ibáñez		MO : un sofware modular y extensible para la captura y visualización de datos multimodales	2021-03-28 20:33:15.15182	2021-03-28 20:33:15.15182	5		celso.javier.gutierrez@usach.cl
3270	70	2	Informática Educativa	4	OP	2016	1	0	Esteban Agustín	González	Riveros	Ricardo	Contreras	Sepúlveda	Aplicación web de consulta para apoyo a la gestión de ejecutivos de centro de contactos	2021-03-28 20:33:15.170671	2021-03-28 20:33:15.170671	84	ricardo.contreras.s@usach.cl	esteban.agustin.gonzalez@usach.cl
3271	71	1	Informática Educativa	3	OP	2016	2	0	Luis Ignacio	Garrido	Pardo	Rosa	Muñoz	Calanchie	Objeto de aprendizaje para el estudio de web services	2021-03-28 20:33:15.192173	2021-03-28 20:33:15.192173	12	rosa.munoz@usach.cl	luis.ignacio.garrido@usach.cl
3272	72	1	Biología y Medicina	4	OP	2016	1	0	Ángel David	Garín	Morales	Andrés	Rice	Mora	Sistema unificado de control de políticas de inversiones para administradoras de fondos de pensiones	2021-03-28 20:33:15.203877	2021-03-28 20:33:15.203877	66	andres.rice@usach.cl	angel.david.garin@usach.cl
3273	73	1	Informática Educativa	3	OP	2016	2	0	Alex Omar	Gárate	Plaza	Mónica	Villanueva	Ilufi	Sistema de apoyo para la comunicación con estudiantes de ingeniería informática de la Universidad de Santiago de Chile	2021-03-28 20:33:15.226718	2021-03-28 20:33:15.226718	19	monica.villanueva@usach.cl	alex.omar.garate@usach.cl
3274	74	1	Sistemas Complejos	3	OP	2016	2	0	Esteban Alejandro	Gaete	Flores	Roberto	González-Ibáñez		VORTICES: Ambiente de realidad virtual para apoyar la evaluación de interacciones con objetos de información digital	2021-03-28 20:33:15.247521	2021-03-28 20:33:15.247521	5		esteban.alejandro.gaete@usach.cl
3201	1	1	Interacción Humano-Computador	3	OP	2015	2	0	Camila Fernanda	Torres	Villanueva	Mónica	Villanueva	Ilufi	Algoritmos paralelos para la generación de los conjuntos independientes maximales de un grafo camino sin cuerdas y de un grafo caterpillar	2021-03-28 20:33:13.679747	2021-03-28 20:33:13.679747	19	monica.villanueva@usach.cl	camila.fernanda.torres@usach.cl
3202	2	1	Sistemas Complejos	3	OP	2015	2	0	Williams John	Soza	Ibarra	Mónica	Villanueva	Ilufi	Sistema de gestión docente del Departamento de Ingeniería Informática de la Universidad de Santiago de Chile módulo: Inscripción de asignaturas	2021-03-28 20:33:13.716651	2021-03-28 20:33:13.716651	19	monica.villanueva@usach.cl	williams.john.soza@usach.cl
3203	3	1	Redes y Seguridad	3	OP	2015	2	0	Gustavo Alberto	Salvo	Lara	Bruno	Jerardino	Wiesenborn	Una aplicación móvil desarrollada con lean UX para el apoyo a los postulantes en el exámen teórico de conducción	2021-03-28 20:33:13.738684	2021-03-28 20:33:13.738684	54	bruno.jerardino@usach.cl	gustavo.alberto.salvo@usach.cl
3204	4	3	Biología y Medicina	4	OP	2015	1	0	Jorge Bermecides	Salazar	Castro	Luis	Ríos	Sepúlveda	Desarrollo de un plan de recuperación ante desastres para procesos críticos de TI	2021-03-28 20:33:13.748717	2021-03-28 20:33:13.748717	69	luis.rios@usach.cl	jorge.bermecides.salazar@usach.cl
3205	5	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2015	2	0	Armando Esteban	Rojas	Muñoz	Arturo	Álvarez	Cea	Autopiloto integrado en Smartphone para vehículo aéreo no tripulado (UAV)	2021-03-28 20:33:13.771811	2021-03-28 20:33:13.771811	25	arturo.alvarez@usach.cl	armando.esteban.rojas@usach.cl
3206	6	1	Redes y Seguridad	3	OP	2015	2	0	Fernando Antonio	Rodríguez	Herrera	Alcides	Quispe	Sanca	Rediseño y propuesta de software para la gestión del proceso realizado en el cobro de facturas de servicios de proveedores en una inmobiliaria	2021-03-28 20:33:13.782362	2021-03-28 20:33:13.782362	14	alcides.quispe@usach.cl	fernando.antonio.rodriguez@usach.cl
3207	7	1	Sistemas Complejos	4	OP	2015	1	0	Víctor Alonso	Reyes	Tapia	Rosa	Muñoz	Calanchie	Objeto de aprendizaje para Blowfish	2021-03-28 20:33:13.79237	2021-03-28 20:33:13.79237	12	rosa.munoz@usach.cl	victor.alonso.reyes@usach.cl
3208	8	2	Sistemas Complejos	4	OP	2015	1	0	Juan Pablo	Reyes	Sepúlveda	Luis	Ríos	Sepúlveda	Prototipo de sistema web de apoyo a la gestión de máquinas virtuales en la empresa ADESSA Ltda.	2021-03-28 20:33:13.805254	2021-03-28 20:33:13.805254	69	luis.rios@usach.cl	juan.pablo.reyes@usach.cl
3209	9	2	Biología y Medicina	4	OP	2015	1	0	Jorge Eduardo	Rebolledo	González	Luis	Ríos	Sepúlveda	Desarrollo de un sistema de administración para el Salón de Belleza Ártico	2021-03-28 20:33:13.816098	2021-03-28 20:33:13.816098	69	luis.rios@usach.cl	jorge.eduardo.rebolledo@usach.cl
3210	10	1	Aplicaciones y Sistemas Escalables para la Web	4	OP	2015	1	0	Benjamín Samuel Elías	Quintana	Oviedo	Carolina	Bonacic	Castro	Twinfluentials : un algoritmo para medir influencia en líderes de opinión	2021-03-28 20:33:13.826747	2021-03-28 20:33:13.826747	2	carolina.bonacic@usach.cl	benjamin.samuelelias.quintana@usach.cl
3211	11	2	Aplicaciones y Sistemas Escalables para la Web	4	OP	2015	1	0	Cristopher Ernesto	Muñoz	Sandoval	Mónica	Villanueva	Ilufi	Enumeración de conjuntos independientes maximales en grafos K-Tree	2021-03-28 20:33:13.849596	2021-03-28 20:33:13.849596	19	monica.villanueva@usach.cl	cristopher.ernesto.munoz@usach.cl
3212	12	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2015	2	0	Rodrigo Andrés	Monsalve	Lagos	Roberto	González-Ibáñez		Dispositivo de retroalimentación táctil para interfaces naturales y de realidad virtual	2021-03-28 20:33:13.870679	2021-03-28 20:33:13.870679	5		rodrigo.andres.monsalve@usach.cl
3213	13	3	Interacción Humano-Computador	4	OP	2015	1	0	Víctor José	Lebil	Legue	Carolina	Bonacic	Castro	Aplicación de apoyo al proceso de gestión de servicios de taller	2021-03-28 20:33:13.884348	2021-03-28 20:33:13.884348	2	carolina.bonacic@usach.cl	victor.jose.lebil@usach.cl
3214	14	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2015	2	0	Felipe Antonio	Iribarren	Viertel	Rosa	Muñoz	Calanchie	Desarrollo de un objetivo de aprendizaje para apoyar el estudio de Android	2021-03-28 20:33:13.904806	2021-03-28 20:33:13.904806	12	rosa.munoz@usach.cl	felipe.antonio.iribarren@usach.cl
3215	15	1	Redes y Seguridad	3	OP	2015	2	0	Maximiliano	Hernández	San Martín	Víctor	Parada	Daza	Generación de algoritmos utilizando programación genética y coevolución con cambio de entorno para el problema de ordenamiento secuencial	2021-03-28 20:33:13.915804	2021-03-28 20:33:13.915804	13	victor.parada@usach.cl	maximiliano.hernandez@usach.cl
3216	16	2	Informática Educativa	4	OP	2015	1	0	Marcial Natalio	Hernández	Sánchez	J.	L.	Jara	PYTAXO: Generador de preguntas de opción múltiple para el curso de fundamentos de programación	2021-03-28 20:33:13.927309	2021-03-28 20:33:13.927309	7	jljara@usach.cl	marcial.natalio.hernandez@usach.cl
3217	17	1	Informática Educativa	3	OP	2015	2	0	Javier Andrés	Henríquez	Acevedo	Mónica	Villanueva	Ilufi	Sistema de gestión de postulantes de la Universidad Diego Portales a becas del Ministerio de Educación	2021-03-28 20:33:13.93739	2021-03-28 20:33:13.93739	19	monica.villanueva@usach.cl	javier.andres.henriquez@usach.cl
3218	18	1	Redes y Seguridad	3	OP	2015	2	0	Martín Santiago	González	Sotomayor	Bruno	Jerardino	Wiesenborn	Una aplicación móvil desarrollada con Lean Ux para la evaluación psico y sensomotora previa al examen de conducción	2021-03-28 20:33:13.949184	2021-03-28 20:33:13.949184	54	bruno.jerardino@usach.cl	martin.santiago.gonzalez@usach.cl
3219	19	3	Sistemas Complejos	4	OP	2015	1	0	Gabriel Osvaldo	Gómez	Abarca	Luis	Ríos	Sepúlveda	Sistema de monitoreo y alertas para plataformas de servicio en entorno virtuales VMWARE	2021-03-28 20:33:13.959365	2021-03-28 20:33:13.959365	69	luis.rios@usach.cl	gabriel.osvaldo.gomez@usach.cl
3220	20	3	Biología y Medicina	4	OP	2015	1	0	Adrián Esteban	Garrido	Goicovic	Juan	Iturbe	Araya	Prototipo de aplicación para el S.O. Android indicadora del riesgo de confidencialidad e integridad de los datos sensibles del usuario	2021-03-28 20:33:13.971267	2021-03-28 20:33:13.971267	52	jiturbe@usach.cl	adrian.esteban.garrido@usach.cl
3221	21	2	Interacción Humano-Computador	4	OP	2015	1	0	Bastian	Ganga	Peña	Rosa	Muñoz	Calanchie	Aplicación interactiva sobre dispositivo Touch-Screen, con el objetivo de mejorar la atención de clientes en Delightchile	2021-03-28 20:33:13.981583	2021-03-28 20:33:13.981583	12	rosa.munoz@usach.cl	bastian.ganga@usach.cl
3222	22	1	Interacción Humano-Computador	3	OP	2015	2	0	Mauricio Leonel	Carús	Flores	Rosa	Muñoz	Calanchie	Generador de objetos de aprendizaje basados en metodología CPIS	2021-03-28 20:33:13.993614	2021-03-28 20:33:13.993614	12	rosa.munoz@usach.cl	mauricio.leonel.carus@usach.cl
3223	23	3	Biología y Medicina	4	OP	2015	1	0	José Miguel	Cabrera	Bravo	Jacqueline	Köhler	Casasempere	Sistema colaborativo para el desarrollo de interfaces gráficas	2021-03-28 20:33:14.059534	2021-03-28 20:33:14.059534	55	jacqueline.kohler@usach.cl	jose.miguel.cabrera@usach.cl
3224	24	1	Biología y Medicina	3	OP	2015	2	0	Leonardo Alexis	Cabrera	Lobos	Rosa	Muñoz	Calanchie	Desarrollo de un Framework para la construcción de objetos de aprendizaje	2021-03-28 20:33:14.081795	2021-03-28 20:33:14.081795	12	rosa.munoz@usach.cl	leonardo.alexis.cabrera@usach.cl
3225	25	1	Redes y Seguridad	4	OP	2015	1	0	Jorge Francisco	Cabezas	Morales	Luis	Ríos	Sepúlveda	Rediseño del proceso de negocio asociado al servicio de arriendo de grúas horquilla para la empresa Grúas M&amp;L Ltda.	2021-03-28 20:33:14.103528	2021-03-28 20:33:14.103528	69	luis.rios@usach.cl	jorge.francisco.cabezas@usach.cl
3226	26	1	Redes y Seguridad	3	OP	2015	2	0	Joel Alain	Avalos	Pincheira	Carolina	Bonacic	Castro	Software de recomendación de rutinas de entrenamiento evolutivas para ciclistas	2021-03-28 20:33:14.116088	2021-03-28 20:33:14.116088	2	carolina.bonacic@usach.cl	joel.alain.avalos@usach.cl
3227	27	1	Interacción Humano-Computador	3	OP	2015	2	0	David Ignacio	Aguilar	Borne	Mónica	Villanueva	Ilufi	Enumeración de conjuntos independientes maximales en grafos polares	2021-03-28 20:33:14.138623	2021-03-28 20:33:14.138623	19	monica.villanueva@usach.cl	david.ignacio.aguilar@usach.cl
3228	28	1	Redes y Seguridad	3	OP	2016	2	0	Ricardo Fabián	Zúñiga	Antiñirre	Arturo	Álvarez	Cea	Protocolo de navegación entre UAVS, bajo arquitectura de comunicación ROS, para exploraciones de reconocimiento	2021-03-28 20:33:14.160923	2021-03-28 20:33:14.160923	25	arturo.alvarez@usach.cl	ricardo.fabian.zuniga@usach.cl
3229	29	2	Informática Educativa	4	OP	2016	1	0	Qixiong	Xiao	Flores	Rosa	Muñoz	Calanchie	Aplicación de apoyo para el estudio de Chino Mandarín	2021-03-28 20:33:14.184704	2021-03-28 20:33:14.184704	12	rosa.munoz@usach.cl	qixiong.xiao@usach.cl
3230	30	1	Redes y Seguridad	3	OP	2016	2	0	Vasco Esteban	Vergara	Arellano	Mónica	Villanueva	Ilufi	Sistema de apoyo para la acreditación de programas de pregrado del Departamento de Ingeniería Informática	2021-03-28 20:33:14.204237	2021-03-28 20:33:14.204237	19	monica.villanueva@usach.cl	vasco.esteban.vergara@usach.cl
3231	31	1	Redes y Seguridad	4	OP	2016	1	0	Francisco Javier	Vergara	Peña	Edmundo	Leiva-Lobos		EYESPLAY : Prototipo móvil para el control de gastos personales por medio del procesamiento de la fotografía de boletas	2021-03-28 20:33:14.226333	2021-03-28 20:33:14.226333	9	edmundo.leiva@usach.cl	francisco.javier.vergara@usach.cl
3232	32	1	Redes y Seguridad	3	OP	2016	2	0	Juan Pablo	Vera	Riquelme	Mauricio	Marín		Arquitectura de software para una plataforma Crowdfunding de proyectos sociales	2021-03-28 20:33:14.249571	2021-03-28 20:33:14.249571	10	mauricio.marin@usach.cl	juan.pablo.vera@usach.cl
3233	33	1	Informática Educativa	3	OP	2016	2	0	Daniel Fernando	Vargas	Mattheus	Bruno	Jerardino	Wiesenborn	Una aplicación web que apoya la gestión de la metodología de sistemas blandos a partir de una aplicación heredada	2021-03-28 20:33:14.260073	2021-03-28 20:33:14.260073	54	bruno.jerardino@usach.cl	daniel.fernando.vargas@usach.cl
3234	34	3	Informática Educativa	3	OP	2016	2	0	Felipe Andrés	Valenzuela	Hernández	Rosa	Muñoz	Calanchie	Objeto de aprendizaje para apoyar la enseñanza de protocolos de ventana deslizante	2021-03-28 20:33:14.282917	2021-03-28 20:33:14.282917	12	rosa.munoz@usach.cl	felipe.andres.valenzuela@usach.cl
3235	35	1	Sistemas Complejos	3	OP	2016	2	0	Jorge Hernán	Valenzuela	Castro	Roberto	González-Ibáñez		Ambientes no productivos para pruebas integradas usando virtualización de servicios	2021-03-28 20:33:14.30483	2021-03-28 20:33:14.30483	5		jorge.hernan.valenzuela@usach.cl
3236	36	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2016	2	0	Paola Andrea	Ulloa	Besserer	Edmundo	Leiva-Lobos		Recurso de aprendizaje de usabilidad Web con características de ludificación y multimedia	2021-03-28 20:33:14.327774	2021-03-28 20:33:14.327774	9	edmundo.leiva@usach.cl	paola.andrea.ulloa@usach.cl
3237	37	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2016	2	0	Alberto Andrés	Toro	Figueroa	Mónica	Villanueva	Ilufi	Algoritmo de enumeración de conjuntos independientes maximales en grafos de clase book	2021-03-28 20:33:14.350162	2021-03-28 20:33:14.350162	19	monica.villanueva@usach.cl	alberto.andres.toro@usach.cl
3238	38	3	Aplicaciones y Sistemas Escalables para la Web	4	OP	2016	1	0	Augusto Alejandro	Toledo	Pollmann	Andrés	Rice	Mora	Sistema para el control del manejo de inventario de productos	2021-03-28 20:33:14.370492	2021-03-28 20:33:14.370492	66	andres.rice@usach.cl	augusto.alejandro.toledo@usach.cl
3239	39	1	Informática Educativa	4	OP	2016	1	0	Jonathan Felipe	Salinas	Aburto	Carolina	Bonacic	Castro	Sistema de emisión y recepción de documentos tributarios electrónicos en la empresa Paytech Solutions	2021-03-28 20:33:14.388202	2021-03-28 20:33:14.388202	2	carolina.bonacic@usach.cl	jonathan.felipe.salinas@usach.cl
3240	40	1	Biología y Medicina	4	OP	2016	1	0	Gabriel Enrique	Salas	Puga	Luis	Ríos	Sepúlveda	Sistema de apoyo al control de costos para la empresa Inmobiliaria Aconcagua	2021-03-28 20:33:14.407216	2021-03-28 20:33:14.407216	69	luis.rios@usach.cl	gabriel.enrique.salas@usach.cl
3241	41	1	Informática Educativa	4	OP	2016	1	0	Nicolás Ignacio	Rozas	Sepúlveda	Edgardo	Sepúlveda	Sariego	Sistema de apoyo al registro y control de actividades de identificación y elaboración de planos de negocio, para proyectos ERP	2021-03-28 20:33:14.428064	2021-03-28 20:33:14.428064	81	edgardo.sepulveda.s@usach.cl	nicolas.ignacio.rozas@usach.cl
3242	42	1	Interacción Humano-Computador	3	OP	2016	2	0	Claudio Nicolás	Rojas	Fuentealba	Juan	Iturbe	Araya	Propuesta de metodología ágil de desarrollo de software considerando funcionalidad, usabilidad y seguridad	2021-03-28 20:33:14.449594	2021-03-28 20:33:14.449594	52	jiturbe@usach.cl	claudio.nicolas.rojas@usach.cl
3243	43	1	Biología y Medicina	4	OP	2016	1	0	Rodrigo Andrés	Rivas	Reyes	Javier	Jara	Valencia	Sistema Web de control de documentos y evaluación para la escuela Alemana D-774	2021-03-28 20:33:14.473023	2021-03-28 20:33:14.473023	53	j.jara.v@gmail.com	rodrigo.andres.rivas@usach.cl
3244	44	1	Interacción Humano-Computador	3	OP	2016	2	0	Patricia Marcela	Riquelme	Jeldres	Mónica	Villanueva	Ilufi	Sistema informativo para los estudiantes de la Universidad de Santiago de Chile	2021-03-28 20:33:14.493923	2021-03-28 20:33:14.493923	19	monica.villanueva@usach.cl	patricia.marcela.riquelme@usach.cl
3245	45	2	Interacción Humano-Computador	4	OP	2016	1	0	Rodrigo Alejandro	Ramírez	Garzo	Rosa	Muñoz	Calanchie	Objetos de aprendizaje para el estudio de protocolos de aplicación en internet	2021-03-28 20:33:14.516622	2021-03-28 20:33:14.516622	12	rosa.munoz@usach.cl	rodrigo.alejandro.ramirez@usach.cl
3246	46	1	Aplicaciones y Sistemas Escalables para la Web	4	OP	2016	1	0	Claudio Domingo	Plaza	Aguirre	Ricardo	Contreras	Sepúlveda	Sistema de apoyo a la venta de capacitaciones para empresa Capacitaciones DAPD EIRL	2021-03-28 20:33:14.53924	2021-03-28 20:33:14.53924	84	ricardo.contreras.s@usach.cl	claudio.domingo.plaza@usach.cl
3247	47	1	Informática Educativa	3	OP	2016	2	0	Felipe Javier	Piñeiro	Poblete	Juan	Iturbe	Araya	Plataforma web para la venta de paquetes turísticos y traslados personales	2021-03-28 20:33:14.559683	2021-03-28 20:33:14.559683	52	jiturbe@usach.cl	felipe.javier.pineiro@usach.cl
3248	48	1	Sistemas Complejos	3	OP	2016	2	0	Esteban Andrés	Ortiz	Cáceres	Rosa	Muñoz	Calanchie	Auditoría de seguridad a red informática de una tienda comercial	2021-03-28 20:33:14.584035	2021-03-28 20:33:14.584035	12	rosa.munoz@usach.cl	esteban.andres.ortiz@usach.cl
3249	49	2	Aplicaciones y Sistemas Escalables para la Web	4	OP	2016	1	0	Diego Enrique	Olavarría	Úbeda	Carolina	Bonacic	Castro	Desarrollo de prototipo de sistema informático para la organización y coordinación de organismos competentes y voluntariado frente a catástrofes	2021-03-28 20:33:14.603937	2021-03-28 20:33:14.603937	2	carolina.bonacic@usach.cl	diego.enrique.olavarria@usach.cl
3275	75	1	Biología y Medicina	4	OP	2016	1	0	Daniel Mariano	Gacitúa	Vásquez	Roberto	González-Ibáñez		Neurone : sistema de apoyo para la evaluación de competencias de investigación en línea para estudiantes de enseñanza básica	2021-03-28 20:33:15.257843	2021-03-28 20:33:15.257843	5		daniel.mariano.gacitua@usach.cl
3276	76	1	Redes y Seguridad	3	OP	2016	2	0	Diego Ignacio	Díaz	Márquez	Gonzalo	Acuña	Leiva	Mejoras en la detección de sismos para alerta temprana utilizando herramientas de inteligencia computacional	2021-03-28 20:33:15.27099	2021-03-28 20:33:15.27099	1	gonzalo.acuna@usach.cl	diego.ignacio.diaz@usach.cl
3277	77	1	Redes y Seguridad	3	OP	2016	2	0	José Ignacio	Cortés	Tapia	Rosa	Muñoz	Calanchie	Protocolo de autenticación para la aplicación de una red inalámbrica de malla	2021-03-28 20:33:15.292742	2021-03-28 20:33:15.292742	12	rosa.munoz@usach.cl	jose.ignacio.cortes@usach.cl
3278	78	1	Sistemas Complejos	3	OP	2016	2	0	Camilo Andrés	Correa	Ruz	Mónica	Villanueva	Ilufi	Predicción del rendimiento  académico de los postulantes a la carrera de Ingeniería de Ejecución en Computación e Informática modalidad vespertina	2021-03-28 20:33:15.315879	2021-03-28 20:33:15.315879	19	monica.villanueva@usach.cl	camilo.andres.correa@usach.cl
3279	79	1	Informática Educativa	3	OP	2016	2	0	María José	Córdova	Celedón	Fernando	Rannou	Fuentes	Mejoramiento funcional de la Oficina de Administración de Proyectos de la División de Tecnologías de la Información de la Dirección de Presupuestos	2021-03-28 20:33:15.337272	2021-03-28 20:33:15.337272	15	fernando.rannou@usach.cl	maria.jose.cordova@usach.cl
3280	80	3	Informática Educativa	4	OP	2016	1	0	Valentino Andrés	Carmona	Victoriano	Luis	Ríos	Sepúlveda	Sistema de asignación de Beca Programa de Atención Económica de la Universidad de Chile	2021-03-28 20:33:15.347236	2021-03-28 20:33:15.347236	69	luis.rios@usach.cl	valentino.andres.carmona@usach.cl
3281	81	1	Redes y Seguridad	4	OP	2016	1	0	Claudia Alejandra	Bustamante	Arce	Luis	Ríos	Sepúlveda	Desarrollo de objetos de aprendizaje sobre la arquitectura del computador de Von Neumann de apoyo a la asignatura Estructura de Computadores	2021-03-28 20:33:15.35941	2021-03-28 20:33:15.35941	69	luis.rios@usach.cl	claudia.alejandra.bustamante@usach.cl
3282	82	1	Interacción Humano-Computador	4	OP	2016	1	0	Daniel Ignacio	Brown	Madariaga	Arturo	Terra	Vásquez	Levantamiento de procesos de Registro Curricular de la Facultad de Ingeniería, evaluación de madurez y propuesta de recomendaciones	2021-03-28 20:33:15.380231	2021-03-28 20:33:15.380231	82	arturo.terra.v@usach.cl	daniel.ignacio.brown@usach.cl
3283	83	1	Redes y Seguridad	4	OP	2016	1	0	Sebastián Ignacio	Acevedo	Carrasco	Edmundo	Leiva-Lobos		Rapsodia : desarrollo de un recurso de aprendizaje sobre las pruebas de software desde el enfoque orientado por pruebas	2021-03-28 20:33:15.392357	2021-03-28 20:33:15.392357	9	edmundo.leiva@usach.cl	sebastian.ignacio.acevedo@usach.cl
3284	84	1	Interacción Humano-Computador	3	OP	2016	2	0	Esteban Andrés	Abarca	Rubio	Nicolás	Hidalgo	Castillo	Sistema escalable para la detección de necesidades en escenarios de catástrofe natural	2021-03-28 20:33:15.414712	2021-03-28 20:33:15.414712	83	nicolas.hidalgo.c@usach.cl	esteban.andres.abarca@usach.cl
3285	85	1	Sistemas Complejos	4	OP	2017	1	0	Christian Igancio	Zaballa	Rojas	Roberto	González-Ibáñez		Extensiones de multimodal observer ( MO ) para la captura y reproducción de modalidades de datos audiovisuales y fisiológicos	2021-03-28 20:33:15.436994	2021-03-28 20:33:15.436994	5		christian.igancio.zaballa@usach.cl
3286	86	1	Interacción Humano-Computador	3	OP	2017	2	0	Rodrigo Andrés	Yáñez	Gutiérrez	Rosa	Muñoz	Calanchie	Metodología para el desarrollo de objetos de aprendizaje y aplicación sobre un objeto de aprendizaje sobre evaluación de proyectos	2021-03-28 20:33:15.446837	2021-03-28 20:33:15.446837	12	rosa.munoz@usach.cl	rodrigo.andres.yanez@usach.cl
3287	87	2	Redes y Seguridad	4	OP	2017	1	0	Felipe Christopher	Vilches	Céspedes	Roberto	González-Ibáñez		Módulo para la búsqueda,descarga,instalación y actualización de extensiones de MO	2021-03-28 20:33:15.45916	2021-03-28 20:33:15.45916	5		felipe.christopher.vilches@usach.cl
3288	88	2	Biología y Medicina	4	OP	2017	1	0	Jaime Andrés	Vidal	Oliva	Irene	Zuccar	Parrini	Concentrador de pagos	2021-03-28 20:33:15.48076	2021-03-28 20:33:15.48076	85	irene.zuccar.p@usach.cl	jaime.andres.vidal@usach.cl
3289	89	1	Sistemas Complejos	4	OP	2017	1	0	Alan Brandon	Vergara	Bravo	Mario	Inostroza-Ponta		Aplicación móvil para apoyar la comunicación entre apoderados y transportistas escolares	2021-03-28 20:33:15.503428	2021-03-28 20:33:15.503428	6	mario.inostroza@usach.cl	alan.brandon.vergara@usach.cl
3290	90	3	Redes y Seguridad	4	OP	2017	1	0	Jennifer Carolina	Venegas	Sandoval	Alcides	Quispe	Sanca	Sistema para automatizar el proceso de las evaluaciones sumativas del curso de Fundamentos de Computación y Programación del módulo básico de Ingeniería	2021-03-28 20:33:15.514879	2021-03-28 20:33:15.514879	14	alcides.quispe@usach.cl	jennifer.carolina.venegas@usach.cl
3291	91	3	Interacción Humano-Computador	4	OP	2017	1	0	Nicolás Andrés	Vásquez	Tobar	Víctor	Parada	Daza	Predicción de elecciones generales mediante redes neuronales	2021-03-28 20:33:15.536832	2021-03-28 20:33:15.536832	13	victor.parada@usach.cl	nicolas.andres.vasquez@usach.cl
3292	92	3	Informática Educativa	4	OP	2017	1	0	Fabián Isaías	Urbina	Ampuero	Roberto	González-Ibáñez		Módulo de control de niveles de inmersión y soporte de interfaces fisiológicas para motions	2021-03-28 20:33:15.560288	2021-03-28 20:33:15.560288	5		fabian.isaias.urbina@usach.cl
3293	93	1	Biología y Medicina	3	OP	2017	2	0	Camilo Andrés	Torres	Sepúlveda	Bruno	Jerardino	Wiesenborn	AGORA : Aplicación web que soporta la gestión de actas de discusión para organizaciones sociales geográficamente distribuidas	2021-03-28 20:33:15.583129	2021-03-28 20:33:15.583129	54	bruno.jerardino@usach.cl	camilo.andres.torres@usach.cl
3294	94	1	Biología y Medicina	3	OP	2017	2	0	Carlos	Torres	Pérez	J.	L.	Jara	Estudio de la viabilidad de automatizar la clasificación de diagnósticos de pacientes hospitalizados en la unidad de cuidados intensivos adultos en una clínica privada de Santiago	2021-03-28 20:33:15.603126	2021-03-28 20:33:15.603126	7	jljara@usach.cl	carlos.torres@usach.cl
3295	95	2	Interacción Humano-Computador	4	OP	2017	1	0	Luis Alberto	Tapia	Araya	Gonzalo	Acuña	Leiva	Análisis comparativo de máquinas de aprendizaje extremo y perceptrón multicapa para problemas de clasificación binaria y multiclase	2021-03-28 20:33:15.625824	2021-03-28 20:33:15.625824	1	gonzalo.acuna@usach.cl	luis.alberto.tapia@usach.cl
3296	96	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2017	2	0	Elias Eliace	Sobarzo	del Pino	Carolina	Bonacic	Castro	Paralelización de índices de poder enfocados en sistemas de votación	2021-03-28 20:33:15.646928	2021-03-28 20:33:15.646928	2	carolina.bonacic@usach.cl	elias.eliace.sobarzo@usach.cl
3297	97	1	Sistemas Complejos	3	OP	2017	2	0	Andrés Gonzalo	Silva	Díaz	Mónica	Villanueva	Ilufi	Sistema para el mejoramiento de los procesos de gestión de la información en el Instituto de Investigaciones Agropecuarias	2021-03-28 20:33:15.657462	2021-03-28 20:33:15.657462	19	monica.villanueva@usach.cl	andres.gonzalo.silva@usach.cl
3298	98	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2017	2	0	Pablo Javier	Salinas	Cabañas	Víctor	Parada	Daza	Herramienta de software para predecir el agrupamiento de buses urbanos	2021-03-28 20:33:15.680511	2021-03-28 20:33:15.680511	13	victor.parada@usach.cl	pablo.javier.salinas@usach.cl
3299	99	1	Aplicaciones y Sistemas Escalables para la Web	4	OP	2017	1	0	Richard Robinson	Saldías	Sanhueza	Edmundo	Leiva-Lobos		TeamMaker : conformación de equipos de trabajo para un curso universitario basado en compatibilidad psico-social de sus estudiantes	2021-03-28 20:33:15.703798	2021-03-28 20:33:15.703798	9	edmundo.leiva@usach.cl	richard.robinson.saldias@usach.cl
3300	100	2	Informática Educativa	4	OP	2017	1	0	Milton Jonnathan	Rosas	Paredes	Luis	Ríos	Sepúlveda	Prototipo de sistema para el control de agua de lastre en embarcaciones de tráfico nacional e internacional	2021-03-28 20:33:15.727225	2021-03-28 20:33:15.727225	69	luis.rios@usach.cl	milton.jonnathan.rosas@usach.cl
3301	101	2	Biología y Medicina	4	OP	2017	1	0	Angus Tafari Amado	Pollmann	Stocker	Roberto	González-Ibáñez		Motions : sistema de apoyo a la investigación de la interacción humano-información a través de múltiples interfaces de usuario	2021-03-28 20:33:15.748389	2021-03-28 20:33:15.748389	5		angus.tafariamado.pollmann@usach.cl
3302	102	2	Redes y Seguridad	4	OP	2017	1	0	Oscar José Antonio	Pinto	Salazar	Víctor	Parada	Daza	Servicio de impresión para el sitio web de una administradora de fondo de pensiones	2021-03-28 20:33:15.77232	2021-03-28 20:33:15.77232	13	victor.parada@usach.cl	oscar.joseantonio.pinto@usach.cl
3303	103	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2017	2	0	Yerko Israel	Pino	Garay	J.	L.	Jara	Modelo de predicción de éxito académico de alumnos fing con causales de eliminación	2021-03-28 20:33:15.791784	2021-03-28 20:33:15.791784	7	jljara@usach.cl	yerko.israel.pino@usach.cl
3304	104	1	Redes y Seguridad	3	OP	2017	2	0	Leonardo Osvaldo	Pavez	Pérez	Mónica	Villanueva	Ilufi	Sistema de administración y soporte de plataformas TI	2021-03-28 20:33:15.814025	2021-03-28 20:33:15.814025	19	monica.villanueva@usach.cl	leonardo.osvaldo.pavez@usach.cl
3305	105	1	Interacción Humano-Computador	3	OP	2017	2	0	Jaime Hernan	Pavez	Pavez	Luis	Ríos	Sepúlveda	Integración del sistema Core Banking para apertura de cuenta corriente por medio de la gestión de procesos de negocio	2021-03-28 20:33:15.835091	2021-03-28 20:33:15.835091	69	luis.rios@usach.cl	jaime.hernan.pavez@usach.cl
3306	106	3	Interacción Humano-Computador	4	OP	2017	1	0	Jonathan Esteban	Padilla	López	Luis	Ríos	Sepúlveda	Desarrollo de una solución web para la gestión de la información contable	2021-03-28 20:33:15.857973	2021-03-28 20:33:15.857973	69	luis.rios@usach.cl	jonathan.esteban.padilla@usach.cl
3307	107	2	Informática Educativa	4	OP	2017	1	0	Hernán Maximiliano	Olmedo	Jara	Mónica	Villanueva	Ilufi	Objeto de aprendizaje para diseño de algoritmos con métodos de descomposición	2021-03-28 20:33:15.871101	2021-03-28 20:33:15.871101	19	monica.villanueva@usach.cl	hernan.maximiliano.olmedo@usach.cl
3308	108	2	Aplicaciones y Sistemas Escalables para la Web	4	OP	2017	1	0	Pablo Andrés	Murga	Salvatierra	Rosa	Muñoz	Calanchie	Desarrollo de objetos de aprendizaje para apoyar el estudio de la red de área local Ethernet	2021-03-28 20:33:15.89216	2021-03-28 20:33:15.89216	12	rosa.munoz@usach.cl	pablo.andres.murga@usach.cl
3309	109	1	Redes y Seguridad	4	OP	2017	1	0	Moisés Rodrigo	Moraga	Rojas	Roberto	González-Ibáñez		Sistema de búsqueda, despliegue visual y generación de reportes de gestión a partir de lista regulatoria PEP	2021-03-28 20:33:15.914747	2021-03-28 20:33:15.914747	5		moises.rodrigo.moraga@usach.cl
3310	110	1	Redes y Seguridad	4	OP	2017	1	0	Diego Iván	Miranda	Gipoulou	Gonzalo	Acuña	Leiva	Análisis comparativo entre Perceptrón Multicapa y Extreme Learning Machine para problemas de regresión	2021-03-28 20:33:15.938241	2021-03-28 20:33:15.938241	1	gonzalo.acuna@usach.cl	diego.ivan.miranda@usach.cl
3311	111	1	Biología y Medicina	3	OP	2017	2	0	Katherine Marcela	Liberona	Irarrázabal	Edmundo	Leiva-Lobos		Desarrollo de un visualizador, manejador y analizador de múltiples videos que permita el tratamiento simultáneo de múltiples canales visuales	2021-03-28 20:33:15.957658	2021-03-28 20:33:15.957658	9	edmundo.leiva@usach.cl	katherine.marcela.liberona@usach.cl
3312	112	1	Biología y Medicina	4	OP	2017	1	0	Juan Manuel	Herrera	Vega	Víctor	Parada	Daza	Nuevas contribuciones para la generación automática de algoritmos genéticos en el problema de la mochila multidimensional	2021-03-28 20:33:16.024944	2021-03-28 20:33:16.024944	13	victor.parada@usach.cl	juan.manuel.herrera@usach.cl
3313	113	1	Interacción Humano-Computador	3	OP	2017	2	0	Claudio Alejandro	Hernández	Pezo	Nicolás	Hidalgo	Castillo	Mecanismo de análisis de precisión de predictores para sistemas de procesamiento de Streams con aprovisionamiento dinámico	2021-03-28 20:33:16.03476	2021-03-28 20:33:16.03476	83	nicolas.hidalgo.c@usach.cl	claudio.alejandro.hernandez@usach.cl
3314	114	3	Aplicaciones y Sistemas Escalables para la Web	4	OP	2017	1	0	Náyada	Hernández	Oyanedel	Mónica	Villanueva	Ilufi	Sistema de coordinación de reserva horaria para eventos y actividades del colegio Alemán de Santiago	2021-03-28 20:33:16.047756	2021-03-28 20:33:16.047756	19	monica.villanueva@usach.cl	nayada.hernandez@usach.cl
3315	115	1	Biología y Medicina	3	OP	2017	2	0	Nicole Macarena	Henríquez	Sepúlveda	Arturo	Terra	Vásquez	Proceso de registro de contratación de docentes por horas de la Dirección de Pregrado de la Universidad de Santiago de Chile	2021-03-28 20:33:16.069715	2021-03-28 20:33:16.069715	82	arturo.terra.v@usach.cl	nicole.macarena.henriquez@usach.cl
3316	116	2	Biología y Medicina	4	OP	2017	1	0	Alfonso Javier	Henríquez	Handy	Carolina	Bonacic	Castro	Sistema de planificación de viajes en el metro de Santiago a través de medición de datos cualitativos y cuantitativos de la experiencia del usuario	2021-03-28 20:33:16.091823	2021-03-28 20:33:16.091823	2	carolina.bonacic@usach.cl	alfonso.javier.henriquez@usach.cl
3317	117	1	Sistemas Complejos	3	OP	2017	2	0	Claudia Irene	Guzmán	Silva	Alcides	Quispe	Sanca	Sistema para monitorear la práctica de programación en Python que realizan los estudiantes fuera del horario de clases	2021-03-28 20:33:16.158381	2021-03-28 20:33:16.158381	14	alcides.quispe@usach.cl	claudia.irene.guzman@usach.cl
3318	118	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2017	2	0	Bryan Alfonso	Guzmán	Álvarez	Alcides	Quispe	Sanca	TEAMie : herramienta para conformación de equipos de trabajo en el curso de Fundamentos de Computación y Programación del módulo básico de Ingeniería	2021-03-28 20:33:16.20327	2021-03-28 20:33:16.20327	14	alcides.quispe@usach.cl	bryan.alfonso.guzman@usach.cl
3319	119	3	Aplicaciones y Sistemas Escalables para la Web	4	OP	2017	1	0	Cristián Alejandro	Gómez	Ibáñez	Juan	Iturbe	Araya	Sistema web de apoyo a la administración de contratos y flujo de caja del Departamento de Ingeniería en Informática de la Universidad de Santiago de Chile	2021-03-28 20:33:16.224142	2021-03-28 20:33:16.224142	52	jiturbe@usach.cl	cristian.alejandro.gomez@usach.cl
3320	120	3	Informática Educativa	4	OP	2017	1	0	Edgar Oladio	Gatica	Martínez	Rosa	Muñoz	Calanchie	Desarrollo de objetos de aprendizaje para el apoyo en el estudio de las arquitecturas de protocolos	2021-03-28 20:33:16.247784	2021-03-28 20:33:16.247784	12	rosa.munoz@usach.cl	edgar.oladio.gatica@usach.cl
3321	121	2	Interacción Humano-Computador	4	OP	2017	1	0	Alberto Daniel	Garrido	Andrade	Edmundo	Leiva-Lobos		Nooby : catálogo interactivo de habilidades blandas para juegos de mesa	2021-03-28 20:33:16.269187	2021-03-28 20:33:16.269187	9	edmundo.leiva@usach.cl	alberto.daniel.garrido@usach.cl
3322	122	1	Biología y Medicina	3	OP	2017	2	0	Matías Nicolás	Flores	Salas	Fernando	Rannou	Fuentes	Herramienta computacional para simulaciones hidrodinámicas de discos protoplanetarios bidimensionales en grilla Euleriana en GPU	2021-03-28 20:33:16.291154	2021-03-28 20:33:16.291154	15	fernando.rannou@usach.cl	matias.nicolas.flores@usach.cl
3323	123	2	Informática Educativa	4	OP	2017	1	0	María Constanza	Flores	González	Arturo	Terra	Vásquez	Levantamiento, documentación y planteamiento de oportunidades de mejora en AFP Capital	2021-03-28 20:33:16.312532	2021-03-28 20:33:16.312532	82	arturo.terra.v@usach.cl	maria.constanza.flores@usach.cl
3324	124	3	Informática Educativa	4	OP	2017	1	0	Cristóbal Eduardo del	Fierro	Berrios	Rosa	Muñoz	Calanchie	Software de facturación electrónica	2021-03-28 20:33:16.336205	2021-03-28 20:33:16.336205	12	rosa.munoz@usach.cl	cristobal.eduardodel.fierro@usach.cl
3325	125	1	Interacción Humano-Computador	4	OP	2017	1	0	Álvaro Pedro	Felmer	Pizarro	Juan	Iturbe	Araya	Implementación de un ERP de apoyo a la administración de la Avícola Avifel	2021-03-28 20:33:16.356956	2021-03-28 20:33:16.356956	52	jiturbe@usach.cl	alvaro.pedro.felmer@usach.cl
3326	126	1	Interacción Humano-Computador	3	OP	2017	2	0	Kevin Daniel	Farías	Sandoval	Carolina	Bonacic	Castro	Sistema de control de documentos tributarios para una empresa financiera en Chile	2021-03-28 20:33:16.368991	2021-03-28 20:33:16.368991	2	carolina.bonacic@usach.cl	kevin.daniel.farias@usach.cl
3327	127	3	Aplicaciones y Sistemas Escalables para la Web	4	OP	2017	1	0	Fernanda Geraldine	Estay	Cabello	Roberto	González-Ibáñez		Plataforma de apoyo a la experimentación en interacción humano-información a través de gestos corporales	2021-03-28 20:33:16.390226	2021-03-28 20:33:16.390226	5		fernanda.geraldine.estay@usach.cl
3328	128	1	Biología y Medicina	3	OP	2017	2	0	Marcelo Alejandro	Escobar	Muñoz	Víctor	Parada	Daza	Análisis de llamadas en una empresa de venta de software para la búsqueda de patrones	2021-03-28 20:33:16.412421	2021-03-28 20:33:16.412421	13	victor.parada@usach.cl	marcelo.alejandro.escobar@usach.cl
3329	129	3	Aplicaciones y Sistemas Escalables para la Web	4	OP	2017	1	0	Gustavo Andrés	Curifuta	Poblete	Roberto	González-Ibáñez		Extensiones de MO para el análisis de datos de rastreo ocular y expresiones faciales	2021-03-28 20:33:16.434739	2021-03-28 20:33:16.434739	5		gustavo.andres.curifuta@usach.cl
3330	130	2	Informática Educativa	4	OP	2017	1	0	Rodrigo Andrés	Cerda	Ponce	Roberto	González-Ibáñez		Extensión de Openglove a nivel de hardware y software para la captura de movimientos de la mano	2021-03-28 20:33:16.457635	2021-03-28 20:33:16.457635	5		rodrigo.andres.cerda@usach.cl
3331	131	3	Aplicaciones y Sistemas Escalables para la Web	4	OP	2017	1	0	Oscar Ignacio	Carrasco	Madriaga	Roberto	González-Ibáñez		Sistema para el estudio de interacciones con material impreso y digital equivalentes a través de realidad aumentada	2021-03-28 20:33:16.478951	2021-03-28 20:33:16.478951	5		oscar.ignacio.carrasco@usach.cl
3332	132	3	Informática Educativa	4	OP	2017	1	0	Matías Alejandro	Calderón	Quezada	Carolina	Bonacic	Castro	Diseño y desarrollo de un prototipo de sistema para capturar y modelar los datos de un blanco en la disciplina de tiro con arco	2021-03-28 20:33:16.4916	2021-03-28 20:33:16.4916	2	carolina.bonacic@usach.cl	matias.alejandro.calderon@usach.cl
3333	133	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2017	2	0	Jonás Mauricio	Astudillo	Concha	Edmundo	Leiva-Lobos		EyesFood : aplicación móvil de prevención en la salud asociada a los alimentos envasados en el caso de la Diabetes Mellitus	2021-03-28 20:33:16.512667	2021-03-28 20:33:16.512667	9	edmundo.leiva@usach.cl	jonas.mauricio.astudillo@usach.cl
3334	134	3	Interacción Humano-Computador	4	OP	2017	1	0	Andrés Mateo	Amengual	Burgos	Javier	Jara	Valencia	Sistema de notificaciones tempranas para fondos concursables	2021-03-28 20:33:16.536802	2021-03-28 20:33:16.536802	53	j.jara.v@gmail.com	andres.mateo.amengual@usach.cl
3335	135	1	Sistemas Complejos	4	OP	2017	1	0	Matías	Aguiló	Correa	Luis	Ríos	Sepúlveda	Servicio web interfaz de productos para la nueva plataforma de clientes asegurados de consorcio	2021-03-28 20:33:16.558651	2021-03-28 20:33:16.558651	69	luis.rios@usach.cl	matias.aguilo@usach.cl
3336	136	3	Redes y Seguridad	4	OP	2018	1	0	René Ignacio	Zárate	Meneses	Alcides	Quispe	Sanca	TUTORPY-BOT: Un sistema para apoyar el aprendizaje de programación para cursos universitarios introductorios a la programación	2021-03-28 20:33:16.581171	2021-03-28 20:33:16.581171	14	alcides.quispe@usach.cl	rene.ignacio.zarate@usach.cl
3337	137	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2018	2	0	Ana Karina	Villagrán	Ibarra	Mario	Inostroza-Ponta		Método de clustering multi-objetivo para el análisis de datos de expresión génica	2021-03-28 20:33:16.603351	2021-03-28 20:33:16.603351	6	mario.inostroza@usach.cl	ana.karina.villagran@usach.cl
3338	138	3	Aplicaciones y Sistemas Escalables para la Web	4	OP	2018	1	0	María José	Vera	Pincheira	Alcides	Quispe	Sanca	Plataforma para monitorear y evaluar el desarrollo de proyectos de software construidos siguiendo el enfoque de integración continua	2021-03-28 20:33:16.623959	2021-03-28 20:33:16.623959	14	alcides.quispe@usach.cl	maria.jose.vera@usach.cl
3339	139	3	Aplicaciones y Sistemas Escalables para la Web	4	OP	2018	1	0	Marcelo Hernán	Vega	Janhsen	J.	L.	Jara	Servicio de control de acceso con toma de decisiones automatizadas asistidas por dispositivos TI para vehículos y personas	2021-03-28 20:33:16.646401	2021-03-28 20:33:16.646401	7	jljara@usach.cl	marcelo.hernan.vega@usach.cl
3340	140	1	Biología y Medicina	4	OP	2018	1	0	Matías José	Vargas	Mora	Carolina	Bonacic	Castro	Modelado de sistemas : Chile un Smart-Country resiliente	2021-03-28 20:33:16.670195	2021-03-28 20:33:16.670195	2	carolina.bonacic@usach.cl	matias.jose.vargas@usach.cl
3341	141	1	Sistemas Complejos	3	OP	2018	2	0	Patricio Alberto	Vargas	Pino	Alcides	Quispe	Sanca	PYFAAV : Una aplicación web para evaluar código fuente Python a partir del análisis estático del código	2021-03-28 20:33:16.691257	2021-03-28 20:33:16.691257	14	alcides.quispe@usach.cl	patricio.alberto.vargas@usach.cl
3342	142	2	Interacción Humano-Computador	4	OP	2018	1	0	Sebastián Ignacio	Vallejos	Arroyo	J.	L.	Jara	SCAP : Sistema de comunicación entre apoderados y profesores	2021-03-28 20:33:16.713176	2021-03-28 20:33:16.713176	7	jljara@usach.cl	sebastian.ignacio.vallejos@usach.cl
3343	143	1	Interacción Humano-Computador	4	OP	2018	1	0	Pablo Ricardo	Ulloa	Castro	Alcides	Quispe	Sanca	MDDV : aplicación web para extraer y visualizar el modelo de datos asociado a un repositorio de bases de datos	2021-03-28 20:33:16.735227	2021-03-28 20:33:16.735227	14	alcides.quispe@usach.cl	pablo.ricardo.ulloa@usach.cl
3344	144	1	Informática Educativa	3	OP	2018	2	0	Javiera Andrea	Torres	Muñoz	Jacqueline	Köhler	Casasempere	Creación de objetos de aprendizaje que consideren estrategias didácticas y estilos de aprendizaje	2021-03-28 20:33:16.757092	2021-03-28 20:33:16.757092	55	jacqueline.kohler@usach.cl	javiera.andrea.torres@usach.cl
3345	145	1	Informática Educativa	4	OP	2018	1	0	Fernanda Paz	Retamal	Fernández	Alcides	Quispe	Sanca	Aplicación de notificaciones push con segmentación dinámica de usuarios para mejorar la comunicación vertical en empresas	2021-03-28 20:33:16.768084	2021-03-28 20:33:16.768084	14	alcides.quispe@usach.cl	fernanda.paz.retamal@usach.cl
3346	146	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2018	2	0	Daniel Alejandro	Ravelo	Riveros	Luis	Ríos	Sepúlveda	Sistema basado en tecnología RFID para control de inventarios de herramientas en obras de construcción civil	2021-03-28 20:33:16.778448	2021-03-28 20:33:16.778448	69	luis.rios@usach.cl	daniel.alejandro.ravelo@usach.cl
3347	147	1	Sistemas Complejos	3	OP	2018	2	0	Diego Ignacio	Polanco	Berrios	Roberto	González-Ibáñez		Desarrollo de un módulo para asistentes destinados a la gestión y despliegue de protocolos de investigación en MO	2021-03-28 20:33:16.789374	2021-03-28 20:33:16.789374	5		diego.ignacio.polanco@usach.cl
3348	148	3	Informática Educativa	4	OP	2018	1	0	Benjamin Ignacio	Pastene	Pastene	J.	L.	Jara	Utilización de dispositivos móviles como una herramienta tecnológica que genera aportes al quiebre activo en una instancia pedagógica	2021-03-28 20:33:16.803126	2021-03-28 20:33:16.803126	7	jljara@usach.cl	benjamin.ignacio.pastene@usach.cl
3349	149	1	Biología y Medicina	3	OP	2018	2	0	Mauricio	Oyarzún	Sepúlveda	Víctor	Parada	Daza	Clasificación de imágenes con red de redes neuronales embebidas en sistemas de recursos limitados	2021-03-28 20:33:16.822905	2021-03-28 20:33:16.822905	13	victor.parada@usach.cl	mauricio.oyarzun@usach.cl
3350	150	1	Sistemas Complejos	3	OP	2018	2	0	Catalina	Ortiz	Ugalde	Arturo	Terra	Vásquez	Proponer y diseñar mejoras a partir de la evaluación de heurísticas de usabilidad de los canales digitales de una empresa de telecomunicaciones	2021-03-28 20:33:16.836833	2021-03-28 20:33:16.836833	82	arturo.terra.v@usach.cl	catalina.ortiz@usach.cl
3351	151	1	Aplicaciones y Sistemas Escalables para la Web	3	OP	2018	2	0	Ian Isaí	Orellana	Cayupan	Roberto	González-Ibáñez		Estudio del comportamiento de búsqueda en línea en estudiantes de enseñanza básica para la identificación de información relevante	2021-03-28 20:33:16.857205	2021-03-28 20:33:16.857205	5		ian.isai.orellana@usach.cl
3352	152	1	Sistemas Complejos	4	OP	2018	1	0	Raúl Andrés	Olivares	Pasten	Roberto	González-Ibáñez		Desarrollo de componentes de NEURONE para funcionalidades en la Open Web	2021-03-28 20:33:16.86767	2021-03-28 20:33:16.86767	5		raul.andres.olivares@usach.cl
3353	153	2	Biología y Medicina	4	OP	2018	1	0	Pamela Alejandra	Olea	Parra	Andrés	Rice	Mora	Optimización del proceso de cotejo de compras de la empresa Laboratorios Maver S.A.	2021-03-28 20:33:16.890188	2021-03-28 20:33:16.890188	66	andres.rice@usach.cl	pamela.alejandra.olea@usach.cl
3354	154	1	Aplicaciones y Sistemas Escalables para la Web	4	OP	2018	1	0	Nicolás Salvador	Muñoz	Zarricueta	Pablo	Román	Asenjo	Desarrollo e implementación de un framework orientado al objeto para síntesis de imágenes en interferometría	2021-03-28 20:33:16.90143	2021-03-28 20:33:16.90143	16	pablo.roman.a@usach.cl	nicolas.salvador.munoz@usach.cl
3355	155	1	Informática Educativa	3	OP	2018	2	0	Diego Ignacio	Méndez	Lazo	Mónica	Villanueva	Ilufi	Estudio de viajes dinámicos con algoritmos de rutas críticas para el transporte público de Santiago	2021-03-28 20:33:16.922826	2021-03-28 20:33:16.922826	19	monica.villanueva@usach.cl	diego.ignacio.mendez@usach.cl
3356	156	1	Redes y Seguridad	3	OP	2018	2	0	Sergio Andrés	Medina	Medel	Arturo	Álvarez	Cea	Sistema de evasión y replanificación de ruta para UAV mediante sensor ultrasónico	2021-03-28 20:33:16.934191	2021-03-28 20:33:16.934191	25	arturo.alvarez@usach.cl	sergio.andres.medina@usach.cl
3357	157	1	Informática Educativa	3	OP	2018	2	0	Israel Gedeón Elías	Martínez	Montenegro	Roberto	González-Ibáñez		Desarrollo de un SDK para dar soporte a OpenGlove en dispositivos móviles	2021-03-28 20:33:16.95553	2021-03-28 20:33:16.95553	5		israel.gedeonelias.martinez@usach.cl
3358	158	1	Biología y Medicina	3	OP	2018	2	0	Camila Margarita	Márquez	Carrasco	Roberto	González-Ibáñez		Stare.js: paquete de visualización de resultados de motores de búsqueda	2021-03-28 20:33:16.968217	2021-03-28 20:33:16.968217	5		camila.margarita.marquez@usach.cl
3359	159	2	Redes y Seguridad	4	OP	2018	1	0	Alfredo Marcelino	López	Allende	Luis	Ríos	Sepúlveda	Sistema de control del proceso de fundición de aceros desde su etapa de planificación hasta el proceso de desplome de piezas fabricadas para máquinas usadas en las faenas mineras	2021-03-28 20:33:16.978341	2021-03-28 20:33:16.978341	69	luis.rios@usach.cl	alfredo.marcelino.lopez@usach.cl
3360	160	1	Redes y Seguridad	3	OP	2018	2	0	Nelson Andrés	Jerez	Vidal	Víctor	Parada	Daza	Búsqueda de correlaciones entre instancias y soluciones del problema del vendedor viajero a través de programación genética	2021-03-28 20:33:17.001323	2021-03-28 20:33:17.001323	13	victor.parada@usach.cl	nelson.andres.jerez@usach.cl
3361	161	1	Informática Educativa	3	OP	2018	2	0	Fernando Joaquín	Handal	Ocampo	Alcides	Quispe	Sanca	Herramienta de gestión de proyectos de software para cursos introductorios de programación de la Universidad de Santiago	2021-03-28 20:33:17.011424	2021-03-28 20:33:17.011424	14	alcides.quispe@usach.cl	fernando.joaquin.handal@usach.cl
3362	162	1	Interacción Humano-Computador	3	OP	2018	2	0	Luis Alfredo	Guerra	Aedo	Mónica	Villanueva	Ilufi	Herramienta de estudio de diferentes tratamientos de rehabilitación para mascotas a tráves de minería de datos	2021-03-28 20:33:17.023636	2021-03-28 20:33:17.023636	19	monica.villanueva@usach.cl	luis.alfredo.guerra@usach.cl
3363	163	1	Sistemas Complejos	4	OP	2018	1	0	Pablo Iván	González	Alarcón	Edgardo	Sepúlveda	Sariego	Proyecto de innovación “Classtrack” : una experiencia práctica	2021-03-28 20:33:17.034999	2021-03-28 20:33:17.034999	81	edgardo.sepulveda.s@usach.cl	pablo.ivan.gonzalez@usach.cl
3364	164	1	Sistemas Complejos	4	OP	2018	1	0	Patricio Oriel	González	Álvarez	Edmundo	Leiva-Lobos		Desarrollar un sistema workflow para el seguimiento y administración de proyectos para una PMO basados en indicadores CMMI	2021-03-28 20:33:17.04609	2021-03-28 20:33:17.04609	9	edmundo.leiva@usach.cl	patricio.oriel.gonzalez@usach.cl
3365	165	3	Redes y Seguridad	4	OP	2018	1	0	Diego Ignacio	González	Arce	Arturo	Álvarez	Cea	MAVTREL : Software traductor de dos protocolos de comunicación para un sistema robótico tipo UAV y drones	2021-03-28 20:33:17.068374	2021-03-28 20:33:17.068374	25	arturo.alvarez@usach.cl	diego.ignacio.gonzalez@usach.cl
3366	166	1	Redes y Seguridad	3	OP	2018	2	0	Jorge Ricardo	Cocio	Palavecino	Roberto	González-Ibáñez		Estudio del impacto de mejoras en usabilidad y del modelo de adopción tecnológica de SERVS en el desempeño y experiencia de usuario en una tarea de selección y organización de información	2021-03-28 20:33:17.077595	2021-03-28 20:33:17.077595	5		jorge.ricardo.cocio@usach.cl
3367	167	3	Redes y Seguridad	4	OP	2018	1	0	Rodrigo Carlos	Cerda	Ruiz	J.	L.	Jara	Sincronización de archivos multimedia a través de reconocimiento de patrones en sus señales de audio	2021-03-28 20:33:17.089409	2021-03-28 20:33:17.089409	7	jljara@usach.cl	rodrigo.carlos.cerda@usach.cl
3368	168	1	Sistemas Complejos	3	OP	2018	2	0	Jonathan Iván	Catalán	Álvarez	Roberto	González-Ibáñez		Desarrollo de un módulo para soportar la interacción táctil y natural gestual a través de las manos con objetos de información digital en Motions	2021-03-28 20:33:17.100937	2021-03-28 20:33:17.100937	5		jonathan.ivan.catalan@usach.cl
3369	169	1	Biología y Medicina	3	OP	2018	2	0	Kevin Alexis	Canales	Bustamante	Arturo	Álvarez	Cea	MOA : aplicación multiplataforma para la comunicación de UAVs DJI a través del protocolo WebSocket	2021-03-28 20:33:17.122668	2021-03-28 20:33:17.122668	25	arturo.alvarez@usach.cl	kevin.alexis.canales@usach.cl
3370	170	2	Biología y Medicina	4	OP	2018	1	0	José Antonio	Camus	Godoy	Francisco	Acuña	Castillo	Plataforma web de vinculación constante y bidireccional entre los títulados y la Universidad de Santiago de Chile	2021-03-28 20:33:17.134326	2021-03-28 20:33:17.134326	21	francisco.acuna@usach.cl	jose.antonio.camus@usach.cl
3371	171	1	Sistemas Complejos	3	OP	2018	2	0	Carlos Felipe	Cáceres	Rodríguez	Roberto	González-Ibáñez		Desarrollo de un módulo para la interacción, control y monitoreo remoto en el software multimodal observer	2021-03-28 20:33:17.144396	2021-03-28 20:33:17.144396	5		carlos.felipe.caceres@usach.cl
3372	172	1	Interacción Humano-Computador	3	OP	2018	2	0	Francisco Ignacio	Avello	Barrera	Carolina	Bonacic	Castro	Banco de tiempo : plataforma para intercambio de servicios unipersonales	2021-03-28 20:33:17.16897	2021-03-28 20:33:17.16897	2	carolina.bonacic@usach.cl	francisco.ignacio.avello@usach.cl
3373	173	1	Informática Educativa	4	OP	2018	1	0	Mario Francisco	Álvarez	Molina	Alcides	Quispe	Sanca	Depurador visual para Python orientado al apoyo pedagógico	2021-03-28 20:33:17.191068	2021-03-28 20:33:17.191068	14	alcides.quispe@usach.cl	mario.francisco.alvarez@usach.cl
3374	174	1	Aplicaciones y Sistemas Escalables para la Web	4	OP	2018	1	0	Marcelo Antonio	Acevedo	Pavez	Edgardo	Sepúlveda	Sariego	Solución de archiving orientada a la mejora de respuesta de operaciones de carácter clínico	2021-03-28 20:33:17.211927	2021-03-28 20:33:17.211927	81	edgardo.sepulveda.s@usach.cl	marcelo.antonio.acevedo@usach.cl
3375	175	3	Biología y Medicina	4	OP	2019	1	0	Christian David	Vidal	Cerda	Víctor	Parada	Daza	Aplicación geoestadística multivariable distribuida en una plataforma Cloud con GPU	2021-03-28 20:33:17.236688	2021-03-28 20:33:17.236688	13	victor.parada@usach.cl	christian.david.vidal@usach.cl
3376	176	1	Interacción Humano-Computador	3	OP	2019	2	0	Juan Pablo	Véliz	García	Edmundo	Leiva-Lobos		Creación de portafolio electrónico para el curso de seminario de título y automatización del flujo de negocio del curso	2021-03-28 20:33:17.256105	2021-03-28 20:33:17.256105	9	edmundo.leiva@usach.cl	juan.pablo.veliz@usach.cl
3377	177	3	Sistemas Complejos	4	OP	2019	1	0	Ariel Ignacio	Tirado	Maturana	J.	L.	Jara	Desarrollo de un sistema para el seguimiento de alumnos con necesidades educativas especiales en cursos de enseñanza básica	2021-03-28 20:33:17.269746	2021-03-28 20:33:17.269746	7	jljara@usach.cl	ariel.ignacio.tirado@usach.cl
3378	178	1	Interacción Humano-Computador	3	OP	2019	2	0	Isaac	Silva	Luna	Víctor	Parada	Daza	Algoritmos evolutivos evaluados en la resolución del problema de selección de atributos con objetivo cuádruple sobre datos desbalanceados sin manipulación de muestra	2021-03-28 20:33:17.289686	2021-03-28 20:33:17.289686	13	victor.parada@usach.cl	isaac.silva@usach.cl
3379	179	1	Interacción Humano-Computador	3	OP	2019	2	0	Javiera Fernanda	Sáez	León	Bruno	Jerardino	Wiesenborn	Implementación de la cuarta y quinta etapa de la metodología de sistemas blandos en la aplicación Soft Systems Manager	2021-03-28 20:33:17.300536	2021-03-28 20:33:17.300536	54	bruno.jerardino@usach.cl	javiera.fernanda.saez@usach.cl
3380	180	1	Informática Educativa	3	OP	2019	2	0	Patricio Andrés	Rocco	Hernández	Mónica	Villanueva	Ilufi	Modelamiento de red wi-fi pública - en dependencias de Plaza S.A.	2021-03-28 20:33:17.313132	2021-03-28 20:33:17.313132	19	monica.villanueva@usach.cl	patricio.andres.rocco@usach.cl
3381	181	1	Interacción Humano-Computador	3	OP	2019	2	0	Luis Felipe	Riquelme	Pradenas	Alcides	Quispe	Sanca	Sistema de apoyo al estudiante para facilitar el aprendizaje en cursos introductorios de programación aplicando gamificación	2021-03-28 20:33:17.33386	2021-03-28 20:33:17.33386	14	alcides.quispe@usach.cl	luis.felipe.riquelme@usach.cl
3382	182	1	Biología y Medicina	3	OP	2019	2	0	Juan Pablo	Retamales	Lepe	Max	Chacón	Pacheco	Sistema de recomendación para la detección de zonas en la aplicación de radioterapia en neoplasias malignas basado en análisis de tomografías computarizadas	2021-03-28 20:33:17.356069	2021-03-28 20:33:17.356069	3	max.chacon@usach.cl	juan.pablo.retamales@usach.cl
3383	183	1	Sistemas Complejos	3	OP	2019	2	0	Franco	Ramorino	Guzmán	Arturo	Terra	Vásquez	Evaluando la ciberseguridad de una empresa de diseño web, desarrollo y hosting en Chile	2021-03-28 20:33:17.377807	2021-03-28 20:33:17.377807	82	arturo.terra.v@usach.cl	franco.ramorino@usach.cl
3384	184	2	Redes y Seguridad	3	OP	2019	2	0	Polett Andrea	Pizarro	Pérez	Roberto	González-Ibáñez		Desarrollo de servicios de evaluación y recomendaciones de contenido web para asegurar la compatibilidad con lectores de pantalla	2021-03-28 20:33:17.402259	2021-03-28 20:33:17.402259	5		polett.andrea.pizarro@usach.cl
3385	185	2	Sistemas Complejos	4	OP	2019	1	0	Marcelo Nicolás	Muñoz	Muñoz	Rosa	Muñoz	Calanchie	Sistema web para preparar la PSU con características de gamificación	2021-03-28 20:33:17.422204	2021-03-28 20:33:17.422204	12	rosa.munoz@usach.cl	marcelo.nicolas.munoz@usach.cl
3386	186	1	Biología y Medicina	4	OP	2019	1	0	Luis Ignacio	Migryk	Tapia	Carolina	Bonacic	Castro	Sigesam : Sistema de unificación de información para apoyar la gestión del programa calle en centros comunitarios de salud mental	2021-03-28 20:33:17.435832	2021-03-28 20:33:17.435832	2	carolina.bonacic@usach.cl	luis.ignacio.migryk@usach.cl
3387	187	2	Informática Educativa	4	OP	2019	1	0	Francisco Matías	Lagos	Sepúlveda	Mónica	Villanueva	Ilufi	Sistema de control financiero y presupuestario de gastos operacionales y control de proyectos para la Unidad de Pasos Fronterizos	2021-03-28 20:33:17.45667	2021-03-28 20:33:17.45667	19	monica.villanueva@usach.cl	francisco.matias.lagos@usach.cl
3388	188	1	Sistemas Complejos	3	OP	2019	2	0	Maximiliano Antonio	Herrera	Rendic	Felipe	Bello	Robles	Modelamiento e implementación de un sistema de apoyo a la toma de decisiones para predecir el riesgo de deserción de alumnos diurnos del Departamento de Ingeniería Informática de la Universidad de Santiago de Chile	2021-03-28 20:33:17.469278	2021-03-28 20:33:17.469278	28	felipe.bello@usach.cl	maximiliano.antonio.herrera@usach.cl
3389	189	3	Interacción Humano-Computador	4	OP	2019	1	0	Tomás Baruch	Gutiérrez	Lethaby	Cristóbal	Acosta	Jurado	Comparación e integración de herramientas para la implementación del pipeline de DevOps para el proceso de desarrollo y operación de software en el Departamento de Ingeniería Informática	2021-03-28 20:33:17.490035	2021-03-28 20:33:17.490035	86	cristobal.acosta.j@usach.cl	tomas.baruch.gutierrez@usach.cl
3390	190	2	Sistemas Complejos	4	OP	2019	1	0	Fabián Andrés	Gómez	Cuevas	Víctor	Parada	Daza	Herramienta computacional para predecir la congestión vehicular producida por accidentes	2021-03-28 20:33:17.499826	2021-03-28 20:33:17.499826	13	victor.parada@usach.cl	fabian.andres.gomez@usach.cl
3391	191	1	Redes y Seguridad	4	OP	2019	1	0	Juan Cristián	Giglio	Gutiérrez	Manuel	Villalobos	Cid	Algoritmo genérico para el problema de escalamiento multidimensional multi-objetivo	2021-03-28 20:33:17.512663	2021-03-28 20:33:17.512663	18	manuel.villalobos@usach.cl	juan.cristian.giglio@usach.cl
3392	192	1	Biología y Medicina	3	OP	2019	2	0	Ignacio Nicolás	Cuadra	Zamora	Edmundo	Leiva-Lobos		NOVAMap#: Herramienta visual para definir modelos workflow	2021-03-28 20:33:17.533751	2021-03-28 20:33:17.533751	9	edmundo.leiva@usach.cl	ignacio.nicolas.cuadra@usach.cl
3393	193	1	Aplicaciones y Sistemas Escalables para la Web	4	OP	2019	1	0	Abraham Ignacio	Cerda	Iturra	Roberto	González-Ibáñez		Extensiones de multimodal observer para administración remota de procesos y monitoreo de actividad de navegación web	2021-03-28 20:33:17.543545	2021-03-28 20:33:17.543545	5		abraham.ignacio.cerda@usach.cl
3394	194	3	Aplicaciones y Sistemas Escalables para la Web	3	OP	2019	2	0	Ángelo Jesús	Carlier	González	Manuel	Villalobos	Cid	Caracterización de la clasificación de los establecimientos públicos de salud en Chile según complejidad mediante la identificación de variables asociadas a casuística hospitalaria	2021-03-28 20:33:17.556425	2021-03-28 20:33:17.556425	18	manuel.villalobos@usach.cl	angelo.jesus.carlier@usach.cl
3395	195	1	Informática Educativa	3	OP	2019	2	0	David Orión	Calistro	Cayuqueo	Roberto	González-Ibáñez		b-Games: framework enfocado en el desarrollo de servicios de datos para videojuegos mapeando fuentes de información al perfil de un usuario	2021-03-28 20:33:17.568016	2021-03-28 20:33:17.568016	5		david.orion.calistro@usach.cl
3396	196	1	Biología y Medicina	4	OP	2019	1	0	Fernando Humberto	Briceño	Gómez	Aldo	Guerra	González	Sistema informático para apoyar el diagnóstico e intervención de los adultos mayores realizadas por equipo profesional multidisciplinario en centro diurno especializado San Bernardo	2021-03-28 20:33:17.589773	2021-03-28 20:33:17.589773	49	aldo.guerra@usach.cl	fernando.humberto.briceno@usach.cl
3397	197	1	Sistemas Complejos	4	OP	2019	1	0	Germán	Bichon	Campos	Arturo	Álvarez	Cea	Aplicación web responsiva para generación automática de planes de vuelo en drones que aplican agroquímicos	2021-03-28 20:33:17.599996	2021-03-28 20:33:17.599996	25	arturo.alvarez@usach.cl	german.bichon@usach.cl
3398	198	1	Aplicaciones y Sistemas Escalables para la Web	4	OP	2019	1	0	Juan Andrés	Barrera	Barril	Edgardo	Sepúlveda	Sariego	Sistema de punto de venta para Restaurant El Encuentro	2021-03-28 20:33:17.609974	2021-03-28 20:33:17.609974	81	edgardo.sepulveda.s@usach.cl	juan.andres.barrera@usach.cl
3399	199	1	Redes y Seguridad	3	OP	2019	2	0	Diego Antonio	Arenas	Riveros	Gonzalo	Acuña	Leiva	Predicción de series de tiempo continuas utilizando métodos de aprendizaje profundo basado basado en LSTM y redes convolucionales	2021-03-28 20:33:17.623488	2021-03-28 20:33:17.623488	1	gonzalo.acuna@usach.cl	diego.antonio.arenas@usach.cl
3400	200	3	Informática Educativa	4	OP	2019	1	0	Joaquín Abel	Acuña	Espinoza	Andrés	Rice	Mora	Solución tecnológica para calificar pruebas de selección múltiple usando reconocimiento visual asistido por computadora para plataforma educativa Classtrack	2021-03-28 20:33:17.634398	2021-03-28 20:33:17.634398	66	andres.rice@usach.cl	joaquin.abel.acuna@usach.cl
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: work_plans; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.work_plans (id, state, trabajo_titulacion, activity_pending, activity_finished, thesis_id, created_at, updated_at) FROM stdin;
50	pendiente	f	1	0	3250	2021-04-25 22:32:40.656428	2021-04-25 22:32:40.656428
\.


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.active_storage_attachments_id_seq', 17, true);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.active_storage_blobs_id_seq', 17, true);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.active_storage_variant_records_id_seq', 1, false);


--
-- Name: activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.activities_id_seq', 106, true);


--
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.admins_id_seq', 1, true);


--
-- Name: commentaries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.commentaries_id_seq', 1, false);


--
-- Name: professor_summaries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.professor_summaries_id_seq', 871, true);


--
-- Name: proposals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.proposals_id_seq', 37, true);


--
-- Name: student_summaries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.student_summaries_id_seq', 206, true);


--
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.tasks_id_seq', 29, true);


--
-- Name: thesis_summaries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.thesis_summaries_id_seq', 3400, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: work_plans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: root
--

SELECT pg_catalog.setval('public.work_plans_id_seq', 50, true);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: commentaries commentaries_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.commentaries
    ADD CONSTRAINT commentaries_pkey PRIMARY KEY (id);


--
-- Name: professor_summaries professor_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.professor_summaries
    ADD CONSTRAINT professor_summaries_pkey PRIMARY KEY (id);


--
-- Name: proposals proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.proposals
    ADD CONSTRAINT proposals_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: student_summaries student_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.student_summaries
    ADD CONSTRAINT student_summaries_pkey PRIMARY KEY (id);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: thesis_summaries thesis_summaries_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.thesis_summaries
    ADD CONSTRAINT thesis_summaries_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: work_plans work_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.work_plans
    ADD CONSTRAINT work_plans_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_activities_on_work_plan_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_activities_on_work_plan_id ON public.activities USING btree (work_plan_id);


--
-- Name: index_commentaries_on_activity_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_commentaries_on_activity_id ON public.commentaries USING btree (activity_id);


--
-- Name: index_tasks_on_activity_id; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX index_tasks_on_activity_id ON public.tasks USING btree (activity_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: activities activity_number_ad; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER activity_number_ad AFTER DELETE ON public.activities FOR EACH ROW EXECUTE FUNCTION public.eliminarnumeroactividades();


--
-- Name: activities activity_number_ai; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER activity_number_ai AFTER INSERT ON public.activities FOR EACH ROW EXECUTE FUNCTION public.insertarnumeroactividades();


--
-- Name: activities activity_number_au; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER activity_number_au AFTER UPDATE ON public.activities FOR EACH ROW EXECUTE FUNCTION public.actualizarnumeroactividades();


--
-- Name: activities activity_state_au; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER activity_state_au AFTER UPDATE ON public.activities FOR EACH ROW EXECUTE FUNCTION public.actualizarestadoactividad();


--
-- Name: tasks task_number_ad; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER task_number_ad AFTER DELETE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.eliminarnumerotareas();


--
-- Name: tasks task_number_ai; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER task_number_ai AFTER INSERT ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.insertarnumerotareas();


--
-- Name: tasks task_number_au; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER task_number_au AFTER UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.actualizarnumerotareas();


--
-- Name: work_plans workplan_state_au; Type: TRIGGER; Schema: public; Owner: root
--

CREATE TRIGGER workplan_state_au AFTER UPDATE ON public.work_plans FOR EACH ROW EXECUTE FUNCTION public.actualizarestadoworkplan();


--
-- Name: commentaries fk_rails_2b960cdf56; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.commentaries
    ADD CONSTRAINT fk_rails_2b960cdf56 FOREIGN KEY (activity_id) REFERENCES public.activities(id);


--
-- Name: activities fk_rails_5b852e9466; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT fk_rails_5b852e9466 FOREIGN KEY (work_plan_id) REFERENCES public.work_plans(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: tasks fk_rails_a6e8c4c2d5; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT fk_rails_a6e8c4c2d5 FOREIGN KEY (activity_id) REFERENCES public.activities(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- PostgreSQL database dump complete
--

