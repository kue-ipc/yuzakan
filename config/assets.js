import * as assets from "hanami-assets";

import civetPlugin from '@danielx/civet/esbuild-plugin';
import {sassPlugin} from 'esbuild-sass-plugin';
import {YAMLPlugin} from 'esbuild-yaml';

await assets.run({
  esbuildOptionsFn: (args, esbuildOptions) => {
    // Add to esbuildOptions here. Use `args.watch` as a condition for different options for
    // compile vs watch.
    // if (args.watch) {
    // } else {
    // }

    esbuildOptions.format = 'esm';
    esbuildOptions.target = [
      'edge128', // for Extended Stable
      'chrome126', // for ChromeOS LTS 126
      'firefox128', // for ESR
      'safari16', // for iOS 16
    ];
    esbuildOptions.plugins ??= [];
    esbuildOptions.plugins.push(civetPlugin());
    esbuildOptions.plugins.push(sassPlugin({
      silenceDeprecations: ['mixed-decls', 'color-functions', 'global-builtin', 'import'],
    }));
    esbuildOptions.plugins.push(YAMLPlugin());

    return esbuildOptions;
  }
});
