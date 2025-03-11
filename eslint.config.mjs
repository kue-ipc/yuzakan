import civetPlugin from "eslint-plugin-civet/ts"

export default [
  // Rules from eslint.configs.recommended
  ...civetPlugin.configs.jsRecommended,
  // Rules from tseslint.configs.strict
  ...civetPlugin.configs.strict,
]
