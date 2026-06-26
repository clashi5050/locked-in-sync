# Deploy runbook — Lock In on Azure (Terraform + GitHub Actions)

This stands up everything in Terraform and deploys it from GitHub Actions:

| Resource | Terraform | Free? |
|---|---|---|
| Resource group | `azurerm_resource_group` | yes |
| Storage account (runtime + data) | `azurerm_storage_account` | ~free at this scale |
| Table (your dashboard state) | `azurerm_storage_table` | ~free |
| Consumption plan | `azurerm_service_plan` (Y1) | yes (1M exec/mo) |
| Function App (the API) | `azurerm_linux_function_app` | yes |
| Static Web App (the frontend) | `azurerm_static_web_app` (Free) | yes |

Your data is one JSON row in Table Storage. The dashboard talks to two endpoints —
`GET /api/state` and `POST /api/state` — both guarded by a shared secret you set.

---

## One-time setup

### 1. Remote state backend
This repo can't use its own Terraform backend to create the storage account that backend
lives in, so there's a separate one-time bootstrap module with local state:
```bash
cd bootstrap
terraform init
terraform apply
```
Note the `tfstate_storage_account_name` output — that's the value you'll put in the
`TFSTATE_SA` GitHub variable in step 3. Then, for local `terraform` runs against the main
config (CI generates its own `backend.hcl` from `TFSTATE_SA`), copy `backend.hcl.example`
to `backend.hcl` and fill in that same account name.

### 2. App registration for OIDC
Create an Azure AD app + service principal, grant it **Contributor** on the subscription
(or target RG) **and Storage Blob Data Contributor** on the tfstate storage account from
step 1 (the backend uses Azure AD auth, not storage keys). Then add a **federated
credential** so GitHub can log in with no secret:
- **Entity type**: Environment (not Branch) — the workflow's jobs each set `environment: dev`,
  so GitHub's OIDC token subject is environment-scoped regardless of which branch ran it.
- **Subject identifier** (auto-generated once you pick Environment + `dev`):
```
repo:<OWNER>/<REPO>:environment:dev
```

### 3. GitHub repo config
- Create an **Environment** named `dev` (Settings → Environments).
- Add these **secrets** (repo or environment scope):
  - `ARM_CLIENT_ID`
  - `ARM_SUBSCRIPTION_ID`
  - `ARM_TENANT_ID`
  - `APP_SHARED_SECRET`  ← invent a long random string; this is your app password.
- Add a repo or environment **variable** (not secret):
  - `TFSTATE_SA` ← the tfstate storage account name from step 1.

---

## Deploy

Push to `main`, or run the **Deploy Lock In** workflow manually. It runs three jobs:
1. `terraform` — provisions/updates all infra, prints the Function + dashboard URLs.
2. `deploy-api` — zips `api/` and deploys the functions.
3. `deploy-web` — uploads `index.html` to the Static Web App.

Grab the two URLs from the `terraform` job log (or `terraform output`).

---

## Connect the dashboard

1. Open your dashboard URL (the Static Web App).
2. Click the **☁ LOCAL ONLY** pill (top-right) → **Cloud sync** panel.
3. Paste the **Function base URL** (e.g. `https://func-lockin-dev-xxxxx.azurewebsites.net`)
   and your **APP_SHARED_SECRET**, then **Save & sync**.
4. The pill turns green (**SYNCED**). Set the same two values on your phone/other laptop and
   they all share one record. Values live in that browser's localStorage only.

---

## Honest caveats / hardening

- **Auth is a shared secret, not real identity.** Fine for a personal habit tracker. The secret
  is entered by you in the UI (not baked into the public site), so it isn't exposed in page source.
  To harden: turn on **App Service Authentication (Easy Auth) with Entra ID** on the function
  (`auth_settings_v2` in Terraform) and log in with your Microsoft account, or move to SWA
  **Standard** ($9/mo) and use linked-backend auth.
- **Conflict model is last-write-wins** on the whole state blob (by `updatedAt`). Editing two
  devices while both are offline can lose one side's changes. Single user, rarely an issue.
- **Cost:** Consumption Functions + Table + SWA Free = effectively $0. Watch only if traffic
  somehow explodes (it won't, it's you).
- **Make this a Receipt.** Infra-as-code + CI/CD + a managed app is exactly the senior-level
  evidence to demo to your manager. Log it.
