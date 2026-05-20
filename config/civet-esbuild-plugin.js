/**
 * https://github.com/DanielXMoore/Civet
 * source/esbuild-plugin.civet
 * version 1.0.7
 * MIT License
 * Copyright (c) 2022 Daniel X Moore and other contributors
 */

import { readFile, writeFile, mkdtemp, rmdir } from 'fs/promises'
import path from 'path'
import { compile } from "@danielx/civet"

// NOTE: this function is named civet so esbuild gets "civet" as the name of the plugin
const civet = function(options = {}) {
  const {
    filter=/\.civet$/,
    inlineMap=true,
    js=true,
    next
  } = options

  let nextTransform
  let tmpPath

  if (next) {
    next.setup({
      onEnd() {; },
      onStart() {; },
      resolve() {; },
      onResolve() {; },
      initialOptions() {; },
      esbuild() {; },
      onLoad(_, handler) {
        return nextTransform = handler
      }
    })
  }

  return {
    name: "civet",

    setup(build) {

      build.onStart(async function() {
        if (next) {
          const { tmpdir } = require('os')
          tmpPath = await mkdtemp(path.join(tmpdir(), "civet-"))
        }
        return
      })

      build.onEnd(async function() {
        if (tmpPath) {
          await rmdir(tmpPath, { recursive: true })
        }
        return
      })

      return build.onLoad({ filter }, async function(args) {
        try {
          const source = await readFile(args.path)
          const filename = path.relative(process.cwd(), args.path)
          const compiled = await compile(source, {
            filename,
            inlineMap,
            js
          })

          if (next && tmpPath) {
            const outputFileName = filename + js ? '.jsx' : '.tsx'
            const outputFilePath = path.join(tmpPath, outputFileName)

            // I'd prefer not to use temp files but I can't find a way to pass a stream to fs.readFile which is what
            // most esbuild plugins use
            await writeFile(outputFilePath, compiled)
            return await nextTransform({
              ...args,
              path: outputFilePath
            })
          }

          return {
            contents: compiled,
          }
        }
        catch (e) {
          return {
            errors: [{
              text: e.message,
              location: {
                file: args.path,
                namespace: args.namespace,
                line: e.line,
                column: e.column,
              },
              detail: e
            }]
          }
        }
      })
    }
  }
}

const defaultPlugin = civet()

// Default zero-config plugin
civet.setup = defaultPlugin.setup

// This gets rewritten to roughly `module.exports = civet` in `build/esbuild.civet`.
// It assumes that there are no named exports, only a default.
export default civet
