import { cloudflareDevProxyVitePlugin as remixCloudflareDevProxy, vitePlugin as remixVitePlugin } from '@remix-run/dev';
import UnoCSS from 'unocss/vite';
import { defineConfig, type ViteDevServer } from 'vite';
import { nodePolyfills } from 'vite-plugin-node-polyfills';
import { optimizeCssModules } from 'vite-plugin-optimize-css-modules';
import tsconfigPaths from 'vite-tsconfig-paths';
import * as dotenv from 'dotenv';

// Load environment variables from multiple files
dotenv.config({ path: '.env.local' });
dotenv.config({ path: '.env' });
dotenv.config();

export default defineConfig((config) => {
  const isCloudflarePages = Boolean(process.env.CF_PAGES);
  return {
    define: {
      'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV),
    },
    build: {
      target: 'esnext',
      // Explicitly disable sourcemaps to reduce memory usage during CI builds
      sourcemap: false,
      // Leaner CF Pages builds to prevent OOM during Rollup/minification steps
      minify: isCloudflarePages ? false : undefined,
      cssMinify: isCloudflarePages ? false : undefined,
      reportCompressedSize: isCloudflarePages ? false : true,
      // Reduce memory pressure in Rollup by aggressively splitting vendor chunks
      rollupOptions: {
        output: {
          manualChunks(id) {
            if (isCloudflarePages) return undefined; // let Rollup decide on CF to keep memory lower
            if (!id || !id.includes('node_modules')) return undefined;

            // Group by top-level package folder to avoid gigantic graphs
            // e.g. node_modules/react/index.js -> vendor-react
            // pnpm paths look like node_modules/.pnpm/<pkg>@<ver>/node_modules/<pkg>/...
            const afterFirstNodeModules = id.split('node_modules/')[1];
            if (!afterFirstNodeModules) return undefined;

            const normalized = afterFirstNodeModules.startsWith('.pnpm/')
              ? afterFirstNodeModules.split('/node_modules/')[1] || afterFirstNodeModules
              : afterFirstNodeModules;

            const segments = normalized.split('/');
            // Scoped packages keep two segments like @scope/pkg
            const scopeOrPkg = segments[0]?.startsWith('@') && segments[1]
              ? `${segments[0]}/${segments[1]}`
              : segments[0];

            // Bucket a few known heavy groups explicitly
            if (scopeOrPkg.startsWith('@codemirror') || scopeOrPkg === 'codemirror') return 'vendor-codemirror';
            if (scopeOrPkg.startsWith('@xterm') || scopeOrPkg === 'xterm') return 'vendor-xterm';
            if (scopeOrPkg === 'shiki') return 'vendor-shiki';
            if (scopeOrPkg === 'isomorphic-git') return 'vendor-git';
            if (scopeOrPkg === 'chart.js') return 'vendor-chartjs';
            if (scopeOrPkg.startsWith('@radix-ui')) return 'vendor-radix';
            if (scopeOrPkg.startsWith('@remix-run')) return 'vendor-remix';
            if (scopeOrPkg === 'react' || scopeOrPkg === 'react-dom') return 'vendor-react';

            return `vendor-${scopeOrPkg.replace('@', '').replace('/', '-')}`;
          },
        },
      },
    },
    resolve: {
      // Ensure browser-compatible implementation for Node's "path" module
      alias: {
        path: 'path-browserify',
      },
    },
    plugins: [
      nodePolyfills({
        include: ['buffer', 'process', 'util', 'stream', 'path'],
        globals: {
          Buffer: true,
          process: true,
          global: true,
        },
        protocolImports: true,
        // Do not exclude "path" so browser builds can resolve it properly
        exclude: ['child_process', 'fs'],
      }),
      {
        name: 'buffer-polyfill',
        transform(code, id) {
          if (id.includes('env.mjs')) {
            return {
              code: `import { Buffer } from 'buffer';\n${code}`,
              map: null,
            };
          }

          return null;
        },
      },
      config.mode !== 'test' && remixCloudflareDevProxy(),
      remixVitePlugin({
        future: {
          v3_fetcherPersist: true,
          v3_relativeSplatPath: true,
          v3_throwAbortReason: true,
          v3_lazyRouteDiscovery: true,
        },
      }),
      UnoCSS(),
      tsconfigPaths(),
      chrome129IssuePlugin(),
      config.mode === 'production' && optimizeCssModules({ apply: 'build' }),
    ],
    envPrefix: [
      'VITE_',
      'OPENAI_LIKE_API_BASE_URL',
      'OPENAI_LIKE_API_MODELS',
      'OLLAMA_API_BASE_URL',
      'LMSTUDIO_API_BASE_URL',
      'TOGETHER_API_BASE_URL',
    ],
    css: {
      preprocessorOptions: {
        scss: {
          api: 'modern-compiler',
        },
      },
    },
    test: {
      exclude: [
        '**/node_modules/**',
        '**/dist/**',
        '**/cypress/**',
        '**/.{idea,git,cache,output,temp}/**',
        '**/{karma,rollup,webpack,vite,vitest,jest,ava,babel,nyc,cypress,tsup,build}.config.*',
        '**/tests/preview/**', // Exclude preview tests that require Playwright
      ],
    },
  };
});

function chrome129IssuePlugin() {
  return {
    name: 'chrome129IssuePlugin',
    configureServer(server: ViteDevServer) {
      server.middlewares.use((req, res, next) => {
        const raw = req.headers['user-agent']?.match(/Chrom(e|ium)\/([0-9]+)\./);

        if (raw) {
          const version = parseInt(raw[2], 10);

          if (version === 129) {
            res.setHeader('content-type', 'text/html');
            res.end(
              '<body><h1>Please use Chrome Canary for testing.</h1><p>Chrome 129 has an issue with JavaScript modules & Vite local development, see <a href="https://github.com/stackblitz/bolt.new/issues/86#issuecomment-2395519258">for more information.</a></p><p><b>Note:</b> This only impacts <u>local development</u>. `pnpm run build` and `pnpm run start` will work fine in this browser.</p></body>',
            );

            return;
          }
        }

        next();
      });
    },
  };
}