-- SOURCE: apps/control-plane-api/src/db/migrations/0001-baseline.ts

CREATE FUNCTION af_current_organization() RETURNS text LANGUAGE sql STABLE AS
$$ SELECT nullif(current_setting('app.organization_id', true), '') $$;

CREATE FUNCTION af_json_valid(value text) RETURNS boolean LANGUAGE plpgsql IMMUTABLE AS $$
BEGIN
  PERFORM value::jsonb;
  RETURN true;
EXCEPTION WHEN others THEN
  RETURN false;
END $$;

CREATE FUNCTION af_now_iso() RETURNS text LANGUAGE sql VOLATILE AS
$$ SELECT to_char(clock_timestamp() AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') $$;

-- Raises its first trigger argument: append-only and immutable tables.
CREATE FUNCTION af_reject() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION '%', TG_ARGV[0];
END $$;

-- Tenants -------------------------------------------------------------------------------------
CREATE TABLE organizations (
 id text PRIMARY KEY,
 name text NOT NULL,
 slug text NOT NULL UNIQUE,
 legal_name text NOT NULL DEFAULT '',
 code text,
 website text NOT NULL DEFAULT '',
 industry text NOT NULL DEFAULT '',
 country text NOT NULL DEFAULT '',
 timezone text NOT NULL DEFAULT 'UTC',
 locale text NOT NULL DEFAULT 'en',
 status text NOT NULL DEFAULT 'active' CHECK(status IN ('active','suspended','disabled')),
 version bigint NOT NULL DEFAULT 1,
 created_at text,
 updated_at text,
 updated_by text
);
CREATE UNIQUE INDEX organization_code_unique ON organizations(lower(code));
CREATE FUNCTION organization_profile_defaults() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.code := coalesce(NEW.code, upper(NEW.slug));
  NEW.created_at := coalesce(NEW.created_at, af_now_iso());
  NEW.updated_at := coalesce(NEW.updated_at, af_now_iso());
  RETURN NEW;
END $$;
CREATE TRIGGER organization_profile_defaults BEFORE INSERT ON organizations
 FOR EACH ROW EXECUTE FUNCTION organization_profile_defaults();

-- Users are global authentication principals. Employment and access are tenant-owned.
CREATE TABLE users (
 id text PRIMARY KEY,
 email text NOT NULL,
 display_name text NOT NULL,
 status text NOT NULL DEFAULT 'active' CHECK(status IN ('active','disabled')),
 created_at text NOT NULL
);
CREATE UNIQUE INDEX users_email_unique ON users(lower(email));

CREATE TABLE employees (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 display_name text NOT NULL,
 email text NOT NULL,
 role text NOT NULL,
 team text NOT NULL,
 user_id text REFERENCES users(id),
 employee_number text,
 employment_type text NOT NULL DEFAULT 'employee' CHECK(employment_type IN ('employee','contractor','external')),
 employment_status text NOT NULL DEFAULT 'active' CHECK(employment_status IN ('active','inactive')),
 version bigint NOT NULL DEFAULT 1
);
CREATE UNIQUE INDEX employees_tenant_id ON employees(organization_id,id);
CREATE UNIQUE INDEX employee_email_per_tenant ON employees(organization_id,lower(email));
CREATE UNIQUE INDEX employee_user_per_tenant ON employees(organization_id,user_id) WHERE user_id IS NOT NULL;
CREATE UNIQUE INDEX employee_number_per_tenant ON employees(organization_id,employee_number) WHERE employee_number IS NOT NULL;
CREATE UNIQUE INDEX employee_user_tenant_link ON employees(organization_id,id,user_id);

CREATE TABLE organization_memberships (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 user_id text NOT NULL REFERENCES users(id),
 employee_id text NOT NULL,
 security_role text NOT NULL CHECK(security_role IN ('ADMIN','EMPLOYEE')),
 membership_status text NOT NULL CHECK(membership_status IN ('pending','active','suspended')),
 version bigint NOT NULL DEFAULT 1,
 joined_at text NOT NULL,
 updated_at text NOT NULL,
 invited_by text,
 UNIQUE(organization_id,user_id), UNIQUE(organization_id,employee_id),
 FOREIGN KEY(organization_id,employee_id,user_id) REFERENCES employees(organization_id,id,user_id)
);
CREATE INDEX memberships_user_status ON organization_memberships(user_id,membership_status);

-- Sign-in (platform scope only) ---------------------------------------------------------------
CREATE TABLE identities (
 issuer text NOT NULL,
 subject text NOT NULL,
 employee_id text NOT NULL REFERENCES employees(id),
 enabled bigint NOT NULL,
 user_id text REFERENCES users(id),
 PRIMARY KEY (issuer, subject)
);
CREATE FUNCTION identity_user_check() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.user_id IS NULL OR NOT EXISTS(SELECT 1 FROM employees WHERE id=NEW.employee_id AND user_id=NEW.user_id) THEN
    RAISE EXCEPTION 'IDENTITY_USER_MISMATCH';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER identity_user_insert BEFORE INSERT ON identities
 FOR EACH ROW EXECUTE FUNCTION identity_user_check();
CREATE TRIGGER identity_user_update BEFORE UPDATE OF user_id,employee_id ON identities
 FOR EACH ROW EXECUTE FUNCTION identity_user_check();

CREATE TABLE login_transactions (hash text PRIMARY KEY, body text NOT NULL, expires_at bigint NOT NULL);
CREATE TABLE password_credentials (
 issuer text NOT NULL, subject text NOT NULL, hash text NOT NULL,
 PRIMARY KEY (issuer, subject), FOREIGN KEY (issuer, subject) REFERENCES identities(issuer, subject)
);
CREATE TABLE account_password_credentials (
 user_id text PRIMARY KEY REFERENCES users(id),
 hash text NOT NULL,
 updated_at text NOT NULL
);
CREATE TABLE auth_sessions (
 hash text PRIMARY KEY, issuer text NOT NULL, subject text NOT NULL, expires_at bigint NOT NULL,
 user_id text REFERENCES users(id), organization_id text REFERENCES organizations(id)
);
CREATE INDEX account_sessions_by_user ON auth_sessions(user_id,organization_id);
CREATE TABLE invitations (
 hash text PRIMARY KEY, employee_id text NOT NULL REFERENCES employees(id),
 expires_at bigint NOT NULL, consumed bigint NOT NULL
);
CREATE TABLE password_resets (
 hash text PRIMARY KEY, employee_id text NOT NULL REFERENCES employees(id),
 expires_at bigint NOT NULL, consumed bigint NOT NULL
);
CREATE TABLE account_link_invitations (
 hash text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 employee_id text NOT NULL,
 user_id text NOT NULL REFERENCES users(id),
 expires_at bigint NOT NULL,
 consumed bigint NOT NULL DEFAULT 0 CHECK(consumed IN (0,1)),
 invited_by text,
 FOREIGN KEY(organization_id,employee_id,user_id) REFERENCES employees(organization_id,id,user_id),
 FOREIGN KEY(organization_id,invited_by) REFERENCES employees(organization_id,id)
);
CREATE INDEX account_link_pending ON account_link_invitations(organization_id,employee_id,consumed);

-- Agents, conversations and approvals -----------------------------------------------------------
CREATE TABLE catalog_blueprint_versions (
 blueprint_id text NOT NULL,
 version text NOT NULL,
 digest text NOT NULL CHECK(length(digest)=64),
 content text NOT NULL CHECK(af_json_valid(content)),
 registered_at text NOT NULL,
 PRIMARY KEY(blueprint_id,version)
);
CREATE TRIGGER catalog_versions_no_update BEFORE UPDATE ON catalog_blueprint_versions
 FOR EACH ROW EXECUTE FUNCTION af_reject('CATALOG_VERSION_IMMUTABLE');
CREATE TRIGGER catalog_versions_no_delete BEFORE DELETE ON catalog_blueprint_versions
 FOR EACH ROW EXECUTE FUNCTION af_reject('CATALOG_VERSION_IMMUTABLE');

CREATE TABLE organization_agent_installations (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 name text NOT NULL CHECK(length(name) BETWEEN 1 AND 120),
 blueprint_id text NOT NULL,
 blueprint_version text NOT NULL,
 configuration text NOT NULL CHECK(af_json_valid(configuration)),
 status text NOT NULL CHECK(status IN ('ACTIVE','RETIRED')),
 version bigint NOT NULL DEFAULT 1 CHECK(version>0),
 created_by text NOT NULL,
 created_at text NOT NULL,
 updated_by text NOT NULL,
 updated_at text NOT NULL,
 UNIQUE(organization_id,id),
 FOREIGN KEY(blueprint_id,blueprint_version) REFERENCES catalog_blueprint_versions(blueprint_id,version),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
);
CREATE UNIQUE INDEX installation_active_name ON organization_agent_installations(organization_id,lower(name))
 WHERE status='ACTIVE';
CREATE TRIGGER installation_identity_immutable BEFORE UPDATE OF id,organization_id,blueprint_id,created_by,created_at
 ON organization_agent_installations FOR EACH ROW EXECUTE FUNCTION af_reject('INSTALLATION_IDENTITY_IMMUTABLE');
CREATE TRIGGER installation_retired_final BEFORE UPDATE ON organization_agent_installations
 FOR EACH ROW WHEN (OLD.status='RETIRED') EXECUTE FUNCTION af_reject('INSTALLATION_RETIRED');
CREATE TRIGGER installation_no_delete BEFORE DELETE ON organization_agent_installations
 FOR EACH ROW EXECUTE FUNCTION af_reject('INSTALLATION_HISTORY_RETAINED');

CREATE TABLE agents (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 name text NOT NULL,
 department text NOT NULL,
 team text NOT NULL,
 status text NOT NULL,
 capabilities text NOT NULL,
 installation_id text,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE
);
CREATE UNIQUE INDEX agents_tenant_id ON agents(organization_id,id);
CREATE INDEX agents_installation ON agents(organization_id,installation_id) WHERE installation_id IS NOT NULL;
CREATE FUNCTION agents_installation_scope() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM organization_agent_installations WHERE id=NEW.installation_id
      AND organization_id=NEW.organization_id AND status='ACTIVE') THEN
    RAISE EXCEPTION 'INSTALLATION_SCOPE_MISMATCH';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER agents_installation_scope BEFORE INSERT ON agents
 FOR EACH ROW WHEN (NEW.installation_id IS NOT NULL) EXECUTE FUNCTION agents_installation_scope();
CREATE TRIGGER agents_installation_immutable BEFORE UPDATE OF installation_id ON agents
 FOR EACH ROW EXECUTE FUNCTION af_reject('AGENT_INSTALLATION_IMMUTABLE');

CREATE TABLE agent_manifests (
 agent_id text PRIMARY KEY REFERENCES agents(id),
 organization_id text NOT NULL REFERENCES organizations(id),
 employee_id text NOT NULL REFERENCES employees(id),
 body text NOT NULL
);
CREATE TABLE agent_assignments (
 agent_id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 created_by text NOT NULL,
 created_at text NOT NULL,
 FOREIGN KEY (organization_id, agent_id) REFERENCES agents(organization_id, id),
 FOREIGN KEY (organization_id, created_by) REFERENCES employees(organization_id, id)
);
CREATE TABLE admin_agent_batches (
 organization_id text NOT NULL REFERENCES organizations(id),
 request_id text NOT NULL, body_hash text NOT NULL, result text NOT NULL,
 PRIMARY KEY (organization_id, request_id)
);
CREATE TABLE provisioning_requests (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 employee_id text NOT NULL REFERENCES employees(id),
 body text NOT NULL,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE
);

CREATE TABLE conversations (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 employee_id text NOT NULL REFERENCES employees(id),
 agent_id text NOT NULL REFERENCES agents(id),
 title text NOT NULL, created_at text NOT NULL, updated_at text NOT NULL
);
CREATE INDEX idx_conversations_employee ON conversations(employee_id, updated_at);
CREATE UNIQUE INDEX conversations_tenant_id ON conversations(organization_id,id);
CREATE TABLE messages (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 conversation_id text NOT NULL,
 author text NOT NULL,
 content text NOT NULL,
 created_at text NOT NULL,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 FOREIGN KEY (organization_id, conversation_id) REFERENCES conversations(organization_id, id)
);
CREATE INDEX messages_conversation ON messages(organization_id, conversation_id, created_at);

