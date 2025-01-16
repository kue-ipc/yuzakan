--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)

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
-- Name: activity_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_logs (
    id integer NOT NULL,
    uuid text NOT NULL,
    client text NOT NULL,
    username text,
    action text NOT NULL,
    method text NOT NULL,
    path text NOT NULL,
    status integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: activity_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.activity_logs ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.activity_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: adapter_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adapter_params (
    id integer NOT NULL,
    provider_id integer NOT NULL,
    name text NOT NULL,
    value bytea NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: adapter_params_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.adapter_params ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.adapter_params_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: attr_mappings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attr_mappings (
    id integer NOT NULL,
    provider_id integer NOT NULL,
    attr_id integer NOT NULL,
    key text NOT NULL,
    conversion text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: attr_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.attr_mappings ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.attr_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: attrs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.attrs (
    id integer NOT NULL,
    name text NOT NULL,
    display_name text,
    description text,
    category text NOT NULL,
    type text NOT NULL,
    "order" integer NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    readonly boolean DEFAULT false NOT NULL,
    code text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: attrs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.attrs ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.attrs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: auth_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_logs (
    id integer NOT NULL,
    uuid text NOT NULL,
    client text NOT NULL,
    username text NOT NULL,
    result text NOT NULL,
    code text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: auth_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.auth_logs ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: configs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configs (
    id integer NOT NULL,
    title text NOT NULL,
    domain text,
    session_timeout integer DEFAULT 3600 NOT NULL,
    password_min_size integer DEFAULT 8,
    password_max_size integer DEFAULT 64 NOT NULL,
    password_min_types integer DEFAULT 1 NOT NULL,
    password_min_score integer DEFAULT 3 NOT NULL,
    password_unusable_chars text DEFAULT ''::text NOT NULL,
    password_extra_dict text DEFAULT ''::text NOT NULL,
    generate_password_size integer DEFAULT 24 NOT NULL,
    generate_password_type text DEFAULT 'ascii'::text NOT NULL,
    generate_password_chars text DEFAULT ' '::text NOT NULL,
    contact_name text,
    contact_email text,
    contact_phone text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: configs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.configs ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    name text NOT NULL,
    display_name text,
    note text,
    "primary" boolean DEFAULT false NOT NULL,
    prohibited boolean DEFAULT false NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.groups ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: local_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_groups (
    id integer NOT NULL,
    name text NOT NULL,
    display_name text,
    attrs jsonb NOT NULL
);


--
-- Name: local_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.local_groups ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.local_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: local_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_members (
    id integer NOT NULL,
    local_user_id integer NOT NULL,
    local_group_id integer NOT NULL
);


--
-- Name: local_members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.local_members ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.local_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: local_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.local_users (
    id integer NOT NULL,
    name text NOT NULL,
    hashed_password text,
    display_name text,
    email text,
    locked boolean DEFAULT false NOT NULL,
    attrs jsonb NOT NULL,
    local_group_id integer
);


--
-- Name: local_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.local_users ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.local_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.members (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL,
    "primary" boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: members_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.members ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: networks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.networks (
    id integer NOT NULL,
    address text NOT NULL,
    clearance_level integer DEFAULT 1 NOT NULL,
    trusted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: networks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.networks ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.networks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: providers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.providers (
    id integer NOT NULL,
    name text NOT NULL,
    display_name text,
    description text,
    adapter text NOT NULL,
    "order" integer NOT NULL,
    readable boolean DEFAULT false NOT NULL,
    writable boolean DEFAULT false NOT NULL,
    authenticatable boolean DEFAULT false NOT NULL,
    password_changeable boolean DEFAULT false NOT NULL,
    lockable boolean DEFAULT false NOT NULL,
    "group" boolean DEFAULT false NOT NULL,
    individual_password boolean DEFAULT false NOT NULL,
    self_management boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: providers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.providers ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    filename text NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name text NOT NULL,
    display_name text,
    email text,
    note text,
    clearance_level integer DEFAULT 1 NOT NULL,
    prohibited boolean DEFAULT false NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.users ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: activity_logs activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT activity_logs_pkey PRIMARY KEY (id);


--
-- Name: adapter_params adapter_params_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adapter_params
    ADD CONSTRAINT adapter_params_pkey PRIMARY KEY (id);


--
-- Name: attr_mappings attr_mappings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attr_mappings
    ADD CONSTRAINT attr_mappings_pkey PRIMARY KEY (id);


--
-- Name: attrs attrs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attrs
    ADD CONSTRAINT attrs_pkey PRIMARY KEY (id);


--
-- Name: auth_logs auth_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_logs
    ADD CONSTRAINT auth_logs_pkey PRIMARY KEY (id);


--
-- Name: configs configs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configs
    ADD CONSTRAINT configs_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: local_groups local_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_groups
    ADD CONSTRAINT local_groups_pkey PRIMARY KEY (id);


--
-- Name: local_members local_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_members
    ADD CONSTRAINT local_members_pkey PRIMARY KEY (id);


--
-- Name: local_users local_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_users
    ADD CONSTRAINT local_users_pkey PRIMARY KEY (id);


--
-- Name: members members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);


--
-- Name: networks networks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.networks
    ADD CONSTRAINT networks_pkey PRIMARY KEY (id);


--
-- Name: providers providers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.providers
    ADD CONSTRAINT providers_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: activity_logs_client_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_logs_client_index ON public.activity_logs USING btree (client);


--
-- Name: activity_logs_username_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_logs_username_index ON public.activity_logs USING btree (username);


--
-- Name: activity_logs_uuid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX activity_logs_uuid_index ON public.activity_logs USING btree (uuid);


--
-- Name: adapter_params_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adapter_params_name_index ON public.adapter_params USING btree (name);


--
-- Name: adapter_params_provider_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX adapter_params_provider_id_index ON public.adapter_params USING btree (provider_id);


--
-- Name: adapter_params_provider_id_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX adapter_params_provider_id_name_index ON public.adapter_params USING btree (provider_id, name);


--
-- Name: attr_mappings_attr_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attr_mappings_attr_id_index ON public.attr_mappings USING btree (attr_id);


--
-- Name: attr_mappings_provider_id_attr_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX attr_mappings_provider_id_attr_id_index ON public.attr_mappings USING btree (provider_id, attr_id);


--
-- Name: attr_mappings_provider_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attr_mappings_provider_id_index ON public.attr_mappings USING btree (provider_id);


--
-- Name: attrs_category_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attrs_category_index ON public.attrs USING btree (category);


--
-- Name: attrs_name_category_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX attrs_name_category_index ON public.attrs USING btree (name, category);


--
-- Name: attrs_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX attrs_name_index ON public.attrs USING btree (name);


--
-- Name: auth_logs_client_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_logs_client_index ON public.auth_logs USING btree (client);


--
-- Name: auth_logs_username_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_logs_username_index ON public.auth_logs USING btree (username);


--
-- Name: auth_logs_uuid_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_logs_uuid_index ON public.auth_logs USING btree (uuid);


--
-- Name: groups_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX groups_name_index ON public.groups USING btree (name);


--
-- Name: local_groups_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX local_groups_name_index ON public.local_groups USING btree (name);


--
-- Name: local_members_local_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX local_members_local_group_id_index ON public.local_members USING btree (local_group_id);


--
-- Name: local_members_local_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX local_members_local_user_id_index ON public.local_members USING btree (local_user_id);


--
-- Name: local_members_local_user_id_local_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX local_members_local_user_id_local_group_id_index ON public.local_members USING btree (local_user_id, local_group_id);


--
-- Name: local_users_local_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX local_users_local_group_id_index ON public.local_users USING btree (local_group_id);


--
-- Name: local_users_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX local_users_name_index ON public.local_users USING btree (name);


--
-- Name: members_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX members_group_id_index ON public.members USING btree (group_id);


--
-- Name: members_user_id_group_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX members_user_id_group_id_index ON public.members USING btree (user_id, group_id);


--
-- Name: members_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX members_user_id_index ON public.members USING btree (user_id);


--
-- Name: networks_address_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX networks_address_index ON public.networks USING btree (address);


--
-- Name: providers_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX providers_name_index ON public.providers USING btree (name);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_name_index ON public.users USING btree (name);


--
-- Name: adapter_params adapter_params_provider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adapter_params
    ADD CONSTRAINT adapter_params_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES public.providers(id) ON DELETE CASCADE;


--
-- Name: attr_mappings attr_mappings_attr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attr_mappings
    ADD CONSTRAINT attr_mappings_attr_id_fkey FOREIGN KEY (attr_id) REFERENCES public.attrs(id) ON DELETE CASCADE;


--
-- Name: attr_mappings attr_mappings_provider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.attr_mappings
    ADD CONSTRAINT attr_mappings_provider_id_fkey FOREIGN KEY (provider_id) REFERENCES public.providers(id) ON DELETE CASCADE;


--
-- Name: local_members local_members_local_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_members
    ADD CONSTRAINT local_members_local_group_id_fkey FOREIGN KEY (local_group_id) REFERENCES public.local_groups(id) ON DELETE CASCADE;


--
-- Name: local_members local_members_local_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_members
    ADD CONSTRAINT local_members_local_user_id_fkey FOREIGN KEY (local_user_id) REFERENCES public.local_users(id) ON DELETE CASCADE;


--
-- Name: local_users local_users_local_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.local_users
    ADD CONSTRAINT local_users_local_group_id_fkey FOREIGN KEY (local_group_id) REFERENCES public.local_groups(id) ON DELETE SET NULL;


--
-- Name: members members_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: members members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.members
    ADD CONSTRAINT members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (filename) VALUES
('10000001000001_create_configs.rb'),
('10000001000002_create_networks.rb'),
('10000002000001_create_users.rb'),
('10000002000002_create_groups.rb'),
('10000002000003_create_members.rb'),
('10000003000001_create_providers.rb'),
('10000003000002_create_adapter_params.rb'),
('10000004000001_create_attrs.rb'),
('10000004000002_create_attr_mappings.rb'),
('10000005000001_create_activity_logs.rb'),
('10000005000002_create_auth_logs.rb'),
('10000011000001_create_local_users.rb'),
('10000011000002_create_local_groups.rb'),
('10000011000003_create_local_members.rb'),
('10000011000004_add_local_group_id_to_local_users.rb');
