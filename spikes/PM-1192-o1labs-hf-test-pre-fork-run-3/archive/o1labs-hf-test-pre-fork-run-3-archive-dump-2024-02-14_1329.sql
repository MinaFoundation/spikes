--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.6

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
-- Name: archive; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE archive WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';


\connect archive

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
-- Name: archive; Type: DATABASE PROPERTIES; Schema: -; Owner: -
--

ALTER DATABASE archive SET default_transaction_isolation TO 'serializable';


\connect archive

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: chain_status_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.chain_status_type AS ENUM (
    'canonical',
    'orphaned',
    'pending'
);


--
-- Name: internal_command_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.internal_command_type AS ENUM (
    'fee_transfer_via_coinbase',
    'fee_transfer',
    'coinbase'
);


--
-- Name: user_command_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_command_status AS ENUM (
    'applied',
    'failed'
);


--
-- Name: user_command_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_command_type AS ENUM (
    'payment',
    'delegation',
    'create_token',
    'create_account',
    'mint_tokens'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: balances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.balances (
    id integer NOT NULL,
    public_key_id integer NOT NULL,
    balance bigint NOT NULL,
    block_id integer NOT NULL,
    block_height integer NOT NULL,
    block_sequence_no integer NOT NULL,
    block_secondary_sequence_no integer NOT NULL,
    nonce bigint
);


--
-- Name: balances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.balances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: balances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.balances_id_seq OWNED BY public.balances.id;


--
-- Name: blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blocks (
    id integer NOT NULL,
    state_hash text NOT NULL,
    parent_id integer,
    parent_hash text NOT NULL,
    creator_id integer NOT NULL,
    block_winner_id integer NOT NULL,
    snarked_ledger_hash_id integer NOT NULL,
    staking_epoch_data_id integer NOT NULL,
    next_epoch_data_id integer NOT NULL,
    ledger_hash text NOT NULL,
    height bigint NOT NULL,
    global_slot bigint NOT NULL,
    global_slot_since_genesis bigint NOT NULL,
    "timestamp" bigint NOT NULL,
    chain_status public.chain_status_type NOT NULL
);


--
-- Name: blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.blocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.blocks_id_seq OWNED BY public.blocks.id;


--
-- Name: blocks_internal_commands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blocks_internal_commands (
    block_id integer NOT NULL,
    internal_command_id integer NOT NULL,
    sequence_no integer NOT NULL,
    secondary_sequence_no integer NOT NULL,
    receiver_account_creation_fee_paid bigint,
    receiver_balance integer NOT NULL
);


--
-- Name: blocks_user_commands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blocks_user_commands (
    block_id integer NOT NULL,
    user_command_id integer NOT NULL,
    sequence_no integer NOT NULL,
    status public.user_command_status NOT NULL,
    failure_reason text,
    fee_payer_account_creation_fee_paid bigint,
    receiver_account_creation_fee_paid bigint,
    created_token bigint,
    fee_payer_balance integer NOT NULL,
    source_balance integer,
    receiver_balance integer
);


--
-- Name: epoch_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.epoch_data (
    id integer NOT NULL,
    seed text NOT NULL,
    ledger_hash_id integer NOT NULL
);


--
-- Name: epoch_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.epoch_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: epoch_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.epoch_data_id_seq OWNED BY public.epoch_data.id;


--
-- Name: internal_commands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.internal_commands (
    id integer NOT NULL,
    type public.internal_command_type NOT NULL,
    receiver_id integer NOT NULL,
    fee bigint NOT NULL,
    token bigint NOT NULL,
    hash text NOT NULL
);


--
-- Name: internal_commands_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.internal_commands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: internal_commands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.internal_commands_id_seq OWNED BY public.internal_commands.id;


--
-- Name: public_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.public_keys (
    id integer NOT NULL,
    value text NOT NULL
);


--
-- Name: public_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.public_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: public_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.public_keys_id_seq OWNED BY public.public_keys.id;


--
-- Name: snarked_ledger_hashes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.snarked_ledger_hashes (
    id integer NOT NULL,
    value text NOT NULL
);


--
-- Name: snarked_ledger_hashes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.snarked_ledger_hashes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: snarked_ledger_hashes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.snarked_ledger_hashes_id_seq OWNED BY public.snarked_ledger_hashes.id;


--
-- Name: timing_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.timing_info (
    id integer NOT NULL,
    public_key_id integer NOT NULL,
    token bigint NOT NULL,
    initial_balance bigint NOT NULL,
    initial_minimum_balance bigint NOT NULL,
    cliff_time bigint NOT NULL,
    cliff_amount bigint NOT NULL,
    vesting_period bigint NOT NULL,
    vesting_increment bigint NOT NULL
);


--
-- Name: timing_info_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.timing_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: timing_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.timing_info_id_seq OWNED BY public.timing_info.id;


--
-- Name: user_commands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_commands (
    id integer NOT NULL,
    type public.user_command_type NOT NULL,
    fee_payer_id integer NOT NULL,
    source_id integer NOT NULL,
    receiver_id integer NOT NULL,
    fee_token bigint NOT NULL,
    token bigint NOT NULL,
    nonce bigint NOT NULL,
    amount bigint,
    fee bigint NOT NULL,
    valid_until bigint,
    memo text NOT NULL,
    hash text NOT NULL
);


--
-- Name: user_commands_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_commands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_commands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_commands_id_seq OWNED BY public.user_commands.id;


--
-- Name: balances id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.balances ALTER COLUMN id SET DEFAULT nextval('public.balances_id_seq'::regclass);


--
-- Name: blocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks ALTER COLUMN id SET DEFAULT nextval('public.blocks_id_seq'::regclass);


--
-- Name: epoch_data id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.epoch_data ALTER COLUMN id SET DEFAULT nextval('public.epoch_data_id_seq'::regclass);


--
-- Name: internal_commands id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_commands ALTER COLUMN id SET DEFAULT nextval('public.internal_commands_id_seq'::regclass);


--
-- Name: public_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_keys ALTER COLUMN id SET DEFAULT nextval('public.public_keys_id_seq'::regclass);


--
-- Name: snarked_ledger_hashes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snarked_ledger_hashes ALTER COLUMN id SET DEFAULT nextval('public.snarked_ledger_hashes_id_seq'::regclass);


--
-- Name: timing_info id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timing_info ALTER COLUMN id SET DEFAULT nextval('public.timing_info_id_seq'::regclass);


--
-- Name: user_commands id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_commands ALTER COLUMN id SET DEFAULT nextval('public.user_commands_id_seq'::regclass);


--
-- Data for Name: balances; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.balances (id, public_key_id, balance, block_id, block_height, block_sequence_no, block_secondary_sequence_no, nonce) FROM stdin;
1	2	2440000000000	2	2	0	0	0
2	4	2440000000000	3	2	0	0	0
3	6	2440000000000	4	2	0	0	0
4	8	2440000000000	5	3	0	0	0
5	10	2440000000000	6	4	0	0	0
6	12	2440000000000	7	5	0	0	0
7	14	2440000000000	8	6	0	0	0
8	16	2440000000000	9	7	0	0	0
9	4	2440000000000	10	8	0	0	0
10	18	1720000000000	11	9	0	0	0
11	20	2440000000000	12	10	0	0	0
12	6	2440000000000	13	11	0	0	0
13	8	3880000000000	14	12	0	0	0
14	22	2440000000000	15	13	0	0	0
15	4	3880000000000	16	14	0	0	0
16	20	3880000000000	17	14	0	0	0
17	4	5320000000000	18	15	0	0	0
18	25	2440000000000	19	15	0	0	0
19	27	2440000000000	20	16	0	0	0
20	2	3880000000000	21	17	0	0	0
21	4	5320000000000	22	18	0	0	0
22	29	2440000000000	23	18	0	0	0
23	2	5320000000000	24	19	0	0	0
24	20	3880000000000	25	19	0	0	0
25	2	5320000000000	26	20	0	0	0
26	12	3880000000000	27	20	0	0	0
27	12	5320000000000	28	21	0	0	0
28	33	2440000000000	29	21	0	0	0
29	12	6760000000000	30	22	0	0	0
30	36	2440000000000	31	23	0	0	0
31	38	2440000000000	32	24	0	0	0
32	40	2440000000000	33	25	0	0	0
33	4	6760000000000	34	26	0	0	0
34	8	5320000000000	35	27	0	0	0
35	42	2440000000000	36	27	0	0	0
36	44	2440000000000	37	28	0	0	0
37	42	3880000000000	38	29	0	0	0
38	4	8200000000000	39	30	0	0	0
39	22	3880000000000	40	31	0	0	0
40	16	3880000000000	41	32	0	0	0
41	2	5320000000000	42	33	0	0	0
42	48	2440000000000	43	34	0	0	0
43	50	2440000000000	44	34	0	0	0
44	6	3880000000000	45	35	0	0	0
45	52	2440000000000	46	35	0	0	0
46	6	3880000000000	47	36	0	0	0
47	12	8200000000000	48	37	0	0	0
48	36	3880000000000	49	38	0	0	0
49	42	5320000000000	50	38	0	0	0
50	14	3880000000000	51	39	0	0	0
51	2	6760000000000	52	40	0	0	0
52	27	3880000000000	53	41	0	0	0
53	29	2440000000000	54	42	0	0	0
54	58	2440000000000	55	42	0	0	0
55	2	7480000000000	56	43	0	0	0
56	4	9640000000000	57	44	0	0	0
57	61	2440000000000	58	45	0	0	0
58	8	5320000000000	59	46	0	0	0
59	61	3880000000000	60	46	0	0	0
60	10	3880000000000	61	46	0	0	0
61	20	5320000000000	62	47	0	0	0
62	65	2440000000000	63	48	0	0	0
63	12	9640000000000	64	49	0	0	0
64	6	5320000000000	65	50	0	0	0
65	12	11080000000000	66	50	0	0	0
\.


--
-- Data for Name: blocks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.blocks (id, state_hash, parent_id, parent_hash, creator_id, block_winner_id, snarked_ledger_hash_id, staking_epoch_data_id, next_epoch_data_id, ledger_hash, height, global_slot, global_slot_since_genesis, "timestamp", chain_status) FROM stdin;
1	3NKB6vcwfc2mSW2ZW5gnVzqDJLCTtKod87Be1PMttdtnCmqiiiZK	\N	3NLE3FV5LF275GEUrNvbcRpUt1pZY52tjHw4fBV3gZL3Mkqz9fXU	1	1	1	1	2	jxZZMTrP6Bc2y9vN69hsgWL5t5yqtnrULikgox5brC1LNFh6YLq	1	0	0	1707901200000	canonical
2	3NKNecWFjRNCnarTGVBY9KGHAmp6RtpFGDHYWX7XcvUVDTP6a7PK	1	3NKB6vcwfc2mSW2ZW5gnVzqDJLCTtKod87Be1PMttdtnCmqiiiZK	2	3	1	1	3	jxYCPfF1SyjDXiQrgePeYhQPwRfdiqfEPZrQ3CgNzSyKF8dBQG2	2	1	1	1707901380000	pending
3	3NKDn6rYBUYXc1Jvjx64Dw4E4NmGdmduo866FReCPF8oMApC3TgY	1	3NKB6vcwfc2mSW2ZW5gnVzqDJLCTtKod87Be1PMttdtnCmqiiiZK	4	5	1	1	4	jwMhd22zTEB6ojU5DZMhqfdXnGGXAnq7MAMy7jnkqYkNwYgDcYA	2	1	1	1707901380000	pending
4	3NLGPpUVicCnETwp6hap13redoRH5DTmv8jtmMJSrv7TA4NU7UUS	1	3NKB6vcwfc2mSW2ZW5gnVzqDJLCTtKod87Be1PMttdtnCmqiiiZK	6	7	1	1	5	jxLLMVMq11Jkfh4A1rbwqkMx8b2J4JKv4YACgpxWnuFWxU2tTrX	2	1	1	1707901380000	pending
5	3NKAxGEYdhhiwEUXn3EM7i3G74h8UPSNGmUWgA7Pq8ypwNWjid29	2	3NKNecWFjRNCnarTGVBY9KGHAmp6RtpFGDHYWX7XcvUVDTP6a7PK	8	9	1	1	6	jx3UedQH4MPt6p3FuusH2zsThztVJPg5CFj85jVD4NAU8czfNSZ	3	2	2	1707901560000	pending
6	3NLdCBNrDseiDKvVj8rZ15k2oAUvx4XuCc8mzf6fL2CmqTJVVceM	5	3NKAxGEYdhhiwEUXn3EM7i3G74h8UPSNGmUWgA7Pq8ypwNWjid29	10	11	1	1	7	jxxd2EHWmL9ekCNKvrxL4WCcpXdBXiMCNoie2yZnPe8nyPgQpNR	4	6	6	1707902280000	pending
7	3NKQEX1iDZrD9jM1vZ7BcRw8u7hvxbXDUQfxKHa7bqzvpg8XWUTS	6	3NLdCBNrDseiDKvVj8rZ15k2oAUvx4XuCc8mzf6fL2CmqTJVVceM	12	13	1	1	8	jy2gGKJydQoj5Ch9H4QvFJqYvLX4NjNwsCsstazJGXKfJkRkJq6	5	9	9	1707902820000	pending
8	3NKgAtqGxMukEvyVoq7u5t46wPUCs56Kn46mevvByXy7b9Yy9Hkq	7	3NKQEX1iDZrD9jM1vZ7BcRw8u7hvxbXDUQfxKHa7bqzvpg8XWUTS	14	15	1	1	9	jwBKU6cSLjWwhTScqpDGtPzWvvGMXMr3FeN1LL1eHARLuzzozmV	6	13	13	1707903540000	pending
9	3NKKCVzz8m6cVwP57AjLdLGtTdUetqWygCWVtawE95A3n46WFFak	8	3NKgAtqGxMukEvyVoq7u5t46wPUCs56Kn46mevvByXy7b9Yy9Hkq	16	17	1	1	10	jxNp5sS9eHrs4eEp3ot5T2jb1BbvfLDTXwhgRu6etDXzaN7PF4J	7	14	14	1707903720000	pending
10	3NLA3bLWZcHsq5sqc4XhufB3szenLnsw8cHYDBpq66Z98Jg5h3La	9	3NKKCVzz8m6cVwP57AjLdLGtTdUetqWygCWVtawE95A3n46WFFak	4	5	1	1	11	jwDR5jDAain4vQKRkZGRJmrhuCGpLHhHHM4fu7WLkCA2HGh9dYW	8	15	15	1707903900000	pending
11	3NKe2wgbnbP43jYW4FmwKLJedqDDgLBNhCAg9bTyMtHwAXVK8Eds	10	3NLA3bLWZcHsq5sqc4XhufB3szenLnsw8cHYDBpq66Z98Jg5h3La	18	19	1	1	12	jwUcRExNqZCFo3oR7tTGuo26MRZ5KRnhRirUGexBnwnrMDURtaf	9	18	18	1707904440000	pending
12	3NKYrwTWUU3WnmigzFRm4YxHTfmZHMXTYj58K3qoPe7Gh7b4pCZv	11	3NKe2wgbnbP43jYW4FmwKLJedqDDgLBNhCAg9bTyMtHwAXVK8Eds	20	21	1	1	13	jxzK26fiGWkD6m8gfNnScEHwH2rRrqDWVUktgnZcxewoA4ncrRG	10	19	19	1707904620000	pending
13	3NKypVEZeLiHPT9A4DY9Tj7BkZEggcHP83N2Sk7deciFoG8QKf8P	12	3NKYrwTWUU3WnmigzFRm4YxHTfmZHMXTYj58K3qoPe7Gh7b4pCZv	6	7	1	1	14	jwTJfFpVNLoYWLsZRA9Gv3FrAXHsQFCXmuLt4wnm16HCJL2ybFL	11	20	20	1707904800000	pending
14	3NKti9fctUZ5u5GvvUUnfq78eQCUARmUsc8KmW5mjS139BKB5WSu	13	3NKypVEZeLiHPT9A4DY9Tj7BkZEggcHP83N2Sk7deciFoG8QKf8P	8	9	1	1	15	jxTkAn9gFNy6dRxvxsKp5JzQnaUzr4NrHULUPbN8n2Jysq2GQfJ	12	25	25	1707905700000	pending
15	3NLekdpKFgVjHx8MVCwBqjHqAvRzY1XtKdyGYutXcEzJjevFNwQJ	14	3NKti9fctUZ5u5GvvUUnfq78eQCUARmUsc8KmW5mjS139BKB5WSu	22	23	1	1	16	jxHFbDYx98wbqy7PaS265rGUuz2z1gFG1588bsXTaZidQ1BdV3B	13	27	27	1707906060000	pending
16	3NLGU6YbWesRrUwR6JLXMWgHwSenpbunULkR4MAwCY5uuW1TwHTr	15	3NLekdpKFgVjHx8MVCwBqjHqAvRzY1XtKdyGYutXcEzJjevFNwQJ	4	5	1	1	17	jwbbich2TLTogM5MYhvTEaxkVdWwaRQ9oaxZuqX2qeRhTZ2ytyd	14	28	28	1707906240000	pending
17	3NLY2188Z8Vc5G8S67JeR2EgYpDoHejwVokakyy1LzHiftGsyLLP	15	3NLekdpKFgVjHx8MVCwBqjHqAvRzY1XtKdyGYutXcEzJjevFNwQJ	20	24	1	1	18	jwm1PonwAjSSZfxSxkPdtz6eoaqyWmn5eKbr6ERuVQNMZPJyqNe	14	28	28	1707906240000	pending
18	3NLXi46uumqkEzMHkiJynUPTw8xyoFYwu6cu8rjX4svu3Rv9L7gt	16	3NLGU6YbWesRrUwR6JLXMWgHwSenpbunULkR4MAwCY5uuW1TwHTr	4	5	1	1	19	jwGbmMDa8USNax4fTbf1HXvM4GoLyiYhSoTacPSNM7EjSxk4AhP	15	29	29	1707906420000	pending
19	3NLeweGQ4bcc9XrzV7rS34ZLaQddmwrCV7CFWwZRj2Sp3mwuf8aP	16	3NLGU6YbWesRrUwR6JLXMWgHwSenpbunULkR4MAwCY5uuW1TwHTr	25	26	1	1	20	jx89JrFHTPhNZxKgeAGT26vtmYqid5rGeaBtc8A8JN7ZSio8g1w	15	29	29	1707906420000	pending
20	3NL6SCe6DUmfGVNarnfbraBcnZiqSKspMVhHW1LEAA7zPRVzT6VU	19	3NLeweGQ4bcc9XrzV7rS34ZLaQddmwrCV7CFWwZRj2Sp3mwuf8aP	27	28	1	1	21	jwG2h3Dt4zJf1vkH2cRwwmBazAuC9iH5JRh3QKo1JsgXszxGG1V	16	32	32	1707906960000	pending
21	3NKbU5hEcAB9buQ91e5t3PiS6aenHU7bSK4HnSHfrcRab2TXRn41	20	3NL6SCe6DUmfGVNarnfbraBcnZiqSKspMVhHW1LEAA7zPRVzT6VU	2	3	1	1	22	jxg8HMoeViWKgRJitnukJN7jsdJKAWWcm3ftq8Bur8XrVuJspke	17	34	34	1707907320000	pending
22	3NKjDokhXLSkmMn8oXp1zmh5dm2RL9YsHxihwmZNhsGfP3SWnVgH	21	3NKbU5hEcAB9buQ91e5t3PiS6aenHU7bSK4HnSHfrcRab2TXRn41	4	5	1	1	23	jxW5U3xGPSidDvE8PkGqBZRnXyCKjehyyTSCGQXgmr2ggpDp8WN	18	36	36	1707907680000	pending
23	3NKEoT3CnfukD4nhfaiQdmTAbEZ5M2aKApQ88TPXH6QJXbo7dif2	21	3NKbU5hEcAB9buQ91e5t3PiS6aenHU7bSK4HnSHfrcRab2TXRn41	29	30	1	1	24	jxqtMLvM3Rgtmr4vdmbRRUk7N6RaxvPmNC8xQuR6my3ETtgkuPt	18	36	36	1707907680000	pending
24	3NKUNQtGsFdxzErtGKvRUuSKBQ6rSAfAfAVCAmc6GDAcCDRYYRtC	22	3NKjDokhXLSkmMn8oXp1zmh5dm2RL9YsHxihwmZNhsGfP3SWnVgH	2	3	1	1	25	jwKq5Va89HD8XZGRx9qTSiE77Fp6YGNQZf8BSomgBBnn6bRa2BP	19	37	37	1707907860000	pending
25	3NKrLNtSsMNJEqTJSux63m9vQ9UcnkJtFa1Pr43QkgJWkYrPzWmj	22	3NKjDokhXLSkmMn8oXp1zmh5dm2RL9YsHxihwmZNhsGfP3SWnVgH	20	21	1	1	26	jxkuS7h54LtFeamZPhE8keZzCEDPaWUy3zxEtnhLAP2a7xUETqC	19	37	37	1707907860000	pending
26	3NLCYWyPa7wpUc811UY4aY5BDuP4YUTUPpTrxdxrPAhWvsGk2JXq	25	3NKrLNtSsMNJEqTJSux63m9vQ9UcnkJtFa1Pr43QkgJWkYrPzWmj	2	3	1	1	27	jxSYWNwwceLJqAh4xiGuSiWkgKm7DfjVQKEu2XjMFsFVKvePEsS	20	41	41	1707908580000	pending
27	3NKjU5uHZUDoBpaWm6nTYFo6WWvRFQuUmTXFm3TDtkkxCcgVHvC8	25	3NKrLNtSsMNJEqTJSux63m9vQ9UcnkJtFa1Pr43QkgJWkYrPzWmj	12	31	1	1	28	jxVnWfheTvGvBi6pSL4X6TwqY1EP9Y8G65jo9hLCQSvJfwUHxgw	20	41	41	1707908580000	pending
28	3NLRuoCeY8VE1mBaQ9RXpnKGmfnY69sx3SVVntC49Vgw9nahicAi	27	3NKjU5uHZUDoBpaWm6nTYFo6WWvRFQuUmTXFm3TDtkkxCcgVHvC8	12	32	1	1	29	jwe3drXWM5xByAEQoNHnupkJsPUHZBjYCHpWw5586YZXvCXuFNG	21	44	44	1707909120000	pending
29	3NLqj7FU8wquZhZDn5vdKK6TeukoFxbx8BHtFSgynujNJWTpwQ4w	27	3NKjU5uHZUDoBpaWm6nTYFo6WWvRFQuUmTXFm3TDtkkxCcgVHvC8	33	34	1	1	30	jxc3wNj5TwdP28ygbgx4XgzBQNnyBkcnDas76mW9Fu4Aze8QkVv	21	44	44	1707909120000	pending
30	3NLu3EhneKQUqAQQSb1pH1oLNj8RJXcq46ukw1Swr3LpFvZUsEY3	28	3NLRuoCeY8VE1mBaQ9RXpnKGmfnY69sx3SVVntC49Vgw9nahicAi	12	35	1	1	31	jwiWJV8ahrraueeuHqoEkJTYEpcwaeMBMVkUBifuZdGvCjxsweS	22	45	45	1707909300000	pending
31	3NKpMhGhy61hDW857wr5iaTR6uH71pvQ6evgukMvSW9opmmLkhqJ	30	3NLu3EhneKQUqAQQSb1pH1oLNj8RJXcq46ukw1Swr3LpFvZUsEY3	36	37	1	1	32	jwSRsZrowqQYcdYkRDDJuS68sxyGDLc86mtCsLkW5AgjNxoPJrR	23	46	46	1707909480000	pending
32	3NKQfdg8ebZ3a5qdfpq18VY8e9FUsuwfDUPYt9RnhxtL3b4cfqsK	31	3NKpMhGhy61hDW857wr5iaTR6uH71pvQ6evgukMvSW9opmmLkhqJ	38	39	1	1	33	jx3KHyDgtMFE4WrnyANidkx7G5mvSDyNhdbJDrQ7T9qpJbq4ui1	24	50	50	1707910200000	pending
36	3NKZt8xzXFmCiUmQqA2JjkiM3TtPhSTJxUrMzpcw3RRU628FAEUf	34	3NK9kamHqYrb5rgVRsbJppHBf6mEScHp2TRhRZFnureSqm66S3eP	42	43	1	1	37	jxv6g921ix1MencvV2kWnBxsZDjXLsNGrsJMeit95tGp41b7GwX	27	56	56	1707911280000	pending
39	3NL4LKhivi5pywBzBThpgBcrd5mfoTVEyKNVU2LUttiqwJyfBFmg	38	3NLQoeb4vBxChn6HVeg91NXyn1miZMGuKTwSb2VXFwKJpyetVUav	4	5	1	1	40	jx67CMwz9tYUSp31s2cJ1LiXwUbbdDCN4XfNBW4btUvbjNbpLpJ	30	59	59	1707911820000	pending
44	3NK3q35kP4yjPE61K2wBzYHxxx1kExd9dAmeAnA1yBZqLDUft5TC	42	3NLgEs6UXTB935W3odwa71AkuhpPDbMizfWQTdmBuHvmFu79FmtX	50	51	1	1	45	jx53yXc8qCKXDxhnXVLfiTBnfgDk9Z9NrTY2UCpsrEVpHhbN338	34	64	64	1707912720000	pending
45	3NKR1omrbxPzpjnvaJwD9iBPjMrhk5ibVMaWqRejvYNtxVriw8U4	43	3NLwC6s5pZcTpNUt41B5H8uoWhFDaw66psdMkwdDmd2kf6BNjwmM	6	7	1	1	46	jxqaWjhU5LJsS8gzge9WKpmrWvqwjVGJGCv4vbTWKpBtM9saVWC	35	65	65	1707912900000	pending
51	3NKDSb5oPoJeM9hiNMYmGb1MaDFsLukqZDfqaansaJKyVKjiKJeN	50	3NLbi1zx9LJvwDRV2XpDQsLtBr54jFNq6XryiYcbNub5XvGhbfnM	14	15	1	1	52	jww58fbB6msSer7CUmg4dbJzfPPgb4Y2yuNQceFaqX2267JYmVi	39	73	73	1707914340000	pending
33	3NLafPRkZzmDaA85BvWmy7249aFgDwZtq6DvWLrDjz94usF7EDNL	32	3NKQfdg8ebZ3a5qdfpq18VY8e9FUsuwfDUPYt9RnhxtL3b4cfqsK	40	41	1	1	34	jxX1d7utaL3McbbuPgnXWbK1o4BzSAX1EnWCqtpm5WMAvVjs2P2	25	52	52	1707910560000	pending
34	3NK9kamHqYrb5rgVRsbJppHBf6mEScHp2TRhRZFnureSqm66S3eP	33	3NLafPRkZzmDaA85BvWmy7249aFgDwZtq6DvWLrDjz94usF7EDNL	4	5	1	1	35	jxXrSBgqiKxsMjR9EKzJGyd2kKms7hRjdVuR4oG3ArPu7MuCeC8	26	54	54	1707910920000	pending
35	3NLkacZtX6XEmAASVfHfKqsjim8JHwtXqeNJBSyYV6yqvDWNT1PC	34	3NK9kamHqYrb5rgVRsbJppHBf6mEScHp2TRhRZFnureSqm66S3eP	8	9	1	1	36	jxqt2ks5NtKLzmXhL13u57x4EpPVHmQbusVfybc1ARpq7mT8LwS	27	56	56	1707911280000	pending
38	3NLQoeb4vBxChn6HVeg91NXyn1miZMGuKTwSb2VXFwKJpyetVUav	37	3NKEdGTB8mZUVsLDebJVu2DmYKEBcvCDpuwEKSqEeF45GALs6op1	42	43	1	1	39	jw8iekEG93Np1UuiqUJdxhwUgmebBrwpkuqM3d1oYrGNbBqv62i	29	58	58	1707911640000	pending
41	3NKUnCuuc3pYyw2B7BzSmt3LELFBwey85gXNwyMwkxsGSjNSGTon	40	3NKZx9QCfYj9N4aRQAAttM1GV5uya476KSGmoNXMwyfHX9xMn5wc	16	47	1	1	42	jxNM3rCbvWnx1SXETj9TuLm3NCAdJ6gwqz4uNFjp4caTUXNK9zP	32	62	62	1707912360000	pending
42	3NLgEs6UXTB935W3odwa71AkuhpPDbMizfWQTdmBuHvmFu79FmtX	41	3NKUnCuuc3pYyw2B7BzSmt3LELFBwey85gXNwyMwkxsGSjNSGTon	2	3	1	1	43	jwUjB8rueFYx88XQJYWNCrJfEw2uH38bvpyBoUw3qa3Mqmu6sTZ	33	63	63	1707912540000	pending
46	3NLuYnJfanV6UVhNYKnduVhJGfdu7ff4NQAR4rj7YErC6yy2Mjrg	43	3NLwC6s5pZcTpNUt41B5H8uoWhFDaw66psdMkwdDmd2kf6BNjwmM	52	53	1	1	47	jwZQXce7m2VwkAy5XLDY5aDwUaSFCcBzhHtCbbFfHUGX3Rme73R	35	65	65	1707912900000	pending
50	3NLbi1zx9LJvwDRV2XpDQsLtBr54jFNq6XryiYcbNub5XvGhbfnM	48	3NLpBeBxPsWCQGv2zBo9LgHdnYJY8zs4KyDEts6iCvSND28NZhpw	42	43	1	1	51	jwzQMT1wBnexXWc4rpwDQ5HDSsPso4BWma8Bu5pBKQG5V5U2TXW	38	72	72	1707914160000	pending
37	3NKEdGTB8mZUVsLDebJVu2DmYKEBcvCDpuwEKSqEeF45GALs6op1	36	3NKZt8xzXFmCiUmQqA2JjkiM3TtPhSTJxUrMzpcw3RRU628FAEUf	44	45	1	1	38	jwpaVxdugZxURjuBQoDchapxXPE7tHkL2b1jqubMZWtCBzPQLez	28	57	57	1707911460000	pending
40	3NKZx9QCfYj9N4aRQAAttM1GV5uya476KSGmoNXMwyfHX9xMn5wc	39	3NL4LKhivi5pywBzBThpgBcrd5mfoTVEyKNVU2LUttiqwJyfBFmg	22	46	1	1	41	jwtbiLNfxR4C7pcKtMu91ZuDCXnQSg1ApnjypzwfbyM7SNgBJgm	31	61	61	1707912180000	pending
43	3NLwC6s5pZcTpNUt41B5H8uoWhFDaw66psdMkwdDmd2kf6BNjwmM	42	3NLgEs6UXTB935W3odwa71AkuhpPDbMizfWQTdmBuHvmFu79FmtX	48	49	1	1	44	jwaFnMS92PoqCKs7umMUvHUbaHfFDQNGHMfqAmpga8iFwW6DNxV	34	64	64	1707912720000	pending
47	3NLgjrszTVC133BegkzRbYBrM9Y4cBumQA2VoejvTa17iS1MN66K	46	3NLuYnJfanV6UVhNYKnduVhJGfdu7ff4NQAR4rj7YErC6yy2Mjrg	6	7	1	1	48	jxVvkj1Tu1Cs7rQubVnCzTJ2KinLU6BmUvY9RDCfdXXX9aVo6kN	36	67	67	1707913260000	pending
48	3NLpBeBxPsWCQGv2zBo9LgHdnYJY8zs4KyDEts6iCvSND28NZhpw	47	3NLgjrszTVC133BegkzRbYBrM9Y4cBumQA2VoejvTa17iS1MN66K	12	54	1	1	49	jxihigmNNhr2EdRBJsMSHYWTFqJwr5Gcdy6azVfN3J7yUp8gzux	37	69	69	1707913620000	pending
49	3NLLHFtQdTstTrfsEeFLMM1frUQRggBiYdMYRe3PPvXpaASeUFGK	48	3NLpBeBxPsWCQGv2zBo9LgHdnYJY8zs4KyDEts6iCvSND28NZhpw	36	55	1	1	50	jxkPX2jysDzVsry22fyxiTzCNM5KtJvAP1mrkZsyb8zz45ZTrHu	38	72	72	1707914160000	pending
52	3NL45t8ga5iij56xyeLxLDXpvWEiE8jRGZbBnCt9xi2jmbWGaPLk	51	3NKDSb5oPoJeM9hiNMYmGb1MaDFsLukqZDfqaansaJKyVKjiKJeN	2	56	1	1	53	jwr8EfrV3UipYdwvm8YYZ6hCk9fXUN7tzf85vGaXPyjJLe9ciuN	40	74	74	1707914520000	pending
53	3NKG6f2z1uAWgWuYXrzSx3sBAcsAfnDWxM8hfKdGvy8sYwaeDTbs	52	3NL45t8ga5iij56xyeLxLDXpvWEiE8jRGZbBnCt9xi2jmbWGaPLk	27	57	1	1	54	jxXWbyhDYaxFgTtxKQLTJMdr8Fh1bgH22JTjAxE8B3sRbSDAWSy	41	75	75	1707914700000	pending
54	3NLcWVWTMYSQSEr2kRQxNrVTypkkkEx1o9P8qJ2NWfKVpg8oZgZe	53	3NKG6f2z1uAWgWuYXrzSx3sBAcsAfnDWxM8hfKdGvy8sYwaeDTbs	29	30	1	1	55	jxCboEMwUcSzXpDQ9mdh9Gty1nhP2haJNkoHmSrZM52DgotDKYk	42	76	76	1707914880000	pending
55	3NLSDW5RzrDjcH5JYfcTsjq9KUPyR1U64W2TcSqE2C9Xq8LNd4Q3	53	3NKG6f2z1uAWgWuYXrzSx3sBAcsAfnDWxM8hfKdGvy8sYwaeDTbs	58	59	1	1	56	jwzZ7URLzdERpSg3R8zotUsNuAEh2MGBFyqTyZeX9vqaiAqmayX	42	76	76	1707914880000	pending
56	3NLmWF98Es6U8fjokqvMiJL5iYFYzT96Kp3gDJt3vaLVY7nsFt6w	55	3NLSDW5RzrDjcH5JYfcTsjq9KUPyR1U64W2TcSqE2C9Xq8LNd4Q3	2	60	1	1	57	jxV1Hjkfo2gdVpKMUQU2sX6UmJMagNw2L9siZ4aZbWZ58ucMgi9	43	78	78	1707915240000	pending
57	3NKMwkWudUMJFvcvCrnaA5eQtEvLUZhKWE5PenAwLrvpmWEa7Wzz	56	3NLmWF98Es6U8fjokqvMiJL5iYFYzT96Kp3gDJt3vaLVY7nsFt6w	4	5	1	1	58	jxUAkSh5Sv9xWHmnrrRzQ5pBJGDtSXzLvyEWU68NLQPbLDmBVSi	44	80	80	1707915600000	pending
58	3NKMsQ1UUCbZX2xyWoVo9nWE2qPHoy89zJhiMGUuQ9tyhzB1Hf2p	57	3NKMwkWudUMJFvcvCrnaA5eQtEvLUZhKWE5PenAwLrvpmWEa7Wzz	61	62	1	1	59	jxnrbhNP73abtX2uL6MRFiimZi9MarkgUPX1wGfCJMMEUEMkqei	45	81	81	1707915780000	pending
59	3NLi7Ms9koi7uuPdzaNU21E5RnDWz4HseTs2kckNpY8eB5omQXVY	58	3NKMsQ1UUCbZX2xyWoVo9nWE2qPHoy89zJhiMGUuQ9tyhzB1Hf2p	8	9	1	1	60	jwb6CbAHbfxtumwq5C8xEKZ6R44d2KDQj1Nw6zGeaJxu3Mi8AZC	46	82	82	1707915960000	pending
60	3NLmnkWj9FPm6YSMvgUy6ckiguubHXYQn9Kht3zmJvwyex7f8cwW	58	3NKMsQ1UUCbZX2xyWoVo9nWE2qPHoy89zJhiMGUuQ9tyhzB1Hf2p	61	62	1	1	61	jwTSeZfpnXaqsJndvWDJT6DrAKs19QugNokQkh7QSpqZTjAgtGK	46	82	82	1707915960000	pending
61	3NK5QNh2UwcHectf9oR66JyvYkfBYuhtSgvg8oxpqTZBoAXLmSbj	58	3NKMsQ1UUCbZX2xyWoVo9nWE2qPHoy89zJhiMGUuQ9tyhzB1Hf2p	10	63	1	1	62	jw9kALHd2L3JXCYtoUdfxQSTqF9oMYVpKuzkNvG7j618usWDYcw	46	82	82	1707915960000	pending
62	3NL6GsyzbitYg9pUGpGe8na1eeBQKvhMkFFouVLiPXmThD2Yhm38	60	3NLmnkWj9FPm6YSMvgUy6ckiguubHXYQn9Kht3zmJvwyex7f8cwW	20	64	1	1	63	jxLAzZhd9RsL5ZqmEx3ZogUm8kzyKc2qoQUEpCroKrydVgzQWg1	47	83	83	1707916140000	pending
63	3NL8HuRdsb4TFYp9wyzKhHcLU9dUhzysktkNXsg7XqfUzgzksQxG	62	3NL6GsyzbitYg9pUGpGe8na1eeBQKvhMkFFouVLiPXmThD2Yhm38	65	66	1	1	64	jxZobFZuBT5gWGMVUWAYsDBGhzcr5ybddyCoVNvXxY9TxVDfGMH	48	85	85	1707916500000	pending
64	3NKmZcqsL95AbFU6ixPmW3xbNEXbuFaC7ctSdFKnprvUCAhgLLSR	63	3NL8HuRdsb4TFYp9wyzKhHcLU9dUhzysktkNXsg7XqfUzgzksQxG	12	67	1	1	65	jx7NxjG5TrQo9PT3QiC8ArWnJYf6hMZ1t4iTQSrNiqVjna7hTov	49	86	86	1707916680000	pending
65	3NKHq5oUuW3ZU4SHFFxJ9urAT8HP6SDXwoCrVLPMc8tPQdXpZDha	64	3NKmZcqsL95AbFU6ixPmW3xbNEXbuFaC7ctSdFKnprvUCAhgLLSR	6	7	1	1	66	jxZGep3F1EzRncygQGUMzLBWktXihCdWEGLewdg6VDXcTXYd596	50	87	87	1707916860000	pending
66	3NKiS3cmzEqx5X49ZD2cB334rt32mN471LE2DAS9MzS1GUZ5jrpe	64	3NKmZcqsL95AbFU6ixPmW3xbNEXbuFaC7ctSdFKnprvUCAhgLLSR	12	68	1	1	67	jwyE5XRKXFGQB4RMVm3mBEMGKpahbfhbSVW3JeDa8vDcTuNiUbB	50	87	87	1707916860000	pending
\.


--
-- Data for Name: blocks_internal_commands; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.blocks_internal_commands (block_id, internal_command_id, sequence_no, secondary_sequence_no, receiver_account_creation_fee_paid, receiver_balance) FROM stdin;
2	1	0	0	\N	1
3	2	0	0	\N	2
4	3	0	0	\N	3
5	4	0	0	\N	4
6	5	0	0	\N	5
7	6	0	0	\N	6
8	7	0	0	\N	7
9	8	0	0	\N	8
10	2	0	0	\N	9
11	9	0	0	\N	10
12	10	0	0	\N	11
13	3	0	0	\N	12
14	4	0	0	\N	13
15	11	0	0	\N	14
16	2	0	0	\N	15
17	10	0	0	\N	16
18	2	0	0	\N	17
19	12	0	0	\N	18
20	13	0	0	\N	19
21	1	0	0	\N	20
22	2	0	0	\N	21
23	14	0	0	\N	22
24	1	0	0	\N	23
25	10	0	0	\N	24
26	1	0	0	\N	25
27	6	0	0	\N	26
28	6	0	0	\N	27
29	15	0	0	\N	28
30	6	0	0	\N	29
31	16	0	0	\N	30
32	17	0	0	\N	31
33	18	0	0	\N	32
34	2	0	0	\N	33
35	4	0	0	\N	34
36	19	0	0	\N	35
37	20	0	0	\N	36
38	19	0	0	\N	37
39	2	0	0	\N	38
40	11	0	0	\N	39
41	8	0	0	\N	40
42	1	0	0	\N	41
43	21	0	0	\N	42
44	22	0	0	\N	43
45	3	0	0	\N	44
46	23	0	0	\N	45
47	3	0	0	\N	46
48	6	0	0	\N	47
49	16	0	0	\N	48
50	19	0	0	\N	49
51	7	0	0	\N	50
52	1	0	0	\N	51
53	13	0	0	\N	52
54	14	0	0	\N	53
55	24	0	0	\N	54
56	25	0	0	\N	55
57	2	0	0	\N	56
58	26	0	0	\N	57
59	4	0	0	\N	58
60	26	0	0	\N	59
61	5	0	0	\N	60
62	10	0	0	\N	61
63	27	0	0	\N	62
64	6	0	0	\N	63
65	3	0	0	\N	64
66	6	0	0	\N	65
\.


--
-- Data for Name: blocks_user_commands; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.blocks_user_commands (block_id, user_command_id, sequence_no, status, failure_reason, fee_payer_account_creation_fee_paid, receiver_account_creation_fee_paid, created_token, fee_payer_balance, source_balance, receiver_balance) FROM stdin;
\.


--
-- Data for Name: epoch_data; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.epoch_data (id, seed, ledger_hash_id) FROM stdin;
1	2vbZRewiphtua2p2cv6gTuvG3a4pa9HeCZHECNmZSzLrvswaxNjq	2
2	2vazaUGDJarTM4pAnDnSHUnNt8nmXiJLeZmdkvHyR7Jpes8K1cyx	3
3	2va9jg5EY7y2Lkyg9HfmDngTShgwLopDEhtVNkesKYbe8zDsF8JL	3
4	2vabr2yVUPkUzbWiWDeqjD1rL41mJwPjchidQdZkKFdiceBDYUzp	3
5	2vbM8sxvaXsWYVWhiVwqK1SJbkQsgDrToGP6NM1Qs5BzwCVTzthP	3
6	2vbhBsMXpCUh7FFoooj6BZR9ETXe6V4nh2TtjknUbMwAMqqGhT2Q	3
7	2vbNQouqyEKe5pfM69CHjeVrVc9DR5qBoGYYvB17yP3tKk7Vi8s7	3
8	2vaCFzLwzXNjfJpdGLt8pT6v4HQ9Mk3vdZG7xmMi6teiWorN5Py7	3
9	2vaGEq8wQvRA6vSPUUrqhTb7vid7uJX4yMmK2rDXKpBofj9Bc8HF	3
10	2varT4HmidgTKAF3xeep1WHMJGnxEn3XQR7pEUi2DQVS28kDhatD	3
11	2vaCucA2SoZqxRFt6chQGj23bTxq8QNcDaqLy83oi1qD8mAXjGfD	3
12	2vbhsiUquC53hspVZArC5ikE8FkpzPdxcPxmQpSQjUiTQxJ667Fn	3
13	2vbo92MqLxmWJYcreRvKx12NK3Yv1hPMWCoUbHq4rFnHKdXEuyEv	3
14	2vbTLoWNK7sV9TUvSyrotUybwYvSNSyaYSnKQt1Cjwbs5s927JXq	3
15	2vb5r9f87UxQNgJ4tYLSCaznTGVSYqtijcpCtobKke8N52nMBAEs	3
16	2vayiL7ZVs5eT4KDdcwUCSwxPYtGf1pBDJJCitf7HcveHwhqT3RQ	3
17	2vabhLVFPKdUmsxuUnEfCaViGmEuK7B8DuecZ5443spCk8voU1iK	3
18	2vbXHHpnW7RXwnK3oSR2z7K19nFTyJpsJLDeWfda14py92hD5j73	3
19	2vbFeJTXqTRLMcmDZgpcXHaJ1Sgb4cGNMBmoEMjfmSqFZM8dTkJB	3
20	2vaSUsj9unHvwia39z7NizCQZHTvGFLZLoyB4BHqGwAarJuccY4R	3
21	2vbh3C2psRu42pC9UuVeD7TsP7RJEAt4AaeSnt34jekG17yZQTo9	3
22	2vbTW8VBNJmvc4GxADSArp72L9TYLhQY3CYaLr8AbXtt33uiFSVH	3
23	2varFuSijsjA2QE4gx3zLNe8Few2XSTAPZjitnkdgnZ5n8qpwNyr	3
24	2vbZtGftRd5pTAvXAeB4ZieFHfPmAMadC3RotpXLPPez8B4EnWPa	3
25	2vbeMVHbuiwpGVvBKkhqXbVahjgu7Nv1xEBRj3YtZeagqBnkUZuu	3
26	2vbxJ1imfs9QDShGXDcJqnHM9McwANxiC3c2aWURzf7U8AvkD9m5	3
27	2vbGdG7E2DnYNRpehmrJCHwE6GLdWSAJFpsnqrUXVLEW7FGLuhsT	3
28	2vbns8qk7kCvywdSL6EWkFwqNnoLUTVoY15fAQFpHT4ADV2SZfno	3
29	2vb4xr8uFytEYusnmsg2T72z8CgHmGZch2VausxzWGUsMYc3L7kp	3
30	2vagDkHY99t3qZT5e2qccXK1zV8gVrXz9bNepQoWvuWMTaogAbJ7	3
31	2vaeZoXnDm3a9dYNa3ehHtTAXU5e3NzbvBupSnuw9zfp4gL32YEj	3
32	2vbZSahLZnBLFVAphWBbmfZS7FGVgpLj2zbrwFxuGsMZKw8VaZpC	3
33	2vaXipSoU4ncjbAGFMxuMRqb8MuKwVhwSSumzZ9dzhg2yofi7PSs	3
34	2vaKhhVSuZ8zC7gXfZABK5g2i4w4JFu7PjbTn8JqkUrwaXAbwaW1	3
35	2vbrztGJ4vi2iCnx2KF7trJuWxDGP1ZRX9GCW1MgiiYb6e4yH7uH	3
36	2vaTG7HbsfVCw3BPtV62NSunoavHzVQ99ECBAEZZ8fBXv58dVT6J	3
37	2vbPZbxPA2SMCYkqrCtGrEL2aU2Mssow2ZwKUY87TFmSW9BBj4FS	3
38	2vaQnBvBJN8LVRDDkSBYYw4iJawPfXN6RdTB2VytrkGWAobQjgc2	3
39	2vb8jbHRXuqmjaUC5jAimJrVdso74UHVbkUxk3wsxuAXh1pew6V8	3
40	2vbuoeekRjZAQr1U583UoxKte8XFgAARX6FCEYNbuNm5JtUUytEy	3
41	2vaD9SQygK2wmoFiFMmgMQni4hA97dnSagyLkXbRkV6cMud4RrQc	3
42	2vbs6TToXU3dFgXWD1FdjMWeV3oBfX5Cib45HM1MQEqvkSrZEFZW	3
43	2vb2Qp6WuUn8dj5161dkZnbR2JPwa74fpzK8svT3V3VyKdbvBf9f	3
44	2vbeSpDnHUzbTqMN69mzXTGYgK8mLsMTufRrSWfwk66oKdQYPEBt	3
45	2vb9q7s6yFTt5TETDtBvU93S8PwhCc3AddysNMqNbydFfFvgD4zh	3
46	2vc5LxKkymbhQ12jHZsbi3z3HPscwunE51WAttnreaYzLkqtjiXY	3
47	2vbAVq4V56omdjk2r79o1HMbiUVkeik4yMCjkJ7MjWpodymHbCSD	3
48	2vbRKUrV4bFv2qLYLN6cQepybL8oPSissd2ZBQjqq27oozgi7v7L	3
49	2vbUKuhZKhpqvYWa1r9hJT7kaS81CDDY4Zy6MMAbMJYHAmKMpHnd	3
50	2vbUMNzhyo5MSBE7Rcgfm9Q9GLttZLhjZnZ2MFNtUaGv8Ld4E2tk	3
51	2vbo6xzta5FdEktwJ2CxokVindwD9UcLndik127fLiYJFhr1LsC2	3
52	2vapjFyLrmMWHMRXyV8MBrT9JtwoPJacDtAARBW4ymM61mQuHjob	3
53	2vaxhhBvodrcwjXZQAFYCxHchq7PtJpuTfHzmALH1aDEgLMYjcfP	3
54	2vaqvqmy4dPYvgECgH5uqFnQ52ixSVKkqnXUicthYgirKdtnUGve	3
55	2vbd3zzQhpXWBE2qcnBPaeEn1FUDsRsaAzwTaDJRpkVw6Y5WB44y	3
56	2vaZHvhW5FALTzFgKPGv2gTnffMbp9VE87VBbkBaNRyPnYf1VQrZ	3
57	2vamSTbfBWQB3ozbJomS5mH4mzcYxiXe3RtzJS8d4CSaHAjq6Npc	3
58	2vb1dSereWEnF6cPFW9rMV9piAoXgYupPYMoKzXuCQ56HNFGfeg8	3
59	2vaVSekyMx88Qf3By3tWEnZcuyaxPL9Pz59RK45Ua9EmMQQt4MyJ	3
60	2vbvsm3CoLSbSi3DNNAymRrXQ6PGgzKXZTpkVeQWjjrZWErHtvK6	3
61	2vaTXzuKognsnBfGTWAkNh8tS3VQdPvjkstLghygivFBarFxYTbJ	3
62	2vas8Gpn2eiZEmYoRR9iwhMEtxQ9MJtXzic6B9w49CefJAoGBTjk	3
63	2vaz7w9Dks6aigQoQbHoBd1c7ZZ1FVitBFDWVFEDJPmYDHhCoi4W	3
64	2vbEuR1oumTZ1Wfn6hYQmo3aHe7Qw7JC3mZqeR8pX2zJUQgVso92	3
65	2vbDwi8fhCouvH6Jc25PnXDsstDTEumYxpJaohjtQWnGn1QR1gmb	3
66	2vaRUKAQJZaQwLr7Q44wKDDutAnV4b7pdCpBxxLeV2G8gTxqyJaq	3
67	2vc1FJ17dpSt3yyoYEGyGvNnrwwycmu7eQoJjx2CRogGx4Cpcgys	3
\.


--
-- Data for Name: internal_commands; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.internal_commands (id, type, receiver_id, fee, token, hash) FROM stdin;
1	coinbase	2	1440000000000	1	CkpZrsYiG1JEjea3q6TCtEW7orM5dEvPot2ZtBy8ScwwjfvMG1grw
2	coinbase	4	1440000000000	1	CkpYQFP1ARUumPnxi18LWd8qPrk2LpP3Qf7t4dDjPPnURq5FV7Mng
3	coinbase	6	1440000000000	1	CkpZeh5PH8ECebRKbRrhV7VJSZHvcmrwT8eYnddWyFAF5WEAv58xk
4	coinbase	8	1440000000000	1	CkpYukKz9PJPtkecvYnHGpT8uqnS5SqNsufTmziGcr9JEGgpCUmfh
5	coinbase	10	1440000000000	1	CkpaGMqd3EVhejVy4a9yQQMrTZJUJgPp4mUJRiFNpjgAyM5wGYzcb
6	coinbase	12	1440000000000	1	CkpZVA78HXJN5rbAv9MPfeZEJRkQM1GYvA5SmeN5HbCuy8wzHt7q3
7	coinbase	14	1440000000000	1	CkpYQXddffkcN6xw3Hgkc9MgsiLyoBENRx6Woaa5EmG7gZQYRuAAA
8	coinbase	16	1440000000000	1	CkpZQTggceX6GW2tpZV6gDJD1BdbYuFRm9Dj6Qkx8ukPt3i8jf31P
9	coinbase	18	720000000000	1	CkpZ2KHHHFKg8zrQTF8ppjf4WWyZUq6Cxq9dX1yLLq5YoST9pKe4d
10	coinbase	20	1440000000000	1	CkpZJwmdAaWWSDaKwBbXwd31U1u394HVTfcQ8GDKiyge9XeRfWsF4
11	coinbase	22	1440000000000	1	CkpZYYTnXsJhbCJz2L9hX35DCSqUKbrbfqsyWJeYVg2phVRCNnjqU
12	coinbase	25	1440000000000	1	CkpYchK9XAS5rweqUSqLhdmtN7k9qcZ94rd2S3ECC8qN2amtYuUid
13	coinbase	27	1440000000000	1	CkpYXXJEJCh8M2QebzfLCqjVLZqPTZ9Y8Ad1fosAKTRdQifGM1BaR
14	coinbase	29	1440000000000	1	CkpZCmYXqgEtGoEWv7FeFCAfox6YjfzP36MjstGRVmBDUyNyeCdkd
15	coinbase	33	1440000000000	1	CkpZsebfABJxSf736G6bEMAVLPsDSZWGHPJPpeffUzyPfvL8GH3PK
16	coinbase	36	1440000000000	1	CkpZb3KSRXaLNpCoRSJEDr1VJg1TvZF1uzRBJN8AnRX15pfYi1DKf
17	coinbase	38	1440000000000	1	CkpYnyvvozmU4SapujSFPKCFafCtrpbxWXBTg6Q2sdR7KnNERneCh
18	coinbase	40	1440000000000	1	CkpYpdnWA93oMpnyqVhrjxsp9874FLp8Jzqhq69rwhmYxGke3UgFW
19	coinbase	42	1440000000000	1	CkpZbPgpsbWpe3dfacnBptXSzKBqVb6t4QYVf1ZQcxLsdC9t2eKNo
20	coinbase	44	1440000000000	1	CkpZ26ze1PtE15a2iFmFYqpNH6CYYJtbAo3EqmqyFqS791HfXVBp9
21	coinbase	48	1440000000000	1	CkpZyfJ9doWsUhNFDTvQP58McUdWe97jb8T7vjaytvCGKrpmTUw9T
22	coinbase	50	1440000000000	1	CkpZDd8iNHqimfQ1UQmtXF8Z53Y53eLbQCAXiiirm3ceFZYUs9doX
23	coinbase	52	1440000000000	1	CkpaApkgLdoWZco7sW4Jahc4SV5tTQ6o5QSZN3XPrx62DLHZsMtC5
24	coinbase	58	1440000000000	1	CkpYX7TduVbxXVEoeH47TJhAaAMSVvDmjwxvdnpLqFhhsvovCsGTp
25	coinbase	2	720000000000	1	CkpYupRzHMyDUQPbWYPrKA11oKh7UawHmegxABkgHw2Rbo2y9jsZx
26	coinbase	61	1440000000000	1	CkpZArGBYW4NW4td1ESD7DWxuw35iJWXpZu3CHjFsatHvXWujB7sQ
27	coinbase	65	1440000000000	1	CkpZ5Wyhni6hsQFHosi7m211T2waUgtrkSysF5vwMPFgu5dyB86Qb
\.


--
-- Data for Name: public_keys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.public_keys (id, value) FROM stdin;
1	B62qiy32p8kAKnny8ZFwoMhYpBppM1DWVCqAPBYNcXnsAHhnfAAuXgg
2	B62qqMeuttmgECAQBJndssX93nfvXgP5cLyUcLrnHawus26vvA3snGw
3	B62qpWaQoQoPL5AGta7Hz2DgJ9CJonpunjzCGTdw8KiCCD1hX8fNHuR
4	B62qkasW9RRENzCzdEov1PRQ63BUT2VQK9iU7imcvbPLThnhL2eYMz8
5	B62qrQKS9ghd91shs73TCmBJRW9GzvTJK443DPx2YbqcyoLc56g1ny9
6	B62qp3x5osG6Fz6j44FVn61E4DNpAnyDEMcoQdNQZAdhaR7sj4wZ6gW
7	B62qjsFTBw4TVwRRxNVrmwJfQqXfmMC4DVa2moCe9f8ErvBYd6f7npr
8	B62qox2Knqg9JE5L6AvW1Jdo7KxhpdckP5JqnmzApSZKfmQ4w3egx5E
9	B62qmjZSQHakvWz7ZMkaaVW7ye1BpxdYABAMoiGk3u9bBaLmK5DJPkR
10	B62qnZ5yFb5W6oS6vFTjMXsvJZVJcRNCj5Uetip4cGXiWvuFvgMA9jJ
11	B62qpDWPWYVt7oJTHFME19ic3iFWrZJcEvuLFWHdSSnkrMiQUDZtySU
12	B62qne3xzC9vnqFvuxvrEy1izWStUWH2W5XvjTi1X5SPqA9Q1psvxDR
13	B62qpys9mNtovWH6poMys3ZKx5U41kHY3XKjhrebXzDSnzKYPwNxyfr
14	B62qn8WCvanEBBxXf5iMmi3rFLVxUPrXDXtHaPuZ2fD7KsX3KogzTXs
15	B62qp3LaAUKQ76DdFYaQ7bj46HDTgpCaFpwhDqbjNJUC79Rf6x8CxV3
16	B62qrbbFv3AfMTFxyrmAUVSzLEi2z6zQYw3sryH39auu4gZ8mHoWQF7
17	B62qmPc8Ziq7txW48YPf4qtavcD5mcQVjEAGo9LEZD8DeaNsNthYLsz
18	B62qmATfKHQWCNoGafsmURNmDbaQd2prUNLQeF3G9J1jz2EbAwp2AeA
19	B62qpdXgX5zgSthWWNGHieRp9oP5R18GS52mfFsCz83tUrb6YgMVQ9B
20	B62qptU47zPwn1v4UgQxwWXKzo5XS7T6iHyw5pgbu2XMg8dSEHaQYv6
21	B62qit2ZgSSFCzMg8CYwjiwNNDEE4SDZ8KiwfVYi5JvzMUN5ZdigdpA
22	B62qqXshwY9aM8urjru3iBWkj9A7Rd5ShwUS4fctv1Zcexse1XWJygV
23	B62qnNh1rEy8tfTHn8pCHsaZ55Gw3Naopm4ixmhKSQ6pwKwasaFxKwA
24	B62qqhTWoZineudzfT9o4YTdruHTps1yANJz9z1Zw3YnFAMgCky8LFS
25	B62qkBXo5ryWAYrfJRoSWnEVnQbSJgSsykdZo39u6duhe5b3ULADDAZ
26	B62qqxj2zxFXDXuBjnuXPt7Q5vz2D5Mh2K3DBPJs6ytq2TPjoU1i314
27	B62qmjPc8CArNpd9zCTgBv84q9YBf14c5ndjCw1gV1ERQ8Bo7pen1JR
28	B62qk85NRZ8sFbWJCYJd1uSX812c52eaTCeVMVL6h2BeGJCTbaX8SVq
29	B62qpUPm7jdsBavcVxdMRtTbcGE6iHE262SV3TVYYTrxjiWsEW6Uipn
30	B62qpFsgpv6ZgXvxWMNW89aBzT9vBXXXN1qxadsD539BkDwUEpPdN8R
31	B62qpDpnXsUFR4TmaUYaBqcCUV1L1wsdsCcb7iRrvzJcU3ehiiUyoJd
32	B62qj8jYSfyMGMkXXBsVBTTsT1qQYHH7z9nCoC2iYanNbmeuUk85gvA
33	B62qqPA5gep2zMFm2UgvK4AapdoBkgWDkn2yToSJFUHzhXeBNuSbUfZ
34	B62qnPAWJBxFVPTyFGpgVi3WLDGFnqnZovgCMU9noiCzuDEnckH18ZA
35	B62qq2MQiFHN9LJFLP2jm3fsAMUyveVRzKVG7mbBzmv6vu5XTB2WLtP
36	B62qnJPv9zyDVyZ98Nxpc6E6BBy1uhTuMecoWR8od4uNgtM1QDeAwRf
37	B62qrkBdswQNacU2hZ4ZYYiNSMcheC8QYc18dCipGrH9Cc7AK5e9yeB
38	B62qoHx3f2gjbqPhb1MYpE3LaevRBrgrswJoD7R1Umd7dVMMFb9RSgb
39	B62qm2hqYFLcx2vxrPR1szE7dBq1AY1aoiKKz4wbbpC8JW4YQM7p8Ge
40	B62qr1CyqBwyCSqFuHWJqvqsdRyRatJ56SDU1smpnb5rddAeXSUVMhh
41	B62qqWE1BK7bVmtpkgvbF5628TeP7WPZNoG3XjhAGudss2j7xznwRrA
42	B62qqkf42MvXQM96mgL11kwrKcNfdknzcjKf4awPMJHW22BEk83cP32
43	B62qruRRvyNbEZdoMmxY9xWzG8DnGqqmSuZSBnCwRLeiZVVn9yDg9LU
44	B62qrUn6pswR1C52xXSWdhJwYRGP4CCWCqWSJ2keTtJ8swVqM4UvkZS
45	B62qnLJ9rfmzF7Zc3jh6rUaBnArdr9BGERrAXvm9XG5fUHu5MyHrRR8
46	B62qmjnKZ8h8Yi26rKxrSu8Nd4xh9DN7gh8foZu3cWkUnBEMzh99HHQ
47	B62qqfXNFw8SHRFrTrRq4gpJt4rnFHaXcvEi6LGDSU2KjXhqzwJ53Mh
48	B62qmwgmbc1RCLk6G7g1NuvTWC85KJ3MP7mSywnxRB6pa4XGzd15U3B
49	B62qrEEjPjUoSQcfVQkF3vmY4Mo8zbRPiGxVBzXKLgRFxoe6ZugzK5e
50	B62qnQBWr7DLpTm1bdowsMNCAQpnfXz3W2yHNvKRYq1ADQwZrm1UqW9
51	B62qqxTbSmuwZu1hxfs6hSXo7LC7XXsqV5DWNDmyMSPitPFeTAntMza
52	B62qs1Zwz7J5e7uWqeZHFGnCz2itQCudFJmPM4C2Knq1Rjbn41QvEry
53	B62qmi1c1MDXFJno8SJZpujg3a1V1zdT7bHCFDGK4pLn9tYih7516ai
54	B62qrGMSb1qzXQ152HsfbKKH9n9FtqACe9J8aAG9L5GtKQABLFGWRYr
55	B62qk2MCHXm4CBBfbY3gPGBo6zbtY7sxyDAaNMRU71dS5DdYg8nu42m
56	B62qjTcgNDXgsEsnHAGXmAnZe8F2V5a9rz9SGs9fLtaPznjfnfAe39t
57	B62qoYYwFnx3ZwGQGq5PQRbrejJKh9j3YB5yKGrgN3thV8HZFP8c9AN
58	B62qmQaca42Kpi6VUEnWigxpAYB7qZL6f27YMRYzmHFrwj3Rmb9N9jD
59	B62qnvgqc3mB3r4oDqqKxHUo4SuSWawANUyjyTygt3k4WgxYBmjYZ5q
60	B62qiUsYoPyakMZx3yPJisMgz1DpbsW34u7XbYrhw2dQ64rjp3CH5hH
61	B62qoZNKxuqTfrgzd2LWnUQfJ8hovVg1hBzoxDGUZj3Ts9WgZgJaZ5X
62	B62qkRodi7nj6W1geB12UuW2XAx2yidWZCcDthJvkf9G4A6G5GFasVQ
63	B62qmWZ9QM5G5wLWW6AUup3L6LuiwSefmYQxdEefS9Gzcd7kL8zeV4H
64	B62qrC2c4BGbUPfbqLfHveXMgw8XLfSsLNgCog198mZZ7Fj6QCyQyvY
65	B62qrofDVYXWdMhLUQF5fKL7y56XJzExR2xzoyPzDkn2Ad9rNvNJVnH
66	B62qiburnzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzmp7r7UN6X
67	B62qn4JwEhmf2gFAATufLE6PXgkF7PGGK6DjQfyReToky8ePDUhiZVH
68	B62qmdJ5AAnaWhuHMAYTQV1dKPMZ6xtuHhrrxv1BZum3MHQtfb3ASdY
\.


--
-- Data for Name: snarked_ledger_hashes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.snarked_ledger_hashes (id, value) FROM stdin;
1	jxZZMTrP6Bc2y9vN69hsgWL5t5yqtnrULikgox5brC1LNFh6YLq
2	jw7rzuH4kXDyWbiEvuwXJRzG7Z2CXdBFHbMoqzbAmTUWCJKUUaz
3	jxatRXuFWozZqn4T1dhBFZFL7vQhW7Ph7BSdJ82QTtfAdG7P2Y3
\.


--
-- Data for Name: timing_info; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.timing_info (id, public_key_id, token, initial_balance, initial_minimum_balance, cliff_time, cliff_amount, vesting_period, vesting_increment) FROM stdin;
\.


--
-- Data for Name: user_commands; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_commands (id, type, fee_payer_id, source_id, receiver_id, fee_token, token, nonce, amount, fee, valid_until, memo, hash) FROM stdin;
\.


--
-- Name: balances_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.balances_id_seq', 65, true);


--
-- Name: blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.blocks_id_seq', 66, true);


--
-- Name: epoch_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.epoch_data_id_seq', 67, true);


--
-- Name: internal_commands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.internal_commands_id_seq', 27, true);


--
-- Name: public_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.public_keys_id_seq', 68, true);


--
-- Name: snarked_ledger_hashes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.snarked_ledger_hashes_id_seq', 3, true);


--
-- Name: timing_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.timing_info_id_seq', 1, false);


--
-- Name: user_commands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_commands_id_seq', 1, false);


--
-- Name: balances balances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.balances
    ADD CONSTRAINT balances_pkey PRIMARY KEY (id);


--
-- Name: balances balances_public_key_id_balance_block_id_block_height_block__key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.balances
    ADD CONSTRAINT balances_public_key_id_balance_block_id_block_height_block__key UNIQUE (public_key_id, balance, block_id, block_height, block_sequence_no, block_secondary_sequence_no);


--
-- Name: blocks_internal_commands blocks_internal_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks_internal_commands
    ADD CONSTRAINT blocks_internal_commands_pkey PRIMARY KEY (block_id, internal_command_id, sequence_no, secondary_sequence_no);


--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (id);


--
-- Name: blocks blocks_state_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_state_hash_key UNIQUE (state_hash);


--
-- Name: blocks_user_commands blocks_user_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks_user_commands
    ADD CONSTRAINT blocks_user_commands_pkey PRIMARY KEY (block_id, user_command_id, sequence_no);


--
-- Name: epoch_data epoch_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.epoch_data
    ADD CONSTRAINT epoch_data_pkey PRIMARY KEY (id);


--
-- Name: internal_commands internal_commands_hash_type_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_commands
    ADD CONSTRAINT internal_commands_hash_type_key UNIQUE (hash, type);


--
-- Name: internal_commands internal_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_commands
    ADD CONSTRAINT internal_commands_pkey PRIMARY KEY (id);


--
-- Name: public_keys public_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_keys
    ADD CONSTRAINT public_keys_pkey PRIMARY KEY (id);


--
-- Name: public_keys public_keys_value_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.public_keys
    ADD CONSTRAINT public_keys_value_key UNIQUE (value);


--
-- Name: snarked_ledger_hashes snarked_ledger_hashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snarked_ledger_hashes
    ADD CONSTRAINT snarked_ledger_hashes_pkey PRIMARY KEY (id);


--
-- Name: snarked_ledger_hashes snarked_ledger_hashes_value_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.snarked_ledger_hashes
    ADD CONSTRAINT snarked_ledger_hashes_value_key UNIQUE (value);


--
-- Name: timing_info timing_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timing_info
    ADD CONSTRAINT timing_info_pkey PRIMARY KEY (id);


--
-- Name: user_commands user_commands_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_commands
    ADD CONSTRAINT user_commands_hash_key UNIQUE (hash);


--
-- Name: user_commands user_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_commands
    ADD CONSTRAINT user_commands_pkey PRIMARY KEY (id);


--
-- Name: idx_balances_height_seq_nos; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_balances_height_seq_nos ON public.balances USING btree (block_height, block_sequence_no, block_secondary_sequence_no);


--
-- Name: idx_balances_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_balances_id ON public.balances USING btree (id);


--
-- Name: idx_balances_public_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_balances_public_key_id ON public.balances USING btree (public_key_id);


--
-- Name: idx_blocks_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_creator_id ON public.blocks USING btree (creator_id);


--
-- Name: idx_blocks_height; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_height ON public.blocks USING btree (height);


--
-- Name: idx_blocks_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_id ON public.blocks USING btree (id);


--
-- Name: idx_blocks_internal_commands_block_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_internal_commands_block_id ON public.blocks_internal_commands USING btree (block_id);


--
-- Name: idx_blocks_internal_commands_internal_command_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_internal_commands_internal_command_id ON public.blocks_internal_commands USING btree (internal_command_id);


--
-- Name: idx_blocks_internal_commands_receiver_balance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_internal_commands_receiver_balance ON public.blocks_internal_commands USING btree (receiver_balance);


--
-- Name: idx_blocks_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_parent_id ON public.blocks USING btree (parent_id);


--
-- Name: idx_blocks_state_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_state_hash ON public.blocks USING btree (state_hash);


--
-- Name: idx_blocks_user_commands_block_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_user_commands_block_id ON public.blocks_user_commands USING btree (block_id);


--
-- Name: idx_blocks_user_commands_fee_payer_balance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_user_commands_fee_payer_balance ON public.blocks_user_commands USING btree (fee_payer_balance);


--
-- Name: idx_blocks_user_commands_receiver_balance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_user_commands_receiver_balance ON public.blocks_user_commands USING btree (receiver_balance);


--
-- Name: idx_blocks_user_commands_source_balance; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_user_commands_source_balance ON public.blocks_user_commands USING btree (source_balance);


--
-- Name: idx_blocks_user_commands_user_command_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_blocks_user_commands_user_command_id ON public.blocks_user_commands USING btree (user_command_id);


--
-- Name: idx_chain_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_chain_status ON public.blocks USING btree (chain_status);


--
-- Name: idx_public_key_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_public_key_id ON public.timing_info USING btree (public_key_id);


--
-- Name: idx_public_keys_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_public_keys_id ON public.public_keys USING btree (id);


--
-- Name: idx_public_keys_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_public_keys_value ON public.public_keys USING btree (value);


--
-- Name: idx_snarked_ledger_hashes_value; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_snarked_ledger_hashes_value ON public.snarked_ledger_hashes USING btree (value);


--
-- Name: balances balances_block_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.balances
    ADD CONSTRAINT balances_block_id_fkey FOREIGN KEY (block_id) REFERENCES public.blocks(id) ON DELETE CASCADE;


--
-- Name: balances balances_public_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.balances
    ADD CONSTRAINT balances_public_key_id_fkey FOREIGN KEY (public_key_id) REFERENCES public.public_keys(id);


--
-- Name: blocks blocks_block_winner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_block_winner_id_fkey FOREIGN KEY (block_winner_id) REFERENCES public.public_keys(id);


--
-- Name: blocks blocks_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.public_keys(id);


--
-- Name: blocks_internal_commands blocks_internal_commands_block_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks_internal_commands
    ADD CONSTRAINT blocks_internal_commands_block_id_fkey FOREIGN KEY (block_id) REFERENCES public.blocks(id) ON DELETE CASCADE;


--
-- Name: blocks_internal_commands blocks_internal_commands_internal_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks_internal_commands
    ADD CONSTRAINT blocks_internal_commands_internal_command_id_fkey FOREIGN KEY (internal_command_id) REFERENCES public.internal_commands(id) ON DELETE CASCADE;


--
-- Name: blocks_internal_commands blocks_internal_commands_receiver_balance_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks_internal_commands
    ADD CONSTRAINT blocks_internal_commands_receiver_balance_fkey FOREIGN KEY (receiver_balance) REFERENCES public.balances(id) ON DELETE CASCADE;


--
-- Name: blocks blocks_next_epoch_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_next_epoch_data_id_fkey FOREIGN KEY (next_epoch_data_id) REFERENCES public.epoch_data(id);


--
-- Name: blocks blocks_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.blocks(id);


--
-- Name: blocks blocks_snarked_ledger_hash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_snarked_ledger_hash_id_fkey FOREIGN KEY (snarked_ledger_hash_id) REFERENCES public.snarked_ledger_hashes(id);


--
-- Name: blocks blocks_staking_epoch_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_staking_epoch_data_id_fkey FOREIGN KEY (staking_epoch_data_id) REFERENCES public.epoch_data(id);


--
-- Name: blocks_user_commands blocks_user_commands_block_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks_user_commands
    ADD CONSTRAINT blocks_user_commands_block_id_fkey FOREIGN KEY (block_id) REFERENCES public.blocks(id) ON DELETE CASCADE;


--
-- Name: blocks_user_commands blocks_user_commands_fee_payer_balance_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks_user_commands
    ADD CONSTRAINT blocks_user_commands_fee_payer_balance_fkey FOREIGN KEY (fee_payer_balance) REFERENCES public.balances(id) ON DELETE CASCADE;


--
-- Name: blocks_user_commands blocks_user_commands_receiver_balance_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks_user_commands
    ADD CONSTRAINT blocks_user_commands_receiver_balance_fkey FOREIGN KEY (receiver_balance) REFERENCES public.balances(id) ON DELETE CASCADE;


--
-- Name: blocks_user_commands blocks_user_commands_source_balance_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks_user_commands
    ADD CONSTRAINT blocks_user_commands_source_balance_fkey FOREIGN KEY (source_balance) REFERENCES public.balances(id) ON DELETE CASCADE;


--
-- Name: blocks_user_commands blocks_user_commands_user_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blocks_user_commands
    ADD CONSTRAINT blocks_user_commands_user_command_id_fkey FOREIGN KEY (user_command_id) REFERENCES public.user_commands(id) ON DELETE CASCADE;


--
-- Name: epoch_data epoch_data_ledger_hash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.epoch_data
    ADD CONSTRAINT epoch_data_ledger_hash_id_fkey FOREIGN KEY (ledger_hash_id) REFERENCES public.snarked_ledger_hashes(id);


--
-- Name: internal_commands internal_commands_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.internal_commands
    ADD CONSTRAINT internal_commands_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.public_keys(id);


--
-- Name: timing_info timing_info_public_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.timing_info
    ADD CONSTRAINT timing_info_public_key_id_fkey FOREIGN KEY (public_key_id) REFERENCES public.public_keys(id);


--
-- Name: user_commands user_commands_fee_payer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_commands
    ADD CONSTRAINT user_commands_fee_payer_id_fkey FOREIGN KEY (fee_payer_id) REFERENCES public.public_keys(id);


--
-- Name: user_commands user_commands_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_commands
    ADD CONSTRAINT user_commands_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.public_keys(id);


--
-- Name: user_commands user_commands_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_commands
    ADD CONSTRAINT user_commands_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.public_keys(id);


--
-- PostgreSQL database dump complete
--

