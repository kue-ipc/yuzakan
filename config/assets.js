import * as assets from "hanami-assets";

// FIXME: Civetのunpluginではtsconfig.jsonのpathsが解決されないため、古いプラグインを使用する。
//        unpluginでの解決策は見つかっていない。
// import civetPlugin from "@danielx/civet/esbuild";
import civetPlugin from "./civet-esbuild-plugin.js";
import { sassPlugin } from "esbuild-sass-plugin";
import YAMLPlugin from "unplugin-yaml/esbuild";

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

    return esbuildOptions;
  },
});