CREATE TABLE approvals (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 requested_by text NOT NULL,
 action text NOT NULL, resource_type text NOT NULL, resource_id text NOT NULL,
 risk text NOT NULL, summary text NOT NULL, status text NOT NULL,
 decided_by text, decided_at text, created_at text NOT NULL,
 run_id text, step_id text, expires_at text,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE
);
CREATE INDEX idx_approvals_status ON approvals(status, created_at);
CREATE INDEX approvals_run ON approvals(organization_id,run_id) WHERE run_id IS NOT NULL;
CREATE INDEX approvals_expiry ON approvals(status,expires_at) WHERE expires_at IS NOT NULL;
CREATE TABLE qa_runs (
 id text PRIMARY KEY,
 organization_id text NOT NULL,
 employee_id text NOT NULL,
 conversation_id text NOT NULL REFERENCES conversations(id),
 story_key text NOT NULL, target_url text NOT NULL,
 status text NOT NULL, plan text NOT NULL,
 approval_id text NOT NULL UNIQUE REFERENCES approvals(id),
 created_at text NOT NULL
);
CREATE TABLE llm_key_bindings (
 id text PRIMARY KEY, organization_id text NOT NULL, employee_id text,
 provider text NOT NULL, key_source text NOT NULL, secret_ref text NOT NULL,
 created_at text NOT NULL,
 CHECK (length(secret_ref) > 0)
);
CREATE TABLE audit_events (
 id text PRIMARY KEY, organization_id text NOT NULL, actor_id text NOT NULL,
 event_type text NOT NULL, resource_type text NOT NULL, resource_id text NOT NULL,
 metadata text NOT NULL, created_at text NOT NULL,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE
);
CREATE INDEX idx_audit_resource ON audit_events(resource_type, resource_id);
CREATE INDEX audit_events_tenant ON audit_events(organization_id, seq);

-- Organization structure --------------------------------------------------------------------------
CREATE TABLE organizational_units (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 parent_id text,
 name text NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 160),
 code text NOT NULL CHECK(length(code) BETWEEN 1 AND 40),
 unit_type text NOT NULL CHECK(unit_type IN ('business_unit','division','department','sub_department','team','squad','pod','chapter','guild','other')),
 description text NOT NULL DEFAULT '',
 status text NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived')),
 version bigint NOT NULL DEFAULT 1,
 created_at text NOT NULL,
 updated_at text NOT NULL,
 created_by text NOT NULL,
 updated_by text NOT NULL,
 head_position_id text,
 UNIQUE(organization_id,id),
 UNIQUE(organization_id,code),
 FOREIGN KEY(organization_id,parent_id) REFERENCES organizational_units(organization_id,id),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id),
 CHECK(parent_id IS NULL OR parent_id <> id)
);
CREATE INDEX units_parent ON organizational_units(organization_id,parent_id,status);
CREATE INDEX units_name ON organizational_units(organization_id,status,name,id);
CREATE UNIQUE INDEX one_unit_per_head_position ON organizational_units(organization_id,head_position_id) WHERE head_position_id IS NOT NULL;

CREATE TABLE organization_change_events (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 actor_id text NOT NULL,
 action text NOT NULL,
 resource_type text NOT NULL,
 resource_id text NOT NULL,
 before_json text,
 after_json text,
 request_id text NOT NULL,
 created_at text NOT NULL,
 FOREIGN KEY(organization_id,actor_id) REFERENCES employees(organization_id,id)
);
CREATE INDEX organization_changes_time ON organization_change_events(organization_id,created_at,id);
CREATE TRIGGER organization_changes_no_update BEFORE UPDATE ON organization_change_events
 FOR EACH ROW EXECUTE FUNCTION af_reject('AUDIT_IMMUTABLE');
CREATE TRIGGER organization_changes_no_delete BEFORE DELETE ON organization_change_events
 FOR EACH ROW EXECUTE FUNCTION af_reject('AUDIT_IMMUTABLE');

CREATE TABLE job_families (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 name text NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 160),
 code text NOT NULL CHECK(length(code) BETWEEN 1 AND 40),
 description text NOT NULL DEFAULT '',
 status text NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived')),
 version bigint NOT NULL DEFAULT 1,
 created_at text NOT NULL, updated_at text NOT NULL,
 created_by text NOT NULL, updated_by text NOT NULL,
 UNIQUE(organization_id,id), UNIQUE(organization_id,code),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
);
CREATE TABLE job_disciplines (
 job_family_id text NOT NULL,
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 name text NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 160),
 code text NOT NULL CHECK(length(code) BETWEEN 1 AND 40),
 description text NOT NULL DEFAULT '',
 status text NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived')),
 version bigint NOT NULL DEFAULT 1,
 created_at text NOT NULL, updated_at text NOT NULL,
 created_by text NOT NULL, updated_by text NOT NULL,
 UNIQUE(organization_id,id), UNIQUE(organization_id,code),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,job_family_id) REFERENCES job_families(organization_id,id)
);
CREATE INDEX disciplines_family ON job_disciplines(organization_id,job_family_id,status);
CREATE TABLE roles (
 job_family_id text NOT NULL,
 discipline_id text NOT NULL,
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 name text NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 160),
 code text NOT NULL CHECK(length(code) BETWEEN 1 AND 40),
 description text NOT NULL DEFAULT '',
 status text NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived')),
 version bigint NOT NULL DEFAULT 1,
 created_at text NOT NULL, updated_at text NOT NULL,
 created_by text NOT NULL, updated_by text NOT NULL,
 UNIQUE(organization_id,id), UNIQUE(organization_id,code),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,job_family_id) REFERENCES job_families(organization_id,id),
 FOREIGN KEY(organization_id,discipline_id) REFERENCES job_disciplines(organization_id,id)
);
CREATE INDEX roles_discipline ON roles(organization_id,discipline_id,status);
CREATE TABLE job_levels (
 rank bigint NOT NULL CHECK(rank>=0),
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 name text NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 160),
 code text NOT NULL CHECK(length(code) BETWEEN 1 AND 40),
 description text NOT NULL DEFAULT '',
 status text NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived')),
 version bigint NOT NULL DEFAULT 1,
 created_at text NOT NULL, updated_at text NOT NULL,
 created_by text NOT NULL, updated_by text NOT NULL,
 UNIQUE(organization_id,id), UNIQUE(organization_id,code),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
);
CREATE TABLE positions (
 organizational_unit_id text NOT NULL,
 role_id text NOT NULL,
 job_level_id text NOT NULL,
 reports_to_position_id text,
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 name text NOT NULL CHECK(length(trim(name)) BETWEEN 1 AND 160),
 code text NOT NULL CHECK(length(code) BETWEEN 1 AND 40),
 description text NOT NULL DEFAULT '',
 status text NOT NULL DEFAULT 'active' CHECK(status IN ('active','archived')),
 version bigint NOT NULL DEFAULT 1,
 created_at text NOT NULL, updated_at text NOT NULL,
 created_by text NOT NULL, updated_by text NOT NULL,
 UNIQUE(organization_id,id), UNIQUE(organization_id,code),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,organizational_unit_id) REFERENCES organizational_units(organization_id,id),
 FOREIGN KEY(organization_id,role_id) REFERENCES roles(organization_id,id),
 FOREIGN KEY(organization_id,job_level_id) REFERENCES job_levels(organization_id,id),
 FOREIGN KEY(organization_id,reports_to_position_id) REFERENCES positions(organization_id,id),
 CHECK(reports_to_position_id IS NULL OR reports_to_position_id<>id)
);
CREATE INDEX positions_unit ON positions(organization_id,organizational_unit_id,status);
CREATE INDEX positions_role ON positions(organization_id,role_id,status);
ALTER TABLE organizational_units ADD FOREIGN KEY (head_position_id) REFERENCES positions(id);

CREATE TABLE organizational_unit_memberships (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 organizational_unit_id text NOT NULL,
 employee_id text NOT NULL,
 membership_type text NOT NULL CHECK(membership_type IN ('member','lead','manager','owner','contributor')),
 is_primary bigint NOT NULL DEFAULT 0 CHECK(is_primary IN (0,1)),
 created_at text NOT NULL,
 created_by text NOT NULL,
 started_at text NOT NULL,
 ended_at text,
 version bigint NOT NULL DEFAULT 1,
 FOREIGN KEY(organization_id,organizational_unit_id) REFERENCES organizational_units(organization_id,id),
 FOREIGN KEY(organization_id,employee_id) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 CHECK(ended_at IS NULL OR ended_at>=started_at)
);
CREATE UNIQUE INDEX current_unit_member ON organizational_unit_memberships(organization_id,organizational_unit_id,employee_id) WHERE ended_at IS NULL;
CREATE UNIQUE INDEX one_primary_unit ON organizational_unit_memberships(organization_id,employee_id) WHERE is_primary=1 AND ended_at IS NULL;
CREATE INDEX unit_membership_history ON organizational_unit_memberships(organization_id,organizational_unit_id,ended_at,started_at);

CREATE TABLE organization_domains (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 domain text NOT NULL,
 domain_type text NOT NULL CHECK(domain_type IN ('custom_domain','platform_subdomain','internal')),
 is_primary bigint NOT NULL DEFAULT 0 CHECK(is_primary IN (0,1)),
 verification_status text NOT NULL DEFAULT 'pending' CHECK(verification_status IN ('pending','verified','disabled')),
 verification_token text NOT NULL,
 verified_at text,
 created_at text NOT NULL, updated_at text NOT NULL,
 created_by text NOT NULL,
 version bigint NOT NULL DEFAULT 1,
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 CHECK(is_primary=0 OR verification_status='verified')
);
CREATE UNIQUE INDEX organization_domain_unique ON organization_domains(lower(domain));
CREATE UNIQUE INDEX primary_domain_per_tenant ON organization_domains(organization_id) WHERE is_primary=1;
CREATE INDEX domain_tenant ON organization_domains(organization_id,verification_status);

CREATE TABLE employee_position_assignments (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 employee_id text NOT NULL,
 position_id text NOT NULL,
 started_at text NOT NULL, ended_at text,
 created_by text NOT NULL,
 FOREIGN KEY(organization_id,employee_id) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,position_id) REFERENCES positions(organization_id,id),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id)
);
CREATE UNIQUE INDEX employee_current_position ON employee_position_assignments(organization_id,employee_id) WHERE ended_at IS NULL;
CREATE UNIQUE INDEX position_current_occupant ON employee_position_assignments(organization_id,position_id) WHERE ended_at IS NULL;

CREATE FUNCTION units_no_cycle() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.parent_id IN (
    WITH RECURSIVE descendants(id) AS (
      SELECT OLD.id UNION SELECT u.id FROM organizational_units u JOIN descendants d ON u.parent_id=d.id
      WHERE u.organization_id=OLD.organization_id
    ) SELECT id FROM descendants) THEN
    RAISE EXCEPTION 'HIERARCHY_CYCLE';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER units_no_cycle BEFORE UPDATE OF parent_id ON organizational_units
 FOR EACH ROW WHEN (NEW.parent_id IS NOT NULL) EXECUTE FUNCTION units_no_cycle();
CREATE FUNCTION units_active_parent() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM organizational_units WHERE id=NEW.parent_id
      AND organization_id=NEW.organization_id AND status='active') THEN
    RAISE EXCEPTION 'PARENT_INACTIVE';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER units_active_parent_insert BEFORE INSERT ON organizational_units
 FOR EACH ROW WHEN (NEW.parent_id IS NOT NULL) EXECUTE FUNCTION units_active_parent();
CREATE TRIGGER units_active_parent_update BEFORE UPDATE ON organizational_units
 FOR EACH ROW WHEN (NEW.status='active' AND NEW.parent_id IS NOT NULL) EXECUTE FUNCTION units_active_parent();
-- One function keeps SQLite's order of checks: children, positions, then members.
CREATE FUNCTION units_archive() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM organizational_units WHERE parent_id=OLD.id
      AND organization_id=OLD.organization_id AND status='active') THEN
    RAISE EXCEPTION 'UNIT_HAS_CHILDREN';
  END IF;
  IF EXISTS (SELECT 1 FROM positions WHERE organization_id=OLD.organization_id
      AND organizational_unit_id=OLD.id AND status='active') THEN
    RAISE EXCEPTION 'UNIT_HAS_CHILDREN';
  END IF;
  IF EXISTS (SELECT 1 FROM organizational_unit_memberships WHERE organizational_unit_id=OLD.id
      AND organization_id=OLD.organization_id AND ended_at IS NULL) THEN
    RAISE EXCEPTION 'UNIT_HAS_MEMBERS';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER units_archive BEFORE UPDATE OF status ON organizational_units
 FOR EACH ROW WHEN (NEW.status='archived') EXECUTE FUNCTION units_archive();
