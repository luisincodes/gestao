# Gestão de Demandas — versão segura em nuvem

Sistema React + Vite + Supabase para uso interno de equipe.

## O que foi incluído
- Login por e-mail e senha via Supabase Auth.
- Recuperação de senha.
- Sessão persistente.
- PostgreSQL na nuvem.
- Row Level Security (RLS).
- Perfis administrador/equipe.
- Dashboard responsivo para PC e celular.
- Demandas, filtros, status, prioridades, prazos e observações.
- Relatórios com gráficos.
- Gestão de canais/categorias para administradores.
- Estrutura pronta para evolução com auditoria, MFA e anexos.

## Instalação
1. Instale Node.js LTS.
2. Abra a pasta no VS Code.
3. Rode `npm install`.
4. Copie `.env.example` para `.env.local`.
5. Crie um projeto em Supabase.
6. No Supabase, abra SQL Editor e execute `supabase/schema.sql`.
7. Coloque em `.env.local` a URL e a chave `anon` pública do Supabase.
8. Rode `npm run dev`.

## Primeiro administrador
Crie sua conta pela autenticação do Supabase. Depois execute no SQL Editor:

`update public.profiles set role='admin' where id=(select id from auth.users where email='SEU_EMAIL');`

## Publicação
Pode ser publicado em Netlify, Vercel ou outro host de frontend. Configure as mesmas variáveis `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY` nas variáveis de ambiente da hospedagem.

## Segurança
Nunca coloque a `service_role` do Supabase no frontend. Somente a chave anon/publica deve aparecer no navegador. O controle de acesso real é feito pelas policies RLS do banco.

Antes de uso definitivo com dados sensíveis, recomenda-se ativar MFA no Supabase, revisar as políticas conforme a regra da equipe, ativar proteção de senha/segurança da conta e configurar backups/retention do projeto.
