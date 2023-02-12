import {text} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'
import {parse, stringify} from '/assets/vendor/csv.js'
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

parseCSV = (csv) ->
  new Promise (resolve, reject) ->
    parse csv, {
      bom: true
      columns: true
    }, (err, records) ->
      if err?
        reject(err)
      else
        console.debug 'parse CSV'
        resolve(records)

runReadCSV = (dispatch, file) ->
  csv = await file.text()
  groups = await parseCSV(csv)
  console.log groups

UploadCSV = (state, files) ->
  return state unless files?.length

  [state, [runReadCSV, files[0]]]

runClickInput = (dispatch, input) ->
  input.click()

ClickUploadButton = (state, input) ->  [state, [runClickInput, input]]

export uploadButton = () ->
  inputFile = html.input {
    class: 'visually-hidden'
    type: 'file'
    accept: '.csv,text/csv'
    onchange: (state, event) -> [UploadCSV, event.target.files]
  }
  html.div {}, [
    inputFile
    html.button {
      class: 'btn btn-primary'
      onclick: () -> [ClickUploadButton, inputFile.node]
    }, text 'アップロード'
  ]


