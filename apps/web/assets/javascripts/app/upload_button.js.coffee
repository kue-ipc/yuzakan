import {text} from 'hyperapp'
import * as html from '@hyperapp/html'

import {csvToList} from '~/common/csv_helper.js'

# Upload button view
# @param {boolean} disabled - 無効にする
# @param {action} onupload - アップロードされたファイルが渡されるアクション
# アクションのprops
#   list: データ(配列)
#   filename: ファイル名
export default uploadButton = ({disabled = false, onupload}) ->
  inputFile = html.input {
    class: 'visually-hidden'
    type: 'file'
    accept: '.csv,text/csv'
    onchange: (state, event) -> [UploadCsv, {file: event.target.files?[0], action: onupload}]
  }
  html.div {}, [
    inputFile
    html.button {
      class: 'btn btn-warning'
      disabled
      onclick: -> [ClickUploadButton, inputFile.node]
    }, text 'アップロード'
  ]

# Upload CSV action
UploadCsv = (state, {file, action}) ->
  return state unless file

  [{state..., mode: 'loading'}, [runUploadCsv, {file, action}]]

# Click upload buton action
ClickUploadButton = (state, input) ->  [state, [runClickInput, input]]

# Upload CSV Effecter
runUploadCsv = (dispatch, {action, file}) ->
  filename = file.name
  console.debug 'upload: %s', filename
  csv = await file.text()
  list = await csvToList(csv)
  dispatch(action, {list, filename})

# Click input effecter
runClickInput = (dispatch, input) ->
  input.click()



