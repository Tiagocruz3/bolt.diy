# Cloudflare Pages Deployment Guide

This application is configured to deploy to **Cloudflare Pages** (not Workers).

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
