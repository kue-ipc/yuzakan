import {parse, stringify, transform} from '/assets/vendor/csv.js'

import {objToRecord, recordToObj} from '/assets/common/convert.js'

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

export listToCsv = (list, {headers} = {}) ->
  records = await transformRecords(list, objToRecord)
  csv = await recordsToCsv(records, {headers})
  csv

export csvToList = (csv) ->
  records = await csvToRecords(csv)
  list = await transformRecords(records, recordToObj)
  list
