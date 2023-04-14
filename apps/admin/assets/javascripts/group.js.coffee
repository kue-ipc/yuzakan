# グループ

import {text, app} from '~/vendor/hyperapp.js'
import * as html from '~/vendor/hyperapp-html.js'

import {pick, pickType, getBasenameFromUrl, getQueryParamsFromUrl, entityLabel} from '~/common/helper.js'
import {objToUrlencoded} from '~/common/convert.js'
import valueDisplay from '~/app/value_display.js'

import {runIndexProviders} from '~/api/providers.js'
import {SHOW_GROUP_PARAM_TYPES, runShowGroup} from '~/api/groups.js'

import groupInfo from '~/admin/group_info.js'
import groupProvider from '~/admin/group_provider.js'
import groupOperation from '~/admin/group_operation.js'

# main

main = ->
  id = getBasenameFromUrl(location)
  id = undefined if id == '*'
  mode = if id? then 'show' else 'new'

  queryParams = pickType(getQueryParamsFromUrl(location), SHOW_GROUP_PARAM_TYPES)

  init = [
    {mode, id, group: null, providers: [], option: queryParams}
    [runIndexProviders, {has_group: true}]
    [runShowGroup, {id, queryParams...}]
  ]

  view = ({mode, id, group, providers, option}) ->
    if mode == 'none'
      return html.div {},
        html.strong {}, text 'グループが見つかりませんでした。'

    if mode == 'new'
      return html.div {},
        html.strong {}, text 'グループの新規作成はできません。'

    unless group? && providers?
      return html.div {}, text '読み込み中...'

    html.div {}, [
      groupInfo {mode, group}
      groupOperation {option}
      groupProvider {mode, group, providers}
    ]

  node = document.getElementById('group')

  app {init, view, node}

main()
