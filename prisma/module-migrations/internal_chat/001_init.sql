-- ============================================================
-- Módulo: Chat Interno (internal_chat)
-- Aplicado apenas quando o módulo está habilitado para o tenant.
-- ============================================================

-- Canais de chat (salas). O banco já é da empresa (tenant), não precisa de company_id.
CREATE TABLE IF NOT EXISTS chat_channels (
  id TEXT NOT NULL PRIMARY KEY DEFAULT gen_random_uuid()::text,
  name TEXT NOT NULL,
  description TEXT,
  is_private BOOLEAN NOT NULL DEFAULT false,
  created_by_employee_id TEXT NOT NULL REFERENCES employees(id) ON DELETE RESTRICT,
  created_at TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS chat_channels_created_by_employee_id_idx ON chat_channels(created_by_employee_id);

-- Membros do canal (quem participa de cada canal)
CREATE TABLE IF NOT EXISTS chat_channel_members (
  id TEXT NOT NULL PRIMARY KEY DEFAULT gen_random_uuid()::text,
  channel_id TEXT NOT NULL REFERENCES chat_channels(id) ON DELETE CASCADE,
  employee_id TEXT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'member')),
  joined_at TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chat_channel_members_channel_employee_unique UNIQUE (channel_id, employee_id)
);

CREATE INDEX IF NOT EXISTS chat_channel_members_channel_id_idx ON chat_channel_members(channel_id);
CREATE INDEX IF NOT EXISTS chat_channel_members_employee_id_idx ON chat_channel_members(employee_id);

-- Mensagens
CREATE TABLE IF NOT EXISTS chat_messages (
  id TEXT NOT NULL PRIMARY KEY DEFAULT gen_random_uuid()::text,
  channel_id TEXT NOT NULL REFERENCES chat_channels(id) ON DELETE CASCADE,
  employee_id TEXT NOT NULL REFERENCES employees(id) ON DELETE RESTRICT,
  content TEXT NOT NULL,
  created_at TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS chat_messages_channel_id_idx ON chat_messages(channel_id);
CREATE INDEX IF NOT EXISTS chat_messages_channel_id_created_at_idx ON chat_messages(channel_id, created_at DESC);
CREATE INDEX IF NOT EXISTS chat_messages_employee_id_idx ON chat_messages(employee_id);
