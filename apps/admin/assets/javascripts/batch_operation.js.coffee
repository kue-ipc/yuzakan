import {DateTime} from '/assets/vendor/luxon.js'
import {text} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import ConfirmDialog from '/assets/app/confirm_dialog.js'
import {basename} from '/assets/common/utils.js'

import {downloadButton, uploadButton} from './csv.js'

# Dialogs

startAllActionConfirm = new ConfirmDialog {
  id: 'modal.confirm.do_all_action'
  states: 'alert'
  title: 'すべて実行'
  action: {
    color: 'danger'
    label: 'すべて実行'
  }
}

# Views

export batchOperation = ({mode, list, headers, filename, onupload, action}) ->
  filename = "#{basename(filename, '.*')}_#{DateTime.now().toFormat('yyyyMMddHHmmss')}.csv"

  html.div {key: 'batch_operation', class: 'row mb-2'}, [
    html.div {key: 'upload', class: 'col-md-2'},
      uploadButton {
        onupload
        disabled: ['loading', 'result'].includes(mode)
      }
    html.div {key: 'download', class: 'col-md-2'},
      downloadButton {
        list
        filename
        headers
        disabled: ['loading', 'file'].includes(mode)
      }
    html.div {key: 'do_all_action', class: 'col-md-2'},
      # result の場合は、既に実行したエントリー(エラー含む)を除いて実行
      unless ['loading', 'loaded'].includes(mode)
        startAllActionButton {list, action, disbaled: mode == 'do_all'}
  ]

startAllActionButton = ({disabled, props...}) ->
  html.button {
    class: 'btn btn-danger'
    onclick: -> [StartAllActionWithConfirm, props]
  }, text 'すべて実行'

# Actions

StartAllActionWithConfirm = (state, props) ->
  [state, [runStartAllActionWithConfirm, props]]

StartAllAction = (state, props) ->
  [
    {state..., mode: 'do_all'}
    [runDoNextAction, props]
  ]

StopAllAction = (state) ->
  {state..., mode: 'result'}

DoNextAction = (state, {list, action}) ->
  target = list.find (item) -> ['ADD', 'MOD', 'DEL', 'SYC', 'LOC', 'UNL'].includes(item.action)

  if target
    [action, target]
  else
    StopAllAction

# Effecters

runStartAllActionWithConfirm = (dispatch, props) ->
  confirm = await startAllActionConfirm.showPromise({
    messages: [
      'すべての処理を実行します。'
      '''
        処理は途中で停止することはできません。
        しかし、ブラウザーを閉じると処理が中断され、実行結果が失われます。
        実行中は決して、ブラウザーを閉じないでください。
        また、予期せぬ中断を避けるために、スリープは無効にしておいてください。
      '''
      'すべての処理を実行してもよろしいですか？']
  })
  if confirm
    dispatch(StartAllAction, props)

export runStartAllAction = (dispatch, props) ->
  dispatch(StartAllAction, props)

export runStopAllAction = (dispatch) ->
  dispatch(StopAllAction)

export runDoNextAction = (dispatch, props) ->
  dispatch(DoNextAction, props)

