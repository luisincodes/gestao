# Checklist de segurança antes de uso real

1. Use somente HTTPS na hospedagem.
2. Nunca publique `SUPABASE_SERVICE_ROLE_KEY` no frontend.
3. Use apenas `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY` no frontend.
4. Execute o `supabase/schema.sql` e confira as policies no painel do Supabase.
5. Crie o primeiro usuário e promova-o a `admin` conforme o README.
6. Ative MFA no Supabase para contas administrativas.
7. Ative proteção contra senhas comprometidas e políticas fortes de senha disponíveis no projeto.
8. Mantenha Node, Vite, React e dependências atualizados.
9. Configure backups do banco conforme o plano do Supabase.
10. Não compartilhe contas: cada integrante deve ter seu próprio usuário.
11. Se o sistema passar a armazenar anexos, crie um bucket privado com policies próprias; não use bucket público para documentos internos.
12. Faça testes periódicos de acesso com usuário `member` e `admin`.
