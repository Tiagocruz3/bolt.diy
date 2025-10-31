# Cloudflare Dashboard Error Fix Guide

If you're getting "An internal error prevented the form from submitting" when trying to save the Build configuration, try these solutions:

## Solution 1: Browser Troubleshooting

1. **Hard Refresh the Page**
   - Windows/Linux: `Ctrl + Shift + R`
   - Mac: `Cmd + Shift + R`

2. **Clear Browser Cache**
   - Go to browser settings
   - Clear cache for cloudflare.com
   - Refresh the page

3. **Try a Different Browser**
   - If using Chrome, try Firefox or Edge
   - Or try an Incognito/Private window

4. **Disable Browser Extensions**
   - Ad blockers or privacy extensions might interfere
   - Try disabling them temporarily

## Solution 2: Dashboard Alternative Steps

Instead of editing all fields at once, try editing them one at a time:

1. First, clear the "Non-production branch deploy command" field ONLY
2. Save
3. Then update the "Deploy command" field
4. Save again

## Solution 3: Delete and Reconnect Git Integration

If the above doesn't work:

1. In your Cloudflare Pages dashboard, go to **Settings → Build → General**
2. Scroll to the bottom and click **"Disconnect"** from Git repository
3. Wait a few seconds
4. Click **"Connect to Git"** again
5. Select your repository `Tiagocruz3/bolt.diy`
6. In the setup wizard, configure:
   - **Build command:** `pnpm run build`
   - **Build output directory:** `build/client`
   - **Production branch:** `main`
   - Leave deploy commands **EMPTY**

## Solution 4: Use Wrangler CLI (Easiest!)

Deploy directly from your local machine without using the dashboard:

```bash
# 1. Install Wrangler globally (if not installed)
npm install -g wrangler

# 2. Login to Cloudflare
wrangler login

# 3. Build your project
pnpm run build

# 4. Deploy to Pages
wrangler pages deploy ./build/client --project-name=brainiac-ide
```

## Solution 5: Contact Cloudflare Support

If none of the above works, this might be a Cloudflare dashboard bug. You can:

1. Go to: https://dash.cloudflare.com/?to=/:account/support
2. Click "Create a ticket"
3. Describe the issue: "Cannot save Build configuration settings - getting internal error"

## Solution 6: Temporary Workaround - Deploy from CLI

While Cloudflare fixes the dashboard issue, you can deploy directly:

```bash
# From your local machine:
npm run build
npx wrangler pages deploy ./build/client --project-name=brainiac-ide --branch=main
```

Or use the deploy script we created:
```bash
./deploy-cloudflare.sh
```

---

## What We Fixed in wrangler.toml

The repository now has the correct `wrangler.toml` configuration:
- Project name matches dashboard: `brainiac-ide`
- Compatibility date updated: `2025-10-31`
- Pages output directory: `./build/client`
- Comments added explaining this is a Pages project

Once you can save the dashboard settings or use the CLI deployment, everything should work!
