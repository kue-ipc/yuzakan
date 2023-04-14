import hljs from 'hljs'
import * as html from '@hyperapp/html'

export default preCode = ({code, language, ignoreIllegals = true}) ->
  hljsResult = hljs.highlight(code, {language, ignoreIllegals})
  html.pre {class: 'm-0'},
    html.code {
      class: "hljs p-1"
      innerHTML: hljsResult.value
    }
