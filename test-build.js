import { build } from 'vite';
import { resolve } from 'path';

async function testBuild() {
  try {
    console.log('Starting build test...');
    
    // Test the build configuration
    await build({
      mode: 'production',
      configFile: resolve('./vite.config.ts'),
      build: {
        outDir: 'dist/test',
        emptyOutDir: true,
      }
    });
    
    console.log('Build test completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Build test failed:', error);
    process.exit(1);
  }
}

testBuild();