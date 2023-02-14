import {text} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'
import {parse, stringify, transform} from '/assets/vendor/csv.js'
import FileSaver from '/assets/vendor/file-saver.js'

# async csv and records utilities

recordsToCsv = (records, {headers} = {}) ->
  new Promise (resolve, reject) ->
    stringify records, {
      bom: true
      columns: headers
      header: true
      quoted_string: true
      record_delimiter: 'windows'
    }, (err, output) ->
      if err?
        reject(err)
      else
        console.debug 'records to csv'
        resolve(output)

csvToRecords = (csv) ->
  new Promise (resolve, reject) ->
    parse csv, {
      bom: true
      columns: true
    }, (err, records) ->
      if err?
        reject(err)
      else
        console.debug 'csv to records'
        resolve(records)

transformRecords = (records, handler) ->
  new Promise (resolve, reject) ->
    transform records, handler, (err, output) ->
      if err?
        reject(err)
      else
        resolve(output)

objToRecord = (obj) ->
  obj = Object.fromEntries(obj) if obj instanceof Map
  record = {}
  for own key, value of obj
    if typeof value == 'object'
      if value instanceof Array
        for nest_key in value
          record["#{key}[#{nest_key}]"] = true
      else if value instanceof Set
        for nest_key from value
          record["#{key}[#{nest_key}]"] = true
      else if value instanceof Map
        for [nest_key, nest_value] from value
          record["#{key}[#{nest_key}]"] = nest_value
      else
        for own nest_key, nest_value of value
          record["#{key}[#{nest_key}]"] = nest_value
    else
      record[key] = value
  record

recordsToObj = (record) ->
  obj = {}
  for key, value of record
    match = key.match(/^(.+)\[([^\]]+)\]$/)
    if match
      obj[match[1]] ||= {}
      obj[match[1]][match[2]] = value
    else
      obj[key] = value
  obj

export listToCsv = (list, {headers} = {}) ->
  records = await transformRecords(list, objToRecord)
  csv = await recordsToCsv(records, {headers})
  csv

export csvToList = (csv) ->
  records = await csvToRecords(csv)
  list = await transformRecords(records, recordsToObj)
  list

# Download

# Downolad button view
# {list: データ, filaname: ファイル名}
export downloadButton = (props)->
  html.button {
    class: 'btn btn-secondary'
    onclick: -> [DownloadCsv, props]
  }, text 'ダウンロード'

DownloadCsv = (state, props) -> [state, [runDownloadCsv, props]]

runDownloadCsv = (dispatch, {list, filename, headers}) ->
  console.debug 'download: %s', filename
  csv = await listToCsv(list, {headers})
  blob = new Blob [csv], {type: 'text/csv'}
  FileSaver.saveAs(blob, filename)

# Upload button view
# {onupload: アップロード完了後に実行されるアクション}
# アクションのprops
#   list: データ(配列)
#   filename: ファイル名
export uploadButton = ({onupload}) ->
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
      # onclick: -> [ClickUploadButton, inputFile.node]
      onclick: -> [ClickUploadButton, inputFile.node]
    }, text 'アップロード'
  ]

UploadCsv = (state, {file, action}) ->
  return state unless file

  [state, [runUploadCsv, {file, action}]]

runUploadCsv = (dispatch, {action, file}) ->
  filename = file.name
  console.debug 'upload: %s', filename
  csv = await file.text()
  list = await csvToList(csv)
  dispatch(action, {list, filename})

ClickUploadButton = (state, input) ->  [state, [runClickInput, input]]

runClickInput = (dispatch, input) ->
  input.click()