CREATE FUNCTION unit_head_check() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM positions WHERE id=NEW.head_position_id AND organization_id=NEW.organization_id
      AND organizational_unit_id=NEW.id AND status='active') THEN
    RAISE EXCEPTION 'INVALID_HEAD_POSITION';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER unit_head_insert BEFORE INSERT ON organizational_units
 FOR EACH ROW WHEN (NEW.head_position_id IS NOT NULL) EXECUTE FUNCTION unit_head_check();
CREATE TRIGGER unit_head_update BEFORE UPDATE OF head_position_id,organization_id ON organizational_units
 FOR EACH ROW WHEN (NEW.head_position_id IS NOT NULL) EXECUTE FUNCTION unit_head_check();

CREATE FUNCTION position_no_cycle() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.reports_to_position_id IN (
    WITH RECURSIVE descendants(id) AS (
      SELECT OLD.id UNION SELECT p.id FROM positions p JOIN descendants d ON p.reports_to_position_id=d.id
      WHERE p.organization_id=OLD.organization_id
    ) SELECT id FROM descendants) THEN
    RAISE EXCEPTION 'HIERARCHY_CYCLE';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER position_no_cycle BEFORE UPDATE OF reports_to_position_id ON positions
 FOR EACH ROW WHEN (NEW.reports_to_position_id IS NOT NULL) EXECUTE FUNCTION position_no_cycle();
CREATE FUNCTION occupied_position_archive() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS(SELECT 1 FROM employee_position_assignments WHERE organization_id=OLD.organization_id
      AND position_id=OLD.id AND ended_at IS NULL) THEN
    RAISE EXCEPTION 'POSITION_OCCUPIED';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER occupied_position_archive BEFORE UPDATE OF status ON positions
 FOR EACH ROW WHEN (NEW.status='archived') EXECUTE FUNCTION occupied_position_archive();
CREATE FUNCTION head_position_move() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM organizational_units WHERE head_position_id=OLD.id AND organization_id=OLD.organization_id
      AND (NEW.organizational_unit_id<>OLD.organizational_unit_id OR NEW.organization_id<>OLD.organization_id OR NEW.status<>'active')) THEN
    RAISE EXCEPTION 'HEAD_POSITION_IN_USE';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER head_position_move BEFORE UPDATE OF organizational_unit_id,organization_id,status ON positions
 FOR EACH ROW EXECUTE FUNCTION head_position_move();
CREATE FUNCTION role_family_check() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM job_disciplines WHERE organization_id=NEW.organization_id
      AND id=NEW.discipline_id AND job_family_id=NEW.job_family_id) THEN
    RAISE EXCEPTION 'JOB_FAMILY_MISMATCH';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER role_family_insert BEFORE INSERT ON roles FOR EACH ROW EXECUTE FUNCTION role_family_check();
CREATE TRIGGER role_family_update BEFORE UPDATE ON roles FOR EACH ROW EXECUTE FUNCTION role_family_check();
CREATE FUNCTION discipline_family_update() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM roles WHERE organization_id=OLD.organization_id
      AND discipline_id=OLD.id AND job_family_id<>NEW.job_family_id) THEN
    RAISE EXCEPTION 'JOB_FAMILY_MISMATCH';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER discipline_family_update BEFORE UPDATE OF job_family_id ON job_disciplines
 FOR EACH ROW EXECUTE FUNCTION discipline_family_update();
CREATE FUNCTION assignment_active_dependencies() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS(SELECT 1 FROM employees WHERE organization_id=NEW.organization_id AND id=NEW.employee_id AND employment_status='active')
     OR NOT EXISTS(SELECT 1 FROM positions WHERE organization_id=NEW.organization_id AND id=NEW.position_id AND status='active') THEN
    RAISE EXCEPTION 'ASSIGNMENT_INACTIVE';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER assignment_active_dependencies BEFORE INSERT ON employee_position_assignments
 FOR EACH ROW EXECUTE FUNCTION assignment_active_dependencies();

-- Agent execution ----------------------------------------------------------------------------------
CREATE TABLE agent_threads (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 employee_id text NOT NULL,
 agent_id text NOT NULL,
 conversation_id text,
 title text NOT NULL CHECK(length(title) BETWEEN 1 AND 200),
 status text NOT NULL CHECK(status IN ('ACTIVE','ARCHIVED')),
 created_at text NOT NULL,
 updated_at text NOT NULL,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 UNIQUE(organization_id,id),
 FOREIGN KEY(organization_id,employee_id) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,agent_id) REFERENCES agents(organization_id,id),
 FOREIGN KEY(organization_id,conversation_id) REFERENCES conversations(organization_id,id)
);
CREATE INDEX agent_threads_conversation ON agent_threads(organization_id,conversation_id,agent_id,status);

CREATE TABLE agent_runs (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 thread_id text NOT NULL,
 employee_id text NOT NULL,
 agent_id text NOT NULL,
 manifest_id text,
 manifest_api_version text CHECK(manifest_api_version IN ('agents-foundry/v1','agents-foundry/v2')),
 manifest_key_id text,
 task text NOT NULL CHECK(af_json_valid(task)),
 runtime_profile text NOT NULL,
 status text NOT NULL CHECK(status IN ('QUEUED','RUNNING','WAITING_FOR_APPROVAL','COMPLETED','FAILED','CANCELLED')),
 status_reason text,
 legacy_qa_run_id text UNIQUE REFERENCES qa_runs(id),
 runtime_sequence bigint NOT NULL DEFAULT 0 CHECK(runtime_sequence>=0),
 created_at text NOT NULL,
 updated_at text NOT NULL,
 started_at text,
 completed_at text,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 UNIQUE(organization_id,id),
 FOREIGN KEY(organization_id,thread_id) REFERENCES agent_threads(organization_id,id),
 FOREIGN KEY(organization_id,employee_id) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,agent_id) REFERENCES agents(organization_id,id),
 CHECK((manifest_id IS NULL) = (manifest_api_version IS NULL) AND (manifest_id IS NULL) = (manifest_key_id IS NULL))
);
CREATE UNIQUE INDEX one_active_run_per_thread ON agent_runs(organization_id,thread_id)
 WHERE status IN ('QUEUED','RUNNING','WAITING_FOR_APPROVAL');
CREATE INDEX agent_runs_employee ON agent_runs(organization_id,employee_id,created_at);
CREATE INDEX agent_runs_queue ON agent_runs(status, created_at);
CREATE FUNCTION agent_runs_thread_owner() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM agent_threads WHERE id=NEW.thread_id AND organization_id=NEW.organization_id
      AND employee_id=NEW.employee_id AND agent_id=NEW.agent_id AND status='ACTIVE') THEN
    RAISE EXCEPTION 'RUN_THREAD_MISMATCH';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER agent_runs_thread_owner BEFORE INSERT ON agent_runs
 FOR EACH ROW EXECUTE FUNCTION agent_runs_thread_owner();
CREATE TRIGGER agent_runs_identity_immutable BEFORE UPDATE OF
 id,organization_id,thread_id,employee_id,agent_id,manifest_id,manifest_api_version,manifest_key_id,task,legacy_qa_run_id,created_at
 ON agent_runs FOR EACH ROW EXECUTE FUNCTION af_reject('RUN_IDENTITY_IMMUTABLE');
CREATE TRIGGER agent_runs_terminal_immutable BEFORE UPDATE ON agent_runs
 FOR EACH ROW WHEN (OLD.status IN ('COMPLETED','FAILED','CANCELLED')) EXECUTE FUNCTION af_reject('RUN_TERMINAL');
CREATE TRIGGER agent_runs_no_delete BEFORE DELETE ON agent_runs
 FOR EACH ROW EXECUTE FUNCTION af_reject('RUN_HISTORY_RETAINED');

CREATE TABLE agent_run_steps (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 run_id text NOT NULL,
 sequence bigint NOT NULL CHECK(sequence>0),
 kind text NOT NULL CHECK(kind IN ('PLAN','MODEL','TOOL','ACTION','MESSAGE')),
 title text NOT NULL CHECK(length(title) BETWEEN 1 AND 200),
 status text NOT NULL CHECK(status IN ('PENDING','RUNNING','WAITING_FOR_APPROVAL','COMPLETED','FAILED','SKIPPED','CANCELLED')),
 detail text NOT NULL DEFAULT '{}' CHECK(af_json_valid(detail)),
 created_at text NOT NULL,
 started_at text,
 completed_at text,
 UNIQUE(organization_id,id),
 UNIQUE(run_id,sequence),
 FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id)
);
CREATE TRIGGER agent_run_steps_identity_immutable BEFORE UPDATE OF id,organization_id,run_id,sequence,kind,created_at
 ON agent_run_steps FOR EACH ROW EXECUTE FUNCTION af_reject('STEP_IDENTITY_IMMUTABLE');
CREATE TRIGGER agent_run_steps_no_delete BEFORE DELETE ON agent_run_steps
 FOR EACH ROW EXECUTE FUNCTION af_reject('RUN_HISTORY_RETAINED');

CREATE TABLE agent_events (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 thread_id text NOT NULL,
 run_id text NOT NULL,
 step_id text,
 sequence bigint NOT NULL CHECK(sequence>0),
 runtime_sequence bigint CHECK(runtime_sequence>0),
 event_type text NOT NULL,
 source text NOT NULL CHECK(source IN ('CONTROL_PLANE','RUNTIME')),
 actor_id text,
 payload text NOT NULL CHECK(af_json_valid(payload)),
 payload_hash text NOT NULL CHECK(length(payload_hash)=64),
 occurred_at text NOT NULL,
 recorded_at text NOT NULL,
 UNIQUE(run_id,sequence),
 UNIQUE(run_id,runtime_sequence),
 CHECK((source='RUNTIME') = (runtime_sequence IS NOT NULL)),
 FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
 FOREIGN KEY(organization_id,thread_id) REFERENCES agent_threads(organization_id,id),
 FOREIGN KEY(organization_id,step_id) REFERENCES agent_run_steps(organization_id,id)
);
CREATE FUNCTION run_scope_check() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM agent_runs WHERE id=NEW.run_id AND thread_id=NEW.thread_id AND organization_id=NEW.organization_id)
     OR (NEW.step_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM agent_run_steps WHERE id=NEW.step_id AND run_id=NEW.run_id)) THEN
    RAISE EXCEPTION '%', TG_ARGV[0];
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER agent_events_scope BEFORE INSERT ON agent_events
 FOR EACH ROW EXECUTE FUNCTION run_scope_check('EVENT_SCOPE_MISMATCH');
CREATE TRIGGER agent_events_no_update BEFORE UPDATE ON agent_events
 FOR EACH ROW EXECUTE FUNCTION af_reject('AGENT_EVENTS_APPEND_ONLY');
CREATE TRIGGER agent_events_no_delete BEFORE DELETE ON agent_events
 FOR EACH ROW EXECUTE FUNCTION af_reject('AGENT_EVENTS_APPEND_ONLY');

CREATE TABLE agent_artifacts (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 thread_id text NOT NULL,
 run_id text NOT NULL,
 step_id text,
 artifact_type text NOT NULL,
 media_type text NOT NULL,
 name text NOT NULL CHECK(length(name) BETWEEN 1 AND 255),
 storage_reference text NOT NULL UNIQUE CHECK(storage_reference LIKE 'artifact://%'),
 checksum_sha256 text NOT NULL CHECK(length(checksum_sha256)=64),
 size_bytes bigint NOT NULL CHECK(size_bytes>=0),
 retention_policy text NOT NULL CHECK(retention_policy IN ('EPHEMERAL','STANDARD_30D','EXTENDED_365D','LEGAL_HOLD')),
 created_at text NOT NULL,
 created_by text NOT NULL,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
 FOREIGN KEY(organization_id,thread_id) REFERENCES agent_threads(organization_id,id),
 FOREIGN KEY(organization_id,step_id) REFERENCES agent_run_steps(organization_id,id)
);
CREATE INDEX agent_artifacts_run ON agent_artifacts(organization_id,run_id,created_at);
CREATE TRIGGER agent_artifacts_scope BEFORE INSERT ON agent_artifacts
 FOR EACH ROW EXECUTE FUNCTION run_scope_check('ARTIFACT_SCOPE_MISMATCH');
CREATE TRIGGER agent_artifacts_no_update BEFORE UPDATE ON agent_artifacts
 FOR EACH ROW EXECUTE FUNCTION af_reject('ARTIFACTS_IMMUTABLE');
CREATE TRIGGER agent_artifacts_no_delete BEFORE DELETE ON agent_artifacts
 FOR EACH ROW EXECUTE FUNCTION af_reject('ARTIFACTS_IMMUTABLE');

