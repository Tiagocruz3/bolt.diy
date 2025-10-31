# Cloudflare Pages Deployment Guide

This application is configured to deploy to **Cloudflare Pages** (not Workers).

## ✅ Build Status

The build is working correctly!
- Build time: ~1m 18s
- Build output: `build/client`
- Memory optimizations: ✓ Working

## ⚠️ Current Issue

Your Cloudflare Pages project has the **WRONG deployment command** configured:

**Current (❌ WRONG):**
```
npx wrangler versions upload
```

This is a **Workers** command, not a **Pages** command!

## 🔧 How to Fix - Cloudflare Pages Dashboard

### Step-by-Step Instructions:

1. **Go to Cloudflare Dashboard**
   - URL: https://dash.cloudflare.com/

2. **Navigate to your Pages project**
   - Click: **Workers & Pages** in the left sidebar
   - Find and click your project (likely named "bolt")

3. **Go to Settings**
   - Click: **Settings** tab
   - Click: **Builds & deployments** section

4. **Update Build Settings**

   Set these values:

   | Setting | Value |
   |---------|-------|
   | **Framework preset** | Remix |
   | **Build command** | `npm run build` or `pnpm run build` |
   | **Build output directory** | `build/client` |

5. **⚠️ CRITICAL: Remove/Fix Deploy Command**

   Look for any field labeled:
   - "Deploy command"
   - "Custom deploy command"
   - "Post-build command"

   **If you see `npx wrangler versions upload` or similar:**

   ❌ **DELETE IT** or **LEAVE IT EMPTY**

   Cloudflare Pages will automatically deploy the `build/client` directory.

   **OR** if you must have a deploy command, use:
   ```
   npx wrangler pages deploy ./build/client
   ```

6. **Optional: Add Environment Variable**

   Go to: **Settings → Environment Variables → Production**

   Add:
   ```
   NODE_OPTIONS = --max-old-space-size=8192
   ```

7. **Save and Deploy**
   - Click **Save**
   - Go to **Deployments** tab
   - Click **Create deployment** to trigger a new build

## Build Configuration

The build process has been optimized to prevent out-of-memory errors:
- Node.js heap size increased to 8GB
- Manual chunking for large vendor dependencies
- Optimized parallel file operations

## Deployment Steps

### Option 1: Using the Deploy Script (Recommended)

```bash
./deploy-cloudflare.sh
```

### Option 2: Manual Deployment

```bash
# Build the application
npm run build

# Deploy to Cloudflare Pages
npx wrangler pages deploy ./build/client --project-name=bolt
```

### Option 3: Using npm script

```bash
npm run deploy
```

## Cloudflare Pages Dashboard Configuration

If you're deploying via the Cloudflare Pages dashboard, ensure the following settings:

### Build Settings

- **Framework preset**: Remix
- **Build command**: `npm run build`
- **Build output directory**: `build/client`
- **Root directory**: `/` (or leave empty)
- **Node version**: 18 or higher

### Environment Variables

Set `NODE_OPTIONS` to `--max-old-space-size=8192` in the dashboard under:
Settings → Environment Variables → Production

### Deployment Command

**IMPORTANT**: If you have a custom deployment command configured, it should be:

```bash
npx wrangler pages deploy ./build/client
```

**NOT** `npx wrangler versions upload` (that's for Workers, not Pages)

## Troubleshooting

### "Missing entry-point to Worker script" Error

This error occurs when trying to use Workers deployment commands on a Pages project.

**Solution**: Use `wrangler pages deploy` instead of `wrangler versions upload`

### Out of Memory Errors

If you still encounter OOM errors:

1. Increase the Node.js memory limit in package.json:
   ```json
   "build": "NODE_OPTIONS='--max-old-space-size=12288' remix vite:build"
   ```

2. Or set the environment variable in your deployment platform:
   ```
   NODE_OPTIONS=--max-old-space-size=12288
   ```

## Project Structure

```
bolt.diy/
├── build/
│   ├── client/         # Static assets (deployed to Pages)
│   └── server/         # Server-side code
├── functions/
│   └── [[path]].ts     # Cloudflare Pages Functions handler
├── app/                # Remix application code
└── wrangler.toml       # Cloudflare configuration
```

## Additional Resources

- [Cloudflare Pages Documentation](https://developers.cloudflare.com/pages/)
- [Remix on Cloudflare Pages](https://remix.run/docs/en/main/guides/deployment#cloudflare-pages)
- [Wrangler CLI Documentation](https://developers.cloudflare.com/workers/wrangler/)
