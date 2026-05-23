# Checklist de Mentoria

Ferramenta de acompanhamento de checklist para mentoradas — com login, fases personalizáveis, evidências e painel da mentora.

## Estrutura de arquivos

```
checklist-mentoria/
├── index.html          ← app completo
├── config.js           ← suas credenciais (NÃO vai pro git)
├── config.example.js   ← modelo do config (vai pro git)
├── schema.sql          ← SQL para rodar no Supabase
├── .gitignore          ← protege o config.js
└── README.md
```

---

## Passo 1 — Configurar o Supabase

1. Acesse seu projeto em [supabase.com](https://supabase.com)
2. Vá em **SQL Editor** (menu lateral)
3. Cole todo o conteúdo de `schema.sql` e clique em **Run**
4. Vá em **Settings → API**
5. Copie a **Project URL** e a **anon public key**

---

## Passo 2 — Criar o config.js

Copie o arquivo de exemplo e preencha com suas credenciais:

```bash
cp config.example.js config.js
```

Edite o `config.js`:

```js
const SUPABASE_URL = 'https://SEU-PROJETO.supabase.co'
const SUPABASE_ANON_KEY = 'sua-anon-key-aqui'
```

> ⚠️ O `config.js` está no `.gitignore` — nunca será enviado ao GitHub.

---

## Passo 3 — Subir no GitHub

```bash
git init
git add .
git commit -m "primeiro commit"
git branch -M main
git remote add origin https://github.com/SEU-USUARIO/checklist-mentoria.git
git push -u origin main
```

Depois, no repositório do GitHub:
- Vá em **Settings → Pages**
- Source: **Deploy from a branch**
- Branch: **main / (root)**
- Clique em **Save**

Em alguns minutos o site estará em:
`https://SEU-USUARIO.github.io/checklist-mentoria`

---

## Passo 4 — Criar a conta da mentora (Raissa)

O sistema diferencia mentora de mentorada pela coluna `role` no banco.

Para criar a conta da mentora com acesso ao painel:

1. No Supabase, vá em **Authentication → Users → Add user**
2. Preencha e-mail e senha da Raissa
3. Depois, no **SQL Editor**, rode:

```sql
update public.profiles
set role = 'mentora', nome = 'Raissa'
where id = 'UUID-DO-USUARIO-AQUI';
```

(O UUID aparece na lista de usuários em Authentication → Users)

---

## Passo 5 — Convidar mentoradas

Cada mentorada acessa o site, clica em **Criar conta** e preenche nome, e-mail e senha. O perfil é criado automaticamente como `mentorada`.

Você pode mandar o link do site pelo WhatsApp com uma mensagem simples:
> "Acesse [link] e crie sua conta com seu e-mail para acessar seu checklist."

---

## Como usar

**Mentorada:**
- Faz login
- Cria suas fases (ex: "Posicionamento", "Captação")
- Dentro de cada fase, adiciona as tarefas
- Marca tarefas como concluídas
- Adiciona link de evidência em cada tarefa (Google Drive, Notion, Instagram...)

**Mentora (Raissa):**
- Faz login com a conta dela
- Vê o painel com todas as mentoradas e o progresso de cada uma
- Clica em qualquer mentorada para ver o checklist detalhado em modo leitura

---

## Segurança

- Cada mentorada vê e edita **apenas seus próprios dados** (Row Level Security)
- A mentora vê **todos os dados em modo leitura**
- As credenciais do Supabase ficam no `config.js` que **não vai ao Git**
- Senhas são gerenciadas pelo Supabase Auth (nunca armazenadas em texto)