CREATE FUNCTION approvals_run_link() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND (OLD.run_id IS NOT NULL OR OLD.step_id IS NOT NULL) THEN
    RAISE EXCEPTION 'APPROVAL_RUN_LINK_IMMUTABLE';
  END IF;
  IF (TG_OP = 'INSERT' AND NEW.run_id IS NULL)
     OR (NEW.run_id IS NOT NULL AND NOT EXISTS (
       SELECT 1 FROM agent_runs WHERE id=NEW.run_id AND organization_id=NEW.organization_id))
     OR (NEW.step_id IS NOT NULL AND NOT EXISTS (
       SELECT 1 FROM agent_run_steps WHERE id=NEW.step_id AND run_id=NEW.run_id AND organization_id=NEW.organization_id)) THEN
    RAISE EXCEPTION 'APPROVAL_RUN_SCOPE_MISMATCH';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER approvals_run_link BEFORE UPDATE OF run_id,step_id ON approvals
 FOR EACH ROW EXECUTE FUNCTION approvals_run_link();
CREATE TRIGGER approvals_run_link_insert BEFORE INSERT ON approvals
 FOR EACH ROW WHEN (NEW.run_id IS NOT NULL OR NEW.step_id IS NOT NULL) EXECUTE FUNCTION approvals_run_link();

CREATE TABLE agent_run_leases (
 run_id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 session_id text NOT NULL UNIQUE,
 runtime_id text NOT NULL CHECK(length(runtime_id) BETWEEN 1 AND 120),
 state text NOT NULL CHECK(state IN ('ACTIVE','CLOSED')),
 last_command text,
 claimed_at text NOT NULL,
 heartbeat_at text NOT NULL,
 lease_expires_at text NOT NULL,
 closed_at text,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id)
);
CREATE INDEX agent_run_leases_runtime ON agent_run_leases(runtime_id,state);
CREATE TRIGGER agent_run_leases_identity_immutable BEFORE UPDATE OF run_id,organization_id,claimed_at
 ON agent_run_leases FOR EACH ROW EXECUTE FUNCTION af_reject('LEASE_IDENTITY_IMMUTABLE');
CREATE TRIGGER agent_run_leases_closed_immutable BEFORE UPDATE ON agent_run_leases
 FOR EACH ROW WHEN (OLD.state='CLOSED') EXECUTE FUNCTION af_reject('LEASE_CLOSED');
CREATE TRIGGER agent_run_leases_no_delete BEFORE DELETE ON agent_run_leases
 FOR EACH ROW EXECUTE FUNCTION af_reject('RUN_HISTORY_RETAINED');

CREATE TABLE runtime_request_nonces (
 runtime_id text NOT NULL,
 nonce text NOT NULL,
 expires_at bigint NOT NULL,
 PRIMARY KEY(runtime_id,nonce)
);
CREATE INDEX runtime_request_nonces_expiry ON runtime_request_nonces(expires_at);

-- Action gateway ------------------------------------------------------------------------------------
CREATE TABLE organization_connector_connections (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 provider text NOT NULL CHECK(provider IN ('jira','github')),
 name text NOT NULL CHECK(length(name) BETWEEN 1 AND 120),
 base_url text NOT NULL CHECK(base_url LIKE 'http%'),
 secret_ref text NOT NULL CHECK(secret_ref LIKE 'secret://%'),
 settings text NOT NULL CHECK(af_json_valid(settings)),
 status text NOT NULL CHECK(status IN ('ACTIVE','DISABLED')),
 version bigint NOT NULL DEFAULT 1 CHECK(version>0),
 created_by text NOT NULL,
 created_at text NOT NULL,
 updated_by text NOT NULL,
 updated_at text NOT NULL,
 UNIQUE(organization_id,id),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
);
CREATE UNIQUE INDEX connector_one_active_per_provider ON organization_connector_connections(organization_id,provider)
 WHERE status='ACTIVE';
CREATE TRIGGER connector_connections_identity_immutable BEFORE UPDATE OF id,organization_id,provider,created_by,created_at
 ON organization_connector_connections FOR EACH ROW EXECUTE FUNCTION af_reject('CONNECTION_IDENTITY_IMMUTABLE');
CREATE TRIGGER connector_connections_no_delete BEFORE DELETE ON organization_connector_connections
 FOR EACH ROW EXECUTE FUNCTION af_reject('CONNECTION_HISTORY_RETAINED');

CREATE TABLE agent_action_requests (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 run_id text NOT NULL,
 step_id text NOT NULL,
 runtime_id text NOT NULL,
 action text NOT NULL,
 tool_id text NOT NULL,
 request_hash text NOT NULL CHECK(length(request_hash)=64),
 decision text NOT NULL CHECK(decision IN ('ALLOWED','DENIED','APPROVAL_REQUIRED')),
 risk text NOT NULL CHECK(risk IN ('LOW','MEDIUM','HIGH','CRITICAL')),
 reason text NOT NULL,
 approval_id text REFERENCES approvals(id),
 created_at text NOT NULL,
 parameters text CHECK(parameters IS NULL OR af_json_valid(parameters)),
 policy_id text,
 policy_version text,
 change_set text CHECK(change_set IS NULL OR af_json_valid(change_set)),
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 CHECK((decision='APPROVAL_REQUIRED') = (approval_id IS NOT NULL)),
 FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
 FOREIGN KEY(organization_id,step_id) REFERENCES agent_run_steps(organization_id,id)
);
CREATE INDEX agent_action_requests_run ON agent_action_requests(organization_id,run_id,created_at);
CREATE TRIGGER agent_action_requests_no_update BEFORE UPDATE ON agent_action_requests
 FOR EACH ROW EXECUTE FUNCTION af_reject('ACTION_REQUESTS_APPEND_ONLY');
CREATE TRIGGER agent_action_requests_no_delete BEFORE DELETE ON agent_action_requests
 FOR EACH ROW EXECUTE FUNCTION af_reject('ACTION_REQUESTS_APPEND_ONLY');

CREATE TABLE organization_action_policies (
 organization_id text NOT NULL REFERENCES organizations(id),
 action text NOT NULL CHECK(length(action) BETWEEN 3 AND 120),
 outcome text NOT NULL CHECK(outcome IN ('REQUIRE_APPROVAL','DENY')),
 reason text NOT NULL CHECK(length(reason) BETWEEN 1 AND 500),
 updated_by text NOT NULL,
 updated_at text NOT NULL,
 PRIMARY KEY(organization_id,action),
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
);

CREATE TABLE agent_action_executions (
 request_id text PRIMARY KEY REFERENCES agent_action_requests(id),
 organization_id text NOT NULL REFERENCES organizations(id),
 run_id text NOT NULL,
 connection_id text,
 status text NOT NULL CHECK(status IN ('DISPATCHING','SUCCEEDED','FAILED')),
 result text CHECK(result IS NULL OR af_json_valid(result)),
 error_code text,
 started_at text NOT NULL,
 completed_at text,
 FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
 FOREIGN KEY(organization_id,connection_id) REFERENCES organization_connector_connections(organization_id,id)
);
CREATE FUNCTION agent_action_executions_transition() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.status<>'DISPATCHING' OR NEW.status NOT IN ('SUCCEEDED','FAILED') OR NEW.request_id<>OLD.request_id
     OR NEW.organization_id<>OLD.organization_id OR NEW.run_id<>OLD.run_id
     OR NEW.connection_id IS DISTINCT FROM OLD.connection_id OR NEW.started_at<>OLD.started_at THEN
    RAISE EXCEPTION 'ACTION_EXECUTION_FINAL';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER agent_action_executions_transition BEFORE UPDATE ON agent_action_executions
 FOR EACH ROW EXECUTE FUNCTION agent_action_executions_transition();
CREATE TRIGGER agent_action_executions_no_delete BEFORE DELETE ON agent_action_executions
 FOR EACH ROW EXECUTE FUNCTION af_reject('ACTION_REQUESTS_APPEND_ONLY');

CREATE TABLE agent_execution_grants (
 grant_id text PRIMARY KEY,
 request_id text NOT NULL UNIQUE REFERENCES agent_action_requests(id),
 organization_id text NOT NULL REFERENCES organizations(id),
 run_id text NOT NULL,
 operation_kind text NOT NULL,
 signed_grant text NOT NULL CHECK(af_json_valid(signed_grant)),
 issued_at text NOT NULL,
 expires_at text NOT NULL,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id)
);
CREATE TRIGGER agent_execution_grants_no_update BEFORE UPDATE ON agent_execution_grants
 FOR EACH ROW EXECUTE FUNCTION af_reject('EXECUTION_GRANTS_IMMUTABLE');
CREATE TRIGGER agent_execution_grants_no_delete BEFORE DELETE ON agent_execution_grants
 FOR EACH ROW EXECUTE FUNCTION af_reject('EXECUTION_GRANTS_IMMUTABLE');

-- Row-level security ----------------------------------------------------------------------------
-- Every table with an organization is isolated by af_current_organization(), which is set
-- per transaction and is NULL (matching nothing) when unset. FORCE applies the policies to the
-- table owner too; only the platform role (BYPASSRLS) sees across organizations.
DO $$
DECLARE
  item text;
BEGIN
  FOREACH item IN ARRAY ARRAY[
    'employees','organization_memberships','account_link_invitations','auth_sessions',
    'organization_agent_installations','agents','agent_manifests','agent_assignments',
    'admin_agent_batches','provisioning_requests','conversations','messages','approvals',
    'qa_runs','llm_key_bindings','audit_events','organizational_units',
    'organization_change_events','job_families','job_disciplines','roles','job_levels',
    'positions','organizational_unit_memberships','organization_domains',
    'employee_position_assignments','agent_threads','agent_runs','agent_run_steps',
    'agent_events','agent_artifacts','agent_run_leases','organization_connector_connections',
    'agent_action_requests','organization_action_policies','agent_action_executions',
    'agent_execution_grants'
  ] LOOP
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', item);
    EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', item);
    EXECUTE format(
      'CREATE POLICY tenant_isolation ON %I USING (organization_id = af_current_organization())'
      ' WITH CHECK (organization_id = af_current_organization())', item);
  END LOOP;
END $$;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON organizations
 USING (id = af_current_organization()) WITH CHECK (id = af_current_organization());
-- Accounts are global, but a tenant sees only accounts that are members of it.
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE users FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_members ON users USING (EXISTS (
 SELECT 1 FROM organization_memberships m WHERE m.user_id = users.id));
-- Identities are sign-in records; a tenant sees only its own employees' identities.
ALTER TABLE identities ENABLE ROW LEVEL SECURITY;
ALTER TABLE identities FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_employees ON identities USING (EXISTS (
 SELECT 1 FROM employees e WHERE e.id = identities.employee_id));
ALTER TABLE account_password_credentials ENABLE ROW LEVEL SECURITY;
ALTER TABLE account_password_credentials FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_members ON account_password_credentials USING (EXISTS (
 SELECT 1 FROM organization_memberships m WHERE m.user_id = account_password_credentials.user_id));

-- Privileges --------------------------------------------------------------------------------------
-- af_tenant: tenant tables, plus the narrow column grants below. Password hashes, session and
-- invitation tokens, login transactions and runtime nonces are not granted at all, so
-- tenant-scoped code cannot read them even by mistake.
GRANT USAGE ON SCHEMA public TO af_tenant, af_platform;
GRANT SELECT, INSERT, UPDATE ON
 employees, organization_memberships, organization_agent_installations, agents, agent_manifests,
 agent_assignments, admin_agent_batches, provisioning_requests, conversations, messages,
 approvals, qa_runs, llm_key_bindings, audit_events, organizational_units,
 organization_change_events, job_families, job_disciplines, roles, job_levels, positions,
 organizational_unit_memberships, organization_domains, employee_position_assignments,
 agent_threads, agent_runs, agent_run_steps, agent_events, agent_artifacts, agent_run_leases,
 organization_connector_connections, agent_action_requests, organization_action_policies,
 agent_action_executions, agent_execution_grants
 TO af_tenant;
GRANT DELETE ON organization_action_policies TO af_tenant;
GRANT SELECT, UPDATE ON organizations TO af_tenant;
GRANT SELECT (id, email, display_name, status, created_at) ON users TO af_tenant;
GRANT SELECT (user_id) ON account_password_credentials TO af_tenant;
-- Admins revoke their own organization's sessions and re-enable their employees' local sign-in;
-- session hashes and identity subjects stay unreadable.
GRANT SELECT (user_id, organization_id), DELETE ON auth_sessions TO af_tenant;
GRANT SELECT (issuer, employee_id, user_id, enabled), UPDATE (enabled) ON identities TO af_tenant;
GRANT SELECT ON catalog_blueprint_versions TO af_tenant;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO af_platform;
-- Migration history belongs to the schema owner.
REVOKE INSERT, UPDATE, DELETE ON schema_migrations FROM af_platform;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO af_tenant, af_platform;


