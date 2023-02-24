import {parse, stringify, transform} from '/assets/vendor/csv.js'

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
