import {text} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'
import {stringify} from '/assets/vendor/csv-stringify.js'
import {parse} from '/assets/vendor/csv-parse.js'
import FileSaver from '/assets/vendor/file-saver.js'

GROUP_KEYS = [
  'action'
  'groupname'
  'display_name'
  'note'
  'primary'
  'obsoleted'
  'deleted'
  'deleted_at'
  'providers'
]

createCSV = (groups) ->
  new Promise (resolve, reject) ->
    stringify groups, {
      bom: true
      columns: GROUP_KEYS
      header: true
      quoted_string: true
    }, (err, output) ->
      if err?
        reject(err)
      else
        console.debug 'create CSV'
        resolve(output)

runDownloadCSV = (dispatch, groups) ->
  csv = await createCSV(groups)
  blob = new Blob [csv], {type: 'text/csv'}
  FileSaver.saveAs(blob, 'groups.csv')

DownloadCSV = (state, groups) -> [state, [runDownloadCSV, groups]]

export downloadButton = ({groups})->
  html.button {
    class: 'btn btn-primary'
    onclick: -> [DownloadCSV, groups]
  }, text 'ダウンロード'
