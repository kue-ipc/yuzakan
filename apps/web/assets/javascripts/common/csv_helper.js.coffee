import {parse, stringify, transform} from 'csv'

import {objToRecord, recordToObj} from '~/common/convert.js'

# async csv and records utilities

recordsToCsv = (records, {columns} = {}) ->
  new Promise (resolve, reject) ->
    stringify records, {
      bom: true
      columns
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
      group_columns_by_name: true
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

export listToCsv = (list, {header = {}} = {}) ->
  records = await transformRecords(list, objToRecord)
  csv = await recordsToCsv(records, {columns: mergeHeaders(records, header)})
  csv

export csvToList = (csv) ->
  records = await csvToRecords(csv)
  list = await transformRecords(records, recordToObj)
  list

mergeHeaders = (records, {includes = [], excludes = []} = {}) ->
  set = new Set(includes)
  for record in records
    for key in Object.keys(record)
      set.add(key)
  for key in excludes
    set.delete(key)
  Array.from(set)
