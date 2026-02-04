-- Seed: permissões padrão do sistema (idempotente)
-- Depois: para cada empresa, garante que o cargo "Administrador" existe e tem todas as permissões

-- 1) Inserir permissões (ignora se já existir pelo code)
INSERT INTO permissions (id, code, name, description, module, "createdAt")
VALUES
  (gen_random_uuid()::text, 'employees.view', 'Ver funcionários', NULL, 'employees', CURRENT_TIMESTAMP),
  (gen_random_uuid()::text, 'employees.create', 'Criar funcionários', NULL, 'employees', CURRENT_TIMESTAMP),
  (gen_random_uuid()::text, 'employees.edit', 'Editar funcionários', NULL, 'employees', CURRENT_TIMESTAMP),
  (gen_random_uuid()::text, 'employees.delete', 'Excluir funcionários', NULL, 'employees', CURRENT_TIMESTAMP),
  (gen_random_uuid()::text, 'employees.manage_access', 'Gerenciar acesso ao sistema', NULL, 'employees', CURRENT_TIMESTAMP),
  (gen_random_uuid()::text, 'roles.view', 'Ver perfis', NULL, 'roles', CURRENT_TIMESTAMP),
  (gen_random_uuid()::text, 'roles.manage', 'Gerenciar perfis', NULL, 'roles', CURRENT_TIMESTAMP),
  (gen_random_uuid()::text, 'settings.view', 'Ver configurações', NULL, 'settings', CURRENT_TIMESTAMP),
  (gen_random_uuid()::text, 'settings.manage', 'Gerenciar configurações', NULL, 'settings', CURRENT_TIMESTAMP)
ON CONFLICT (code) DO NOTHING;

-- 2) Para cada empresa, criar cargo "Administrador" se não existir
INSERT INTO roles (id, name, description, "isActive", "companyId", "createdAt", "updatedAt")
SELECT gen_random_uuid()::text, 'Administrador', 'Acesso total ao sistema', true, c.id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM companies c
WHERE NOT EXISTS (
  SELECT 1 FROM roles r WHERE r."companyId" = c.id AND r.name = 'Administrador'
);

-- 3) Associar todas as permissões ao cargo Administrador (para cada empresa)
INSERT INTO role_permissions (id, "roleId", "permissionId", "createdAt")
SELECT gen_random_uuid()::text, r.id, p.id, CURRENT_TIMESTAMP
FROM roles r
CROSS JOIN permissions p
WHERE r.name = 'Administrador'
  AND NOT EXISTS (
    SELECT 1 FROM role_permissions rp
    WHERE rp."roleId" = r.id AND rp."permissionId" = p.id
  );