-- SOURCE: apps/control-plane-api/src/db/migrations/0002-model-spending.ts

CREATE TABLE organization_model_budgets (
 organization_id text PRIMARY KEY REFERENCES organizations(id),
 monthly_token_limit bigint CHECK(monthly_token_limit IS NULL OR monthly_token_limit>0),
 run_token_limit bigint CHECK(run_token_limit IS NULL OR run_token_limit>0),
 version bigint NOT NULL DEFAULT 1 CHECK(version>0),
 updated_by text NOT NULL,
 updated_at text NOT NULL,
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
);

CREATE TABLE model_usage_reservations (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 run_id text NOT NULL,
 employee_id text NOT NULL,
 agent_id text NOT NULL,
 runtime_id text NOT NULL,
 provider text NOT NULL,
 model text NOT NULL,
 period text NOT NULL CHECK(period ~ '^[0-9]{4}-[0-9]{2}$'),
 reserved_tokens bigint NOT NULL CHECK(reserved_tokens>0),
 max_output_tokens bigint NOT NULL CHECK(max_output_tokens>0),
 status text NOT NULL CHECK(status IN ('RESERVED','SETTLED')),
 input_tokens bigint CHECK(input_tokens>=0),
 output_tokens bigint CHECK(output_tokens>=0),
 request_hash text NOT NULL,
 created_at text NOT NULL,
 settled_at text,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 CHECK((status='SETTLED') = (input_tokens IS NOT NULL AND output_tokens IS NOT NULL AND settled_at IS NOT NULL)),
 FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
 FOREIGN KEY(organization_id,employee_id) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,agent_id) REFERENCES agents(organization_id,id)
);
CREATE INDEX model_usage_period ON model_usage_reservations(organization_id,period);
CREATE INDEX model_usage_run ON model_usage_reservations(organization_id,run_id);
-- Only a reservation's settlement may change it, once; usage history is never deleted.
CREATE FUNCTION af_model_usage_settle_only() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.status <> 'RESERVED' OR NEW.status <> 'SETTLED'
     OR (NEW.id, NEW.organization_id, NEW.run_id, NEW.employee_id, NEW.agent_id, NEW.runtime_id,
         NEW.provider, NEW.model, NEW.period, NEW.reserved_tokens, NEW.max_output_tokens,
         NEW.request_hash, NEW.created_at)
     IS DISTINCT FROM
        (OLD.id, OLD.organization_id, OLD.run_id, OLD.employee_id, OLD.agent_id, OLD.runtime_id,
         OLD.provider, OLD.model, OLD.period, OLD.reserved_tokens, OLD.max_output_tokens,
         OLD.request_hash, OLD.created_at) THEN
    RAISE EXCEPTION 'MODEL_USAGE_IMMUTABLE';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER model_usage_settle_only BEFORE UPDATE ON model_usage_reservations
 FOR EACH ROW EXECUTE FUNCTION af_model_usage_settle_only();
CREATE TRIGGER model_usage_no_delete BEFORE DELETE ON model_usage_reservations
 FOR EACH ROW EXECUTE FUNCTION af_reject('MODEL_USAGE_IMMUTABLE');

ALTER TABLE organization_model_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_model_budgets FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON organization_model_budgets
 USING (organization_id = af_current_organization())
 WITH CHECK (organization_id = af_current_organization());
ALTER TABLE model_usage_reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE model_usage_reservations FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON model_usage_reservations
 USING (organization_id = af_current_organization())
 WITH CHECK (organization_id = af_current_organization());

GRANT SELECT, INSERT, UPDATE ON organization_model_budgets, model_usage_reservations TO af_tenant;
GRANT SELECT, INSERT, UPDATE, DELETE ON organization_model_budgets, model_usage_reservations
 TO af_platform;


-- SOURCE: apps/control-plane-api/src/db/migrations/0003-model-prices.ts

ALTER TABLE organization_model_budgets
 ADD COLUMN currency text NOT NULL DEFAULT 'USD' CHECK(currency ~ '^[A-Z]{3}$'),
 ADD COLUMN monthly_cost_limit_micros bigint
   CHECK(monthly_cost_limit_micros IS NULL OR monthly_cost_limit_micros>0),
 ADD COLUMN run_cost_limit_micros bigint
   CHECK(run_cost_limit_micros IS NULL OR run_cost_limit_micros>0);

CREATE TABLE model_prices (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 provider text NOT NULL,
 model text NOT NULL,
 currency text NOT NULL CHECK(currency ~ '^[A-Z]{3}$'),
 input_micros_per_million bigint CHECK(input_micros_per_million BETWEEN 0 AND 10000000000),
 output_micros_per_million bigint CHECK(output_micros_per_million BETWEEN 0 AND 10000000000),
 supersedes text,
 set_by text NOT NULL,
 set_at text NOT NULL,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 CHECK((input_micros_per_million IS NULL) = (output_micros_per_million IS NULL)),
 UNIQUE(organization_id,id),
 UNIQUE(organization_id,supersedes),
 FOREIGN KEY(organization_id,supersedes) REFERENCES model_prices(organization_id,id),
 FOREIGN KEY(organization_id,set_by) REFERENCES employees(organization_id,id)
);
CREATE INDEX model_prices_model ON model_prices(organization_id,provider,model,seq);
-- One chain per model: only its first price supersedes nothing.
CREATE UNIQUE INDEX model_prices_first ON model_prices(organization_id,provider,model)
 WHERE supersedes IS NULL;
CREATE TRIGGER model_prices_no_update BEFORE UPDATE ON model_prices
 FOR EACH ROW EXECUTE FUNCTION af_reject('MODEL_PRICE_IMMUTABLE');
CREATE TRIGGER model_prices_no_delete BEFORE DELETE ON model_prices
 FOR EACH ROW EXECUTE FUNCTION af_reject('MODEL_PRICE_IMMUTABLE');

ALTER TABLE model_usage_reservations
 ADD COLUMN price_id text,
 ADD COLUMN currency text,
 ADD COLUMN reserved_cost_micros bigint CHECK(reserved_cost_micros>=0),
 ADD COLUMN cost_micros bigint CHECK(cost_micros>=0),
 ADD CONSTRAINT model_usage_price FOREIGN KEY(organization_id,price_id)
   REFERENCES model_prices(organization_id,id),
 ADD CONSTRAINT model_usage_priced CHECK(
   (price_id IS NULL) = (currency IS NULL) AND (price_id IS NULL) = (reserved_cost_micros IS NULL)
   AND (cost_micros IS NULL) = (price_id IS NULL OR status='RESERVED'));

-- The settlement is still the only change, now including its cost.
CREATE OR REPLACE FUNCTION af_model_usage_settle_only() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.status <> 'RESERVED' OR NEW.status <> 'SETTLED'
     OR (NEW.id, NEW.organization_id, NEW.run_id, NEW.employee_id, NEW.agent_id, NEW.runtime_id,
         NEW.provider, NEW.model, NEW.period, NEW.reserved_tokens, NEW.max_output_tokens,
         NEW.request_hash, NEW.created_at, NEW.price_id, NEW.currency, NEW.reserved_cost_micros)
     IS DISTINCT FROM
        (OLD.id, OLD.organization_id, OLD.run_id, OLD.employee_id, OLD.agent_id, OLD.runtime_id,
         OLD.provider, OLD.model, OLD.period, OLD.reserved_tokens, OLD.max_output_tokens,
         OLD.request_hash, OLD.created_at, OLD.price_id, OLD.currency, OLD.reserved_cost_micros) THEN
    RAISE EXCEPTION 'MODEL_USAGE_IMMUTABLE';
  END IF;
  RETURN NEW;
END $$;

ALTER TABLE model_prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE model_prices FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON model_prices
 USING (organization_id = af_current_organization())
 WITH CHECK (organization_id = af_current_organization());

GRANT SELECT, INSERT ON model_prices TO af_tenant;
GRANT SELECT, INSERT, UPDATE, DELETE ON model_prices TO af_platform;


-- SOURCE: apps/control-plane-api/src/db/migrations/0004-model-budget-alerts.ts

ALTER TABLE organization_model_budgets
 ADD COLUMN alert_thresholds smallint[] NOT NULL DEFAULT '{80}'
   CHECK(cardinality(alert_thresholds) <= 5 AND array_position(alert_thresholds, NULL) IS NULL
     AND 1 <= ALL(alert_thresholds) AND 99 >= ALL(alert_thresholds));

CREATE TABLE model_budget_alerts (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 period text NOT NULL CHECK(period ~ '^[0-9]{4}-[0-9]{2}$'),
 scope text NOT NULL CHECK(scope IN ('MONTHLY_TOKENS','MONTHLY_COST')),
 threshold_percent smallint NOT NULL CHECK(threshold_percent BETWEEN 1 AND 100),
 limit_value bigint NOT NULL CHECK(limit_value>0),
 charged_value bigint NOT NULL CHECK(charged_value>=0),
 currency text CHECK(currency ~ '^[A-Z]{3}$'),
 created_at text NOT NULL,
 acknowledged_by text,
 acknowledged_at text,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 UNIQUE(organization_id,period,scope,threshold_percent),
 CHECK((scope='MONTHLY_COST') = (currency IS NOT NULL)),
 CHECK((acknowledged_by IS NULL) = (acknowledged_at IS NULL)),
 FOREIGN KEY(organization_id,acknowledged_by) REFERENCES employees(organization_id,id)
);
CREATE INDEX model_budget_alerts_period ON model_budget_alerts(organization_id,period);
CREATE FUNCTION af_model_budget_alert_ack_only() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.acknowledged_at IS NOT NULL OR NEW.acknowledged_at IS NULL
     OR (NEW.id, NEW.organization_id, NEW.period, NEW.scope, NEW.threshold_percent,
         NEW.limit_value, NEW.charged_value, NEW.currency, NEW.created_at)
     IS DISTINCT FROM
        (OLD.id, OLD.organization_id, OLD.period, OLD.scope, OLD.threshold_percent,
         OLD.limit_value, OLD.charged_value, OLD.currency, OLD.created_at) THEN
    RAISE EXCEPTION 'MODEL_BUDGET_ALERT_IMMUTABLE';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER model_budget_alerts_ack_only BEFORE UPDATE ON model_budget_alerts
 FOR EACH ROW EXECUTE FUNCTION af_model_budget_alert_ack_only();
CREATE TRIGGER model_budget_alerts_no_delete BEFORE DELETE ON model_budget_alerts
 FOR EACH ROW EXECUTE FUNCTION af_reject('MODEL_BUDGET_ALERT_IMMUTABLE');

ALTER TABLE model_budget_alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE model_budget_alerts FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON model_budget_alerts
 USING (organization_id = af_current_organization())
 WITH CHECK (organization_id = af_current_organization());

GRANT SELECT, INSERT, UPDATE ON model_budget_alerts TO af_tenant;
GRANT SELECT, INSERT, UPDATE, DELETE ON model_budget_alerts TO af_platform;


-- SOURCE: apps/control-plane-api/src/db/migrations/0005-alert-webhooks.ts

CREATE TABLE organization_alert_webhooks (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 url text NOT NULL CHECK(url ~ '^https?://' AND length(url) <= 500),
 description text NOT NULL CHECK(length(description) <= 200),
 status text NOT NULL CHECK(status IN ('ACTIVE','DISABLED')),
 version bigint NOT NULL DEFAULT 1 CHECK(version>0),
 created_by text NOT NULL,
 created_at text NOT NULL,
 updated_by text NOT NULL,
 updated_at text NOT NULL,
 UNIQUE(organization_id,id),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
);
CREATE FUNCTION af_alert_webhook_status_only() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF (NEW.id, NEW.organization_id, NEW.url, NEW.description, NEW.created_by, NEW.created_at)
     IS DISTINCT FROM (OLD.id, OLD.organization_id, OLD.url, OLD.description, OLD.created_by, OLD.created_at) THEN
    RAISE EXCEPTION 'ALERT_WEBHOOK_IMMUTABLE';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER alert_webhooks_status_only BEFORE UPDATE ON organization_alert_webhooks
 FOR EACH ROW EXECUTE FUNCTION af_alert_webhook_status_only();
CREATE TRIGGER alert_webhooks_no_delete BEFORE DELETE ON organization_alert_webhooks
 FOR EACH ROW EXECUTE FUNCTION af_reject('ALERT_WEBHOOK_IMMUTABLE');

