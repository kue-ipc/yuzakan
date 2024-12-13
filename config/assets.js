import * as assets from "hanami-assets";

import coffeeScriptPlugin from 'esbuild-coffeescript';
import civetPlugin from '@danielx/civet/esbuild-plugin';
import {sassPlugin} from 'esbuild-sass-plugin';

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
    esbuildOptions.plugins.push(coffeeScriptPlugin());
    esbuildOptions.plugins.push(civetPlugin());
    esbuildOptions.plugins.push(sassPlugin());

    return esbuildOptions;
  }
});
