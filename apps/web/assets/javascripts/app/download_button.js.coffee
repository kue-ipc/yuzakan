import {text} from '~/vendor/hyperapp.js'
import * as html from '~/vendor/hyperapp-html.js'
import FileSaver from '~/vendor/file-saver.js'

import {listToCsv} from '~/common/csv_helper.js'

# Downolad button view
# @param {boolean} disabled - 無効にする
# @param {object[]} list - データ
# @param {string} filename - ダウンロードするファイルのファイル名
export default downloadButton = ({disabled = false, props...})->
  html.button {
    class: 'btn btn-secondary'
    disabled
    onclick: -> [DownloadCsv, props]
  }, text 'ダウンロード'

# Dowunloa CSV action
DownloadCsv = (state, props) -> [state, [runDownloadCsv, props]]

# Dwnload CSV effecter
runDownloadCsv = (dispatch, {list, filename, header}) ->
  console.debug 'download: %s', filename
  csv = await listToCsv(list, {header})
  blob = new Blob [csv], {type: 'text/csv'}
  FileSaver.saveAs(blob, filename)