CREATE TABLE alert_webhook_deliveries (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 webhook_id text NOT NULL,
 event_type text NOT NULL CHECK(event_type IN ('model.budget.alert','webhook.test')),
 alert_id text REFERENCES model_budget_alerts(id),
 body text NOT NULL,
 status text NOT NULL CHECK(status IN ('PENDING','DELIVERED','FAILED')),
 attempts integer NOT NULL DEFAULT 0 CHECK(attempts BETWEEN 0 AND 10),
 next_attempt_at text,
 last_attempt_at text,
 last_status_code integer CHECK(last_status_code BETWEEN 100 AND 599),
 last_error text CHECK(length(last_error) <= 80),
 delivered_at text,
 created_at text NOT NULL,
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 UNIQUE(webhook_id,alert_id),
 CHECK((event_type='model.budget.alert') = (alert_id IS NOT NULL)),
 CHECK((status='PENDING') = (next_attempt_at IS NOT NULL)),
 CHECK((status='DELIVERED') = (delivered_at IS NOT NULL)),
 FOREIGN KEY(organization_id,webhook_id) REFERENCES organization_alert_webhooks(organization_id,id)
);
CREATE INDEX alert_webhook_deliveries_due ON alert_webhook_deliveries(next_attempt_at)
 WHERE status='PENDING';
CREATE INDEX alert_webhook_deliveries_recent ON alert_webhook_deliveries(organization_id,seq);
CREATE FUNCTION af_alert_webhook_delivery_progress() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.status <> 'PENDING'
     OR NEW.attempts < OLD.attempts
     OR (NEW.id, NEW.organization_id, NEW.webhook_id, NEW.event_type, NEW.alert_id, NEW.body, NEW.created_at)
     IS DISTINCT FROM
        (OLD.id, OLD.organization_id, OLD.webhook_id, OLD.event_type, OLD.alert_id, OLD.body, OLD.created_at) THEN
    RAISE EXCEPTION 'ALERT_WEBHOOK_DELIVERY_IMMUTABLE';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER alert_webhook_deliveries_progress BEFORE UPDATE ON alert_webhook_deliveries
 FOR EACH ROW EXECUTE FUNCTION af_alert_webhook_delivery_progress();
CREATE TRIGGER alert_webhook_deliveries_no_delete BEFORE DELETE ON alert_webhook_deliveries
 FOR EACH ROW EXECUTE FUNCTION af_reject('ALERT_WEBHOOK_DELIVERY_IMMUTABLE');

ALTER TABLE organization_alert_webhooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_alert_webhooks FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON organization_alert_webhooks
 USING (organization_id = af_current_organization())
 WITH CHECK (organization_id = af_current_organization());
ALTER TABLE alert_webhook_deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE alert_webhook_deliveries FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON alert_webhook_deliveries
 USING (organization_id = af_current_organization())
 WITH CHECK (organization_id = af_current_organization());

GRANT SELECT, INSERT, UPDATE ON organization_alert_webhooks TO af_tenant;
GRANT SELECT, INSERT ON alert_webhook_deliveries TO af_tenant;
GRANT SELECT, INSERT, UPDATE, DELETE ON organization_alert_webhooks, alert_webhook_deliveries
 TO af_platform;


-- SOURCE: apps/control-plane-api/src/db/migrations/0006-model-quality-results.ts

CREATE TABLE model_quality_results (
 run_id text NOT NULL CHECK(length(run_id) BETWEEN 1 AND 200),
 run_at text NOT NULL,
 commit_sha text CHECK(length(commit_sha) <= 64),
 provider text NOT NULL CHECK(length(provider) BETWEEN 1 AND 200),
 model text NOT NULL CHECK(length(model) BETWEEN 1 AND 200),
 judge_model text NOT NULL CHECK(length(judge_model) BETWEEN 1 AND 200),
 blueprint text NOT NULL CHECK(length(blueprint) BETWEEN 1 AND 200),
 suite text NOT NULL CHECK(length(suite) BETWEEN 1 AND 200),
 task text NOT NULL CHECK(length(task) BETWEEN 1 AND 200),
 trial integer NOT NULL CHECK(trial BETWEEN 1 AND 100),
 passed boolean NOT NULL,
 score double precision NOT NULL CHECK(score BETWEEN 0 AND 1),
 pass_threshold double precision NOT NULL CHECK(pass_threshold BETWEEN 0 AND 1),
 failed_gates text NOT NULL,
 run_status text NOT NULL CHECK(length(run_status) BETWEEN 1 AND 200),
 tokens bigint NOT NULL CHECK(tokens >= 0),
 estimated_cost_usd double precision CHECK(estimated_cost_usd >= 0),
 imported_at text NOT NULL,
 PRIMARY KEY(run_id, provider, model, judge_model, blueprint, task, trial)
);
CREATE INDEX model_quality_results_run_at ON model_quality_results(run_at);
CREATE TRIGGER model_quality_results_no_update BEFORE UPDATE ON model_quality_results
 FOR EACH ROW EXECUTE FUNCTION af_reject('MODEL_QUALITY_RESULT_IMMUTABLE');
CREATE TRIGGER model_quality_results_no_delete BEFORE DELETE ON model_quality_results
 FOR EACH ROW EXECUTE FUNCTION af_reject('MODEL_QUALITY_RESULT_IMMUTABLE');

GRANT SELECT ON model_quality_results TO af_tenant;
GRANT SELECT, INSERT ON model_quality_results TO af_platform;


-- SOURCE: apps/control-plane-api/src/db/migrations/0007-tenant-domain-notifications.ts

CREATE FUNCTION af_notify_tenant_domains() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM pg_notify('af_tenant_domains', '');
  RETURN NULL;
END $$;
CREATE TRIGGER organization_domains_notify
 AFTER INSERT OR UPDATE OR DELETE OR TRUNCATE ON organization_domains
 FOR EACH STATEMENT EXECUTE FUNCTION af_notify_tenant_domains();
CREATE TRIGGER organizations_notify_tenant_domains
 AFTER UPDATE OR DELETE OR TRUNCATE ON organizations
 FOR EACH STATEMENT EXECUTE FUNCTION af_notify_tenant_domains();


-- SOURCE: apps/control-plane-api/src/db/migrations/0008-native-column-types.ts

-- A stored time without an offset is UTC, whatever the server's time zone.
SET LOCAL TimeZone = 'UTC';

-- JSON validity is now the column type; the text checks cannot apply to jsonb.
DO $$
DECLARE item record;
BEGIN
  FOR item IN
    SELECT t.relname AS table_name, k.conname
    FROM pg_constraint k JOIN pg_class t ON t.oid = k.conrelid
    WHERE k.contype = 'c' AND pg_get_constraintdef(k.oid) LIKE '%af_json_valid(%'
      AND (t.relname, substring(pg_get_constraintdef(k.oid) FROM 'af_json_valid\((\w+)\)'))
        IN (VALUES ('admin_agent_batches','result'),('agent_action_executions','result'),('agent_action_requests','parameters'),('agent_action_requests','change_set'),('agent_events','payload'),('agent_run_steps','detail'),('agent_runs','task'),('audit_events','metadata'),('login_transactions','body'),('model_quality_results','failed_gates'),('organization_agent_installations','configuration'),('organization_change_events','before_json'),('organization_change_events','after_json'),('organization_connector_connections','settings'),('provisioning_requests','body'))
  LOOP
    EXECUTE format('ALTER TABLE %I DROP CONSTRAINT %I', item.table_name, item.conname);
  END LOOP;
END $$;
ALTER TABLE agent_run_steps ALTER COLUMN detail DROP DEFAULT;

-- Triggers that name a converted column are recreated unchanged afterwards.
DROP TRIGGER installation_identity_immutable ON organization_agent_installations;
DROP TRIGGER agent_runs_identity_immutable ON agent_runs;
DROP TRIGGER agent_run_steps_identity_immutable ON agent_run_steps;
DROP TRIGGER agent_run_leases_identity_immutable ON agent_run_leases;
DROP TRIGGER connector_connections_identity_immutable ON organization_connector_connections;

ALTER TABLE account_password_credentials
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE admin_agent_batches
 ALTER COLUMN result TYPE jsonb USING result::jsonb;
ALTER TABLE agent_action_executions
 ALTER COLUMN started_at TYPE timestamptz USING started_at::timestamptz,
 ALTER COLUMN completed_at TYPE timestamptz USING completed_at::timestamptz,
 ALTER COLUMN result TYPE jsonb USING result::jsonb;
ALTER TABLE agent_action_requests
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN parameters TYPE jsonb USING parameters::jsonb,
 ALTER COLUMN change_set TYPE jsonb USING change_set::jsonb;
ALTER TABLE agent_artifacts
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz;
ALTER TABLE agent_assignments
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz;
ALTER TABLE agent_events
 ALTER COLUMN occurred_at TYPE timestamptz USING occurred_at::timestamptz,
 ALTER COLUMN recorded_at TYPE timestamptz USING recorded_at::timestamptz,
 ALTER COLUMN payload TYPE jsonb USING payload::jsonb;
ALTER TABLE agent_execution_grants
 ALTER COLUMN issued_at TYPE timestamptz USING issued_at::timestamptz,
 ALTER COLUMN expires_at TYPE timestamptz USING expires_at::timestamptz;
ALTER TABLE agent_run_leases
 ALTER COLUMN claimed_at TYPE timestamptz USING claimed_at::timestamptz,
 ALTER COLUMN heartbeat_at TYPE timestamptz USING heartbeat_at::timestamptz,
 ALTER COLUMN lease_expires_at TYPE timestamptz USING lease_expires_at::timestamptz,
 ALTER COLUMN closed_at TYPE timestamptz USING closed_at::timestamptz;
ALTER TABLE agent_run_steps
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN started_at TYPE timestamptz USING started_at::timestamptz,
 ALTER COLUMN completed_at TYPE timestamptz USING completed_at::timestamptz,
 ALTER COLUMN detail TYPE jsonb USING detail::jsonb;
ALTER TABLE agent_runs
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz,
 ALTER COLUMN started_at TYPE timestamptz USING started_at::timestamptz,
 ALTER COLUMN completed_at TYPE timestamptz USING completed_at::timestamptz,
 ALTER COLUMN task TYPE jsonb USING task::jsonb;
ALTER TABLE agent_threads
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE alert_webhook_deliveries
 ALTER COLUMN next_attempt_at TYPE timestamptz USING next_attempt_at::timestamptz,
 ALTER COLUMN last_attempt_at TYPE timestamptz USING last_attempt_at::timestamptz,
 ALTER COLUMN delivered_at TYPE timestamptz USING delivered_at::timestamptz,
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz;
ALTER TABLE approvals
 ALTER COLUMN decided_at TYPE timestamptz USING decided_at::timestamptz,
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN expires_at TYPE timestamptz USING expires_at::timestamptz;
ALTER TABLE audit_events
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN metadata TYPE jsonb USING metadata::jsonb;
ALTER TABLE catalog_blueprint_versions
 ALTER COLUMN registered_at TYPE timestamptz USING registered_at::timestamptz;
ALTER TABLE conversations
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE employee_position_assignments
 ALTER COLUMN started_at TYPE timestamptz USING started_at::timestamptz,
 ALTER COLUMN ended_at TYPE timestamptz USING ended_at::timestamptz;
ALTER TABLE job_disciplines
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE job_families
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE job_levels
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE llm_key_bindings
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz;
ALTER TABLE login_transactions
 ALTER COLUMN body TYPE jsonb USING body::jsonb;
ALTER TABLE messages
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz;
ALTER TABLE model_budget_alerts
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN acknowledged_at TYPE timestamptz USING acknowledged_at::timestamptz;
ALTER TABLE model_prices
 ALTER COLUMN set_at TYPE timestamptz USING set_at::timestamptz;
ALTER TABLE model_quality_results
 ALTER COLUMN run_at TYPE timestamptz USING run_at::timestamptz,
 ALTER COLUMN imported_at TYPE timestamptz USING imported_at::timestamptz,
 ALTER COLUMN failed_gates TYPE jsonb USING failed_gates::jsonb;
ALTER TABLE model_usage_reservations
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN settled_at TYPE timestamptz USING settled_at::timestamptz;
ALTER TABLE organization_action_policies
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE organization_agent_installations
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz,
 ALTER COLUMN configuration TYPE jsonb USING configuration::jsonb;
ALTER TABLE organization_alert_webhooks
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE organization_change_events
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN before_json TYPE jsonb USING before_json::jsonb,
 ALTER COLUMN after_json TYPE jsonb USING after_json::jsonb;
ALTER TABLE organization_connector_connections
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz,
 ALTER COLUMN settings TYPE jsonb USING settings::jsonb;
