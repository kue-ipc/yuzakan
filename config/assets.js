import * as assets from "hanami-assets";

import civetPlugin from "@danielx/civet/esbuild";
import { sassPlugin } from "esbuild-sass-plugin";
import { YAMLPlugin } from "esbuild-yaml";

// Assets are managed by esbuild (https://esbuild.github.io), and can be
// customized below.
//
// Learn more at https://guides.hanamirb.org/assets/customization/.

await assets.run({
  esbuildOptionsFn: (args, esbuildOptions) => {
    // Customize your `esbuildOptions` here.
    //
    // Use the `args.watch` boolean as a condition to apply diffierent options
    // when running `hanami assets watch` vs `hanami assets compile`.

    esbuildOptions.format = "esm";
    esbuildOptions.target = [
      "edge128", // for Extended Stable
      "chrome126", // for ChromeOS LTS 126
      "firefox128", // for ESR
      "safari16", // for iOS 16
    ];
    esbuildOptions.plugins ??= [];
    esbuildOptions.plugins.push(civetPlugin());
    esbuildOptions.plugins.push(sassPlugin({
      silenceDeprecations: ["color-functions", "global-builtin", "import"],
    }));
    esbuildOptions.plugins.push(YAMLPlugin());
    esbuildOptions.alias = {
      "~": "./app/assets/js",
      "~admin": "./slices/admin/assets/js",
      "~api": "./slices/api/assets/js",
    };

    return esbuildOptions;
  },
});
