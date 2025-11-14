# Terraform Cloud Authentication Setup

## Problem
If you see the error:
```
Error: Failed to read organization "babalola" at host app.terraform.io
The "remote" backend encountered an unexpected error while reading the organization settings: unauthorized
```

This means Terraform is not authenticated with Terraform Cloud.

## Solution Options

### Option 1: Interactive Login (Recommended for Local Development)

Run this command in your terminal:
```bash
terraform login
```

This will:
1. Open your browser to Terraform Cloud
2. Generate an API token
3. Save it to `~/.terraform.d/credentials.tfrc.json`

### Option 2: Manual Token Setup

1. **Get your Terraform Cloud API token:**
   - Go to https://app.terraform.io
   - Navigate to **User Settings** → **Tokens**
   - Click **Create an API token**
   - Copy the token (you won't see it again!)

2. **Set the token as an environment variable:**
   ```bash
   export TF_TOKEN_app_terraform_io="your-token-here"
   ```

3. **Or add it to your shell profile** (e.g., `~/.zshrc` or `~/.bashrc`):
   ```bash
   echo 'export TF_TOKEN_app_terraform_io="your-token-here"' >> ~/.zshrc
   source ~/.zshrc
   ```

### Option 3: Credentials File

Create the credentials file manually:

```bash
mkdir -p ~/.terraform.d
cat > ~/.terraform.d/credentials.tfrc.json << EOF
{
  "credentials": {
    "app.terraform.io": {
      "token": "your-token-here"
    }
  }
}
EOF
```

## Verify Authentication

After setting up authentication, verify it works:

```bash
cd /Users/opeyemibabalola/Desktop/Workspace/opeyemi/infra/hetzner
terraform init -backend-config=environments/dev/backend-config.hcl
```

## For GitHub Actions

The GitHub Actions workflow uses the `TF_TOKEN_app_terraform_io` secret. Make sure you've added this secret in your GitHub repository settings.

## Troubleshooting

- **Wrong organization**: Make sure the organization name in `environments/dev/backend-config.hcl` matches your Terraform Cloud organization
- **Token expired**: Generate a new token if your old one expired
- **No workspace**: Make sure the workspace `babalolas-infra` exists in your Terraform Cloud organization