ALTER TABLE organization_domains
 ALTER COLUMN verified_at TYPE timestamptz USING verified_at::timestamptz,
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE organization_memberships
 ALTER COLUMN joined_at TYPE timestamptz USING joined_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE organization_model_budgets
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE organizational_unit_memberships
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN started_at TYPE timestamptz USING started_at::timestamptz,
 ALTER COLUMN ended_at TYPE timestamptz USING ended_at::timestamptz;
ALTER TABLE organizational_units
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE organizations
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE positions
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE provisioning_requests
 ALTER COLUMN body TYPE jsonb USING body::jsonb;
ALTER TABLE qa_runs
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz;
ALTER TABLE roles
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz,
 ALTER COLUMN updated_at TYPE timestamptz USING updated_at::timestamptz;
ALTER TABLE users
 ALTER COLUMN created_at TYPE timestamptz USING created_at::timestamptz;

ALTER TABLE agent_run_steps ALTER COLUMN detail SET DEFAULT '{}'::jsonb;

CREATE TRIGGER installation_identity_immutable BEFORE UPDATE OF id,organization_id,blueprint_id,created_by,created_at
 ON organization_agent_installations FOR EACH ROW EXECUTE FUNCTION af_reject('INSTALLATION_IDENTITY_IMMUTABLE');
CREATE TRIGGER agent_runs_identity_immutable BEFORE UPDATE OF
 id,organization_id,thread_id,employee_id,agent_id,manifest_id,manifest_api_version,manifest_key_id,task,legacy_qa_run_id,created_at
 ON agent_runs FOR EACH ROW EXECUTE FUNCTION af_reject('RUN_IDENTITY_IMMUTABLE');
CREATE TRIGGER agent_run_steps_identity_immutable BEFORE UPDATE OF id,organization_id,run_id,sequence,kind,created_at
 ON agent_run_steps FOR EACH ROW EXECUTE FUNCTION af_reject('STEP_IDENTITY_IMMUTABLE');
CREATE TRIGGER agent_run_leases_identity_immutable BEFORE UPDATE OF run_id,organization_id,claimed_at
 ON agent_run_leases FOR EACH ROW EXECUTE FUNCTION af_reject('LEASE_IDENTITY_IMMUTABLE');
CREATE TRIGGER connector_connections_identity_immutable BEFORE UPDATE OF id,organization_id,provider,created_by,created_at
 ON organization_connector_connections FOR EACH ROW EXECUTE FUNCTION af_reject('CONNECTION_IDENTITY_IMMUTABLE');

-- Milliseconds, like every timestamp the API writes, so values read back compare equal.
CREATE OR REPLACE FUNCTION organization_profile_defaults() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.code := coalesce(NEW.code, upper(NEW.slug));
  NEW.created_at := coalesce(NEW.created_at, date_trunc('milliseconds', clock_timestamp()));
  NEW.updated_at := coalesce(NEW.updated_at, date_trunc('milliseconds', clock_timestamp()));
  RETURN NEW;
END $$;


-- SOURCE: apps/control-plane-api/src/db/migrations/0009-catalog-version-notifications.ts

CREATE FUNCTION af_notify_catalog_versions() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM inserted) THEN
    PERFORM pg_notify('af_catalog_versions', '');
  END IF;
  RETURN NULL;
END $$;
CREATE TRIGGER catalog_versions_notify
 AFTER INSERT ON catalog_blueprint_versions REFERENCING NEW TABLE AS inserted
 FOR EACH STATEMENT EXECUTE FUNCTION af_notify_catalog_versions();


-- SOURCE: apps/control-plane-api/src/db/migrations/0010-catalog-bundle-schema.ts

ALTER TABLE catalog_blueprint_versions
 ADD COLUMN bundle_schema text NOT NULL DEFAULT 'agents-foundry.catalog-bundle/v1'
 CHECK (bundle_schema ~ '^[a-z0-9.-]{1,100}/v[0-9]{1,6}$');


-- SOURCE: apps/control-plane-api/src/db/migrations/0011-repository-credentials.ts

CREATE TABLE organization_source_control_connections (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 provider text NOT NULL CHECK(provider IN ('github','bitbucket')),
 name text NOT NULL CHECK(length(name) BETWEEN 1 AND 120),
 git_host text NOT NULL CHECK(git_host ~ '^[a-z0-9]([a-z0-9.-]{0,251}[a-z0-9])?$'),
 api_base_url text NOT NULL CHECK(api_base_url ~ '^https?://' AND length(api_base_url) <= 300),
 credential_mode text NOT NULL CHECK(credential_mode IN ('static_token','github_app')),
 secret_ref text NOT NULL CHECK(secret_ref ~ '^secret://[a-z0-9][a-z0-9._-]{0,63}$'),
 app_id text CHECK(app_id ~ '^[0-9]{1,20}$'),
 installation_id text CHECK(installation_id ~ '^[0-9]{1,20}$'),
 allowed_repositories jsonb NOT NULL CHECK(jsonb_typeof(allowed_repositories)='array'),
 status text NOT NULL CHECK(status IN ('ACTIVE','DISABLED')),
 version bigint NOT NULL DEFAULT 1 CHECK(version>0),
 created_by text NOT NULL,
 created_at timestamptz NOT NULL,
 updated_by text NOT NULL,
 updated_at timestamptz NOT NULL,
 UNIQUE(organization_id,id),
 CHECK((credential_mode='github_app') = (app_id IS NOT NULL AND installation_id IS NOT NULL)),
 CHECK(credential_mode<>'github_app' OR provider='github'),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
);
CREATE UNIQUE INDEX source_control_one_active_per_host
 ON organization_source_control_connections(organization_id,git_host) WHERE status='ACTIVE';
CREATE FUNCTION af_source_control_connection_status_only() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF (NEW.id, NEW.organization_id, NEW.provider, NEW.name, NEW.git_host, NEW.api_base_url,
      NEW.credential_mode, NEW.secret_ref, NEW.app_id, NEW.installation_id,
      NEW.allowed_repositories, NEW.created_by, NEW.created_at)
     IS DISTINCT FROM
     (OLD.id, OLD.organization_id, OLD.provider, OLD.name, OLD.git_host, OLD.api_base_url,
      OLD.credential_mode, OLD.secret_ref, OLD.app_id, OLD.installation_id,
      OLD.allowed_repositories, OLD.created_by, OLD.created_at)
     OR OLD.status='DISABLED' THEN
    RAISE EXCEPTION 'SOURCE_CONTROL_CONNECTION_IMMUTABLE';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER source_control_connections_status_only BEFORE UPDATE ON organization_source_control_connections
 FOR EACH ROW EXECUTE FUNCTION af_source_control_connection_status_only();
CREATE TRIGGER source_control_connections_no_delete BEFORE DELETE ON organization_source_control_connections
 FOR EACH ROW EXECUTE FUNCTION af_reject('SOURCE_CONTROL_CONNECTION_IMMUTABLE');

CREATE TABLE repository_credential_leases (
 id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 connection_id text NOT NULL,
 provider text NOT NULL CHECK(provider IN ('github','bitbucket')),
 repository text NOT NULL CHECK(repository ~ '^[A-Za-z0-9][A-Za-z0-9_.-]{0,99}/[A-Za-z0-9_.-]{1,100}$'),
 repository_url text NOT NULL CHECK(repository_url ~ '^https://' AND length(repository_url) <= 2048),
 ref text NOT NULL CHECK(length(ref) BETWEEN 1 AND 200),
 operation_kind text NOT NULL CHECK(operation_kind='git.checkout'),
 operation_digest text NOT NULL CHECK(operation_digest ~ '^[a-f0-9]{64}$'),
 grant_id text NOT NULL UNIQUE,
 request_id text NOT NULL,
 run_id text NOT NULL,
 employee_id text NOT NULL,
 agent_id text NOT NULL,
 issued_to_runtime text NOT NULL,
 status text NOT NULL CHECK(status IN ('ISSUED','REDEEMED','RELEASED','REVOKED','EXPIRED')),
 issued_at timestamptz NOT NULL,
 expires_at timestamptz NOT NULL,
 redeemed_at timestamptz,
 redeemed_by text,
 released_at timestamptz,
 revoked_at timestamptz,
 revoked_by text,
 revoke_reason text CHECK(revoke_reason ~ '^[A-Z][A-Z0-9_]{1,63}$'),
 outcome text CHECK(outcome IN ('SUCCEEDED','FAILED','TIMED_OUT','CANCELLED','INTERRUPTED')),
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 CHECK(expires_at > issued_at),
 CHECK(status<>'ISSUED' OR (redeemed_at IS NULL AND released_at IS NULL AND revoked_at IS NULL)),
 CHECK((redeemed_at IS NULL) = (redeemed_by IS NULL)),
 CHECK(status<>'REDEEMED' OR redeemed_at IS NOT NULL),
 CHECK(status<>'RELEASED' OR (redeemed_at IS NOT NULL AND released_at IS NOT NULL)),
 CHECK(status<>'REVOKED' OR (revoked_at IS NOT NULL AND revoke_reason IS NOT NULL)),
 FOREIGN KEY(organization_id,connection_id)
  REFERENCES organization_source_control_connections(organization_id,id),
 FOREIGN KEY(request_id) REFERENCES agent_action_requests(id),
 FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id)
);
CREATE INDEX repository_credential_leases_live ON repository_credential_leases(expires_at)
 WHERE status IN ('ISSUED','REDEEMED');
CREATE INDEX repository_credential_leases_run ON repository_credential_leases(organization_id,run_id);
CREATE INDEX repository_credential_leases_recent ON repository_credential_leases(organization_id,seq);
CREATE FUNCTION af_repository_credential_lease_transition() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF (NEW.id, NEW.organization_id, NEW.connection_id, NEW.provider, NEW.repository,
      NEW.repository_url, NEW.ref, NEW.operation_kind, NEW.operation_digest, NEW.grant_id,
      NEW.request_id, NEW.run_id, NEW.employee_id, NEW.agent_id, NEW.issued_to_runtime,
      NEW.issued_at, NEW.expires_at)
     IS DISTINCT FROM
     (OLD.id, OLD.organization_id, OLD.connection_id, OLD.provider, OLD.repository,
      OLD.repository_url, OLD.ref, OLD.operation_kind, OLD.operation_digest, OLD.grant_id,
      OLD.request_id, OLD.run_id, OLD.employee_id, OLD.agent_id, OLD.issued_to_runtime,
      OLD.issued_at, OLD.expires_at) THEN
    RAISE EXCEPTION 'CREDENTIAL_LEASE_IMMUTABLE';
  END IF;
  IF NOT (
       (OLD.status='ISSUED' AND NEW.status IN ('REDEEMED','REVOKED','EXPIRED'))
    OR (OLD.status='REDEEMED' AND NEW.status IN ('RELEASED','REVOKED','EXPIRED'))
  ) THEN
    RAISE EXCEPTION 'CREDENTIAL_LEASE_TRANSITION_INVALID';
  END IF;
  IF OLD.redeemed_at IS NOT NULL AND (NEW.redeemed_at, NEW.redeemed_by)
     IS DISTINCT FROM (OLD.redeemed_at, OLD.redeemed_by) THEN
    RAISE EXCEPTION 'CREDENTIAL_LEASE_IMMUTABLE';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER repository_credential_leases_transition BEFORE UPDATE ON repository_credential_leases
 FOR EACH ROW EXECUTE FUNCTION af_repository_credential_lease_transition();
CREATE TRIGGER repository_credential_leases_no_delete BEFORE DELETE ON repository_credential_leases
 FOR EACH ROW EXECUTE FUNCTION af_reject('CREDENTIAL_LEASE_IMMUTABLE');

ALTER TABLE organization_source_control_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_source_control_connections FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON organization_source_control_connections
 USING (organization_id = af_current_organization())
 WITH CHECK (organization_id = af_current_organization());
ALTER TABLE repository_credential_leases ENABLE ROW LEVEL SECURITY;
ALTER TABLE repository_credential_leases FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON repository_credential_leases
 USING (organization_id = af_current_organization())
 WITH CHECK (organization_id = af_current_organization());

GRANT SELECT, INSERT, UPDATE ON organization_source_control_connections, repository_credential_leases
 TO af_tenant;
GRANT SELECT, INSERT, UPDATE, DELETE ON organization_source_control_connections,
 repository_credential_leases TO af_platform;


-- SOURCE: apps/control-plane-api/src/db/migrations/0012-run-recovery.ts

ALTER TABLE agent_run_leases ADD COLUMN recoveries integer NOT NULL DEFAULT 0 CHECK(recoveries>=0);
CREATE INDEX agent_run_leases_expiry ON agent_run_leases(lease_expires_at) WHERE state='ACTIVE';

