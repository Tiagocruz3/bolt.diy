#!/bin/bash
set -e

echo "Building application..."
npm run build

echo "Deploying to Cloudflare Pages..."
npx wrangler pages deploy ./build/client --project-name=bolt

echo "Deployment complete!"
