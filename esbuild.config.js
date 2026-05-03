import { build, context, formatMessages } from 'esbuild'
import esbuildPluginImportGlob from 'esbuild-plugin-import-glob'
import esbuildPluginTextReplace from 'esbuild-plugin-text-replace'
import manifestPlugin from 'esbuild-manifest-plugin'
const { default: importGlob } = esbuildPluginImportGlob

const path = await import('path')
const fs = await import('fs')

const railsEnv = process.env.RAILS_ENV || 'development'
const outdir = path.join(process.cwd(), 'public/assets')
const errorFilePath = path.join(outdir, `esbuild_error_${railsEnv}.txt`)

if (!fs.existsSync(outdir)) { fs.mkdirSync(outdir) }

async function handleErrors(errors) {
  const formattedErrors = await formatMessages(errors, { kind: 'error' })
  const output = formattedErrors.join('\n')

  if (output) {
    fs.writeFileSync(errorFilePath, output)
  } else if (fs.existsSync(errorFilePath)) {
    fs.truncate(errorFilePath, 0, () => {})
  }
}

let entryPoints

if (railsEnv === 'production') {
  entryPoints = ['application.js', 'static.js']
} else {
  entryPoints = ['application.js', 'static.js', 'jasmine.js']
}

const config = {
  entryPoints,
  bundle: true,
  sourcemap: railsEnv !== 'production',
  format: 'esm',
  outdir,
  absWorkingDir: path.join(process.cwd(), 'app/assets'),
  metafile: true,
  publicPath: '/assets',
  entryNames: '[dir]/[name]-[hash]',
  assetNames: '[dir]/[name]-[hash]',
  loader: {
    '.css': 'css',
    '.ico': 'copy',
    '.jpg': 'copy',
    '.png': 'copy',
    '.svg': 'copy',
    '.webp': 'copy',
    '.json': 'copy',
    '.ttf': 'file',
    '.woff': 'file',
    '.woff2': 'file',
  },
  plugins: [
    esbuildPluginTextReplace({
      include: /jasmine-core\/lib\/jasmine-core\/jasmine\.js/,
      pattern: [
        ['let jasmineRequire;', 'let jasmineRequire; const global = window;'],
      ]
    }),
    importGlob(),
    manifestPlugin(),
    {
      name: 'handleErrors',
      setup: (build) => {
        build.onEnd(async ({ errors }) => {
          await handleErrors(errors)
        })
      }
    }
  ],
}

if (process.argv.includes('--watch')) {
  const ctx = await context(config)
  ctx.watch()
} else {
  await build(config)
}