CREATE TABLE agent_run_checkpoints (
 organization_id text NOT NULL REFERENCES organizations(id),
 run_id text NOT NULL,
 version integer NOT NULL CHECK(version>0),
 thread_id text NOT NULL,
 session_id text NOT NULL,
 runtime_id text NOT NULL CHECK(length(runtime_id) BETWEEN 1 AND 120),
 manifest_id text NOT NULL,
 manifest_digest text NOT NULL CHECK(manifest_digest ~ '^[a-f0-9]{64}$'),
 workflow text,
 step_id text,
 approval_id text,
 kernel_id text NOT NULL CHECK(length(kernel_id) BETWEEN 1 AND 100),
 runtime_sequence bigint NOT NULL CHECK(runtime_sequence>=0),
 body_sha256 text NOT NULL CHECK(body_sha256 ~ '^[a-f0-9]{64}$'),
 body_bytes integer NOT NULL CHECK(body_bytes BETWEEN 2 AND 8388608),
 body text NOT NULL,
 created_at timestamptz NOT NULL,
 PRIMARY KEY(run_id,version),
 FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
 FOREIGN KEY(organization_id,thread_id) REFERENCES agent_threads(organization_id,id),
 FOREIGN KEY(organization_id,step_id) REFERENCES agent_run_steps(organization_id,id)
);
CREATE FUNCTION af_checkpoint_next_version() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.version <> COALESCE(
       (SELECT max(version) FROM agent_run_checkpoints WHERE run_id=NEW.run_id), 0) + 1 THEN
    RAISE EXCEPTION 'CHECKPOINT_VERSION_CONFLICT';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER agent_run_checkpoints_next_version BEFORE INSERT ON agent_run_checkpoints
 FOR EACH ROW EXECUTE FUNCTION af_checkpoint_next_version();
CREATE TRIGGER agent_run_checkpoints_no_update BEFORE UPDATE ON agent_run_checkpoints
 FOR EACH ROW EXECUTE FUNCTION af_reject('CHECKPOINT_IMMUTABLE');

ALTER TABLE agent_run_checkpoints ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_run_checkpoints FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON agent_run_checkpoints
 USING (organization_id = af_current_organization())
 WITH CHECK (organization_id = af_current_organization());

GRANT SELECT, INSERT, DELETE ON agent_run_checkpoints TO af_tenant;
GRANT SELECT, INSERT, UPDATE, DELETE ON agent_run_checkpoints TO af_platform;


-- SOURCE: apps/control-plane-api/src/db/migrations/0013-artifact-objects.ts

CREATE TABLE agent_artifact_objects (
 artifact_id text PRIMARY KEY,
 organization_id text NOT NULL REFERENCES organizations(id),
 thread_id text NOT NULL,
 run_id text NOT NULL,
 step_id text NOT NULL,
 tool_call_id text,
 store text NOT NULL CHECK(store ~ '^[a-z0-9][a-z0-9-]{0,62}$'),
 storage_key text NOT NULL UNIQUE
  CHECK(storage_key ~ '^[A-Za-z0-9._/-]+$' AND length(storage_key) <= 512),
 media_type text NOT NULL CHECK(length(media_type) BETWEEN 3 AND 129),
 size_bytes bigint NOT NULL CHECK(size_bytes>=0),
 sha256 text NOT NULL CHECK(sha256 ~ '^[a-f0-9]{64}$'),
 retention_class text NOT NULL
  CHECK(retention_class IN ('EPHEMERAL','STANDARD_30D','EXTENDED_365D','LEGAL_HOLD')),
 state text NOT NULL CHECK(state IN ('PENDING','STORED','REGISTERED','DELETED')),
 uploaded_by text NOT NULL CHECK(length(uploaded_by) BETWEEN 1 AND 120),
 created_at timestamptz NOT NULL,
 registered_at timestamptz,
 expires_at timestamptz,
 deleted_at timestamptz,
 deletion_reason text CHECK(deletion_reason ~ '^[A-Z][A-Z0-9_]{1,63}$'),
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 CHECK((retention_class='LEGAL_HOLD') = (expires_at IS NULL)),
 CHECK(state<>'REGISTERED' OR registered_at IS NOT NULL),
 CHECK((state='DELETED') = (deleted_at IS NOT NULL)),
 CHECK((deleted_at IS NULL) = (deletion_reason IS NULL)),
 FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
 FOREIGN KEY(organization_id,thread_id) REFERENCES agent_threads(organization_id,id),
 FOREIGN KEY(organization_id,step_id) REFERENCES agent_run_steps(organization_id,id)
);
CREATE INDEX agent_artifact_objects_run ON agent_artifact_objects(organization_id,run_id);
CREATE INDEX agent_artifact_objects_due ON agent_artifact_objects(expires_at)
 WHERE state='REGISTERED';
CREATE INDEX agent_artifact_objects_unregistered ON agent_artifact_objects(created_at)
 WHERE state IN ('PENDING','STORED');
CREATE TRIGGER agent_artifact_objects_scope BEFORE INSERT ON agent_artifact_objects
 FOR EACH ROW EXECUTE FUNCTION run_scope_check('ARTIFACT_SCOPE_MISMATCH');
CREATE FUNCTION af_artifact_object_transition() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF (NEW.artifact_id, NEW.organization_id, NEW.thread_id, NEW.run_id, NEW.step_id,
      NEW.tool_call_id, NEW.store, NEW.storage_key, NEW.media_type, NEW.size_bytes, NEW.sha256,
      NEW.retention_class, NEW.uploaded_by, NEW.created_at, NEW.expires_at)
     IS DISTINCT FROM
     (OLD.artifact_id, OLD.organization_id, OLD.thread_id, OLD.run_id, OLD.step_id,
      OLD.tool_call_id, OLD.store, OLD.storage_key, OLD.media_type, OLD.size_bytes, OLD.sha256,
      OLD.retention_class, OLD.uploaded_by, OLD.created_at, OLD.expires_at) THEN
    RAISE EXCEPTION 'ARTIFACT_OBJECT_IMMUTABLE';
  END IF;
  IF NOT (
       (OLD.state='PENDING' AND NEW.state IN ('STORED','DELETED'))
    OR (OLD.state='STORED' AND NEW.state IN ('REGISTERED','DELETED'))
    OR (OLD.state='REGISTERED' AND NEW.state='DELETED')
  ) THEN
    RAISE EXCEPTION 'ARTIFACT_OBJECT_TRANSITION_INVALID';
  END IF;
  IF OLD.registered_at IS NOT NULL AND NEW.registered_at IS DISTINCT FROM OLD.registered_at THEN
    RAISE EXCEPTION 'ARTIFACT_OBJECT_IMMUTABLE';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER agent_artifact_objects_transition BEFORE UPDATE ON agent_artifact_objects
 FOR EACH ROW EXECUTE FUNCTION af_artifact_object_transition();
CREATE TRIGGER agent_artifact_objects_no_delete BEFORE DELETE ON agent_artifact_objects
 FOR EACH ROW EXECUTE FUNCTION af_reject('ARTIFACT_OBJECT_RETAINED');

ALTER TABLE agent_artifact_objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_artifact_objects FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON agent_artifact_objects
 USING (organization_id = af_current_organization())
 WITH CHECK (organization_id = af_current_organization());

GRANT SELECT, INSERT, UPDATE ON agent_artifact_objects TO af_tenant;
GRANT SELECT, INSERT, UPDATE, DELETE ON agent_artifact_objects TO af_platform;


-- SOURCE: apps/control-plane-api/src/db/migrations/0014-model-credentials.ts

CREATE TABLE organization_model_credentials (
 organization_id text NOT NULL REFERENCES organizations(id),
 provider text NOT NULL CHECK(provider ~ '^[a-zA-Z0-9._-]{1,80}$'),
 secret_ref text NOT NULL CHECK(secret_ref ~ '^secret://[a-z0-9][a-z0-9._-]{0,63}$'),
 status text NOT NULL CHECK(status IN ('ACTIVE','DISABLED')),
 version bigint NOT NULL DEFAULT 1 CHECK(version>0),
 created_by text NOT NULL,
 created_at timestamptz NOT NULL,
 updated_by text NOT NULL,
 updated_at timestamptz NOT NULL,
 PRIMARY KEY(organization_id,provider),
 FOREIGN KEY(organization_id,created_by) REFERENCES employees(organization_id,id),
 FOREIGN KEY(organization_id,updated_by) REFERENCES employees(organization_id,id)
);
CREATE TRIGGER organization_model_credentials_identity_immutable
 BEFORE UPDATE OF organization_id, provider, created_by, created_at ON organization_model_credentials
 FOR EACH ROW EXECUTE FUNCTION af_reject('MODEL_CREDENTIAL_IDENTITY_IMMUTABLE');
CREATE TRIGGER organization_model_credentials_no_delete BEFORE DELETE ON organization_model_credentials
 FOR EACH ROW EXECUTE FUNCTION af_reject('MODEL_CREDENTIAL_RETAINED');

ALTER TABLE organization_model_credentials ENABLE ROW LEVEL SECURITY;
ALTER TABLE organization_model_credentials FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON organization_model_credentials
 USING (organization_id = af_current_organization())
 WITH CHECK (organization_id = af_current_organization());

GRANT SELECT, INSERT, UPDATE ON organization_model_credentials TO af_tenant;
GRANT SELECT, INSERT, UPDATE, DELETE ON organization_model_credentials TO af_platform;


-- SOURCE: apps/control-plane-api/src/db/migrations/0015-action-reconciliation.ts

CREATE TABLE agent_action_reconciliations (
 request_id text PRIMARY KEY REFERENCES agent_action_executions(request_id),
 organization_id text NOT NULL REFERENCES organizations(id),
 thread_id text NOT NULL,
 run_id text NOT NULL,
 action text NOT NULL CHECK(action ~ '^[a-z][a-z0-9_.]+$' AND length(action) <= 120),
 payload_digest text NOT NULL CHECK(payload_digest ~ '^[a-f0-9]{64}$'),
 reason text NOT NULL CHECK(reason IN ('CONNECTOR_OUTCOME_UNKNOWN','DISPATCH_INTERRUPTED')),
 state text NOT NULL CHECK(state IN ('REQUIRED','APPLIED','NOT_APPLIED')),
 created_at timestamptz NOT NULL,
 resolved_by text,
 resolved_at timestamptz,
 note text CHECK(note IS NULL OR length(note) <= 500),
 seq bigint GENERATED ALWAYS AS IDENTITY UNIQUE,
 CHECK((state='REQUIRED') = (resolved_at IS NULL)),
 CHECK((resolved_at IS NULL) = (resolved_by IS NULL)),
 FOREIGN KEY(organization_id,run_id) REFERENCES agent_runs(organization_id,id),
 FOREIGN KEY(organization_id,thread_id) REFERENCES agent_threads(organization_id,id),
 FOREIGN KEY(organization_id,resolved_by) REFERENCES employees(organization_id,id)
);
CREATE INDEX agent_action_reconciliations_payload
 ON agent_action_reconciliations(organization_id,action,payload_digest) WHERE state='REQUIRED';
CREATE INDEX agent_action_reconciliations_thread
 ON agent_action_reconciliations(organization_id,thread_id,action) WHERE state='REQUIRED';
CREATE FUNCTION af_action_reconciliation_transition() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF OLD.state<>'REQUIRED' OR NEW.state NOT IN ('APPLIED','NOT_APPLIED')
     OR (NEW.request_id, NEW.organization_id, NEW.thread_id, NEW.run_id, NEW.action,
         NEW.payload_digest, NEW.reason, NEW.created_at)
        IS DISTINCT FROM
        (OLD.request_id, OLD.organization_id, OLD.thread_id, OLD.run_id, OLD.action,
         OLD.payload_digest, OLD.reason, OLD.created_at) THEN
    RAISE EXCEPTION 'ACTION_RECONCILIATION_FINAL';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER agent_action_reconciliations_transition BEFORE UPDATE ON agent_action_reconciliations
 FOR EACH ROW EXECUTE FUNCTION af_action_reconciliation_transition();
CREATE TRIGGER agent_action_reconciliations_no_delete BEFORE DELETE ON agent_action_reconciliations
 FOR EACH ROW EXECUTE FUNCTION af_reject('ACTION_RECONCILIATION_RETAINED');

ALTER TABLE agent_action_reconciliations ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_action_reconciliations FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation ON agent_action_reconciliations
 USING (organization_id = af_current_organization())
 WITH CHECK (organization_id = af_current_organization());

GRANT SELECT, INSERT, UPDATE ON agent_action_reconciliations TO af_tenant;
GRANT SELECT, INSERT, UPDATE, DELETE ON agent_action_reconciliations TO af_platform;
