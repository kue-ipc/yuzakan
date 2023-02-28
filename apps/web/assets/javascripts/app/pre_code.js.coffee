import hljs from '/assets/vendor/hljs.js'
import * as html from '/assets/vendor/hyperapp-html.js'

export default preCode = ({code, language, ignoreIllegals = true}) ->
  hljsResult = hljs.highlight(code, {language, ignoreIllegals})
  html.pre {class: 'm-0'},
    html.code {
      class: "hljs p-1"
      innerHTML: hljsResult.value
    }
