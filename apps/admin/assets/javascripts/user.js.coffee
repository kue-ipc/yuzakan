# /admin/user/*

import {text, app} from '~/vendor/hyperapp.js'
import * as html from '~/vendor/hyperapp-html.js'

import {pick, pickType, getBasenameFromUrl, getQueryParamsFromUrl, entityLabel} from '~/common/helper.js'

import {fetchJsonGet} from '~/api/fetch_json.js'

import {runShowSystem} from '~/api/system.js'
import {runIndexProviders} from '~/api/providers.js'
import {runIndexGroupsNoSync} from '~/api/groups.js'
import {createRunIndexAttrs} from '~/api/attrs.js'
import {SHOW_USER_PARAM_TYPES, createRunShowUser} from '~/api/users.js'

import userInfo from '~/admin/user_info.js'
import userOperation from '~/admin/user_operation.js'
import userGroup from '~/admin/user_group.js'
import userProvider from '~/admin/user_provider.js'
import userAttr from '~/admin/user_attr.js'

import {runGetUserWithInit} from '~/admin/user_get_user.js'

import {InitUserAttrs} from '~/admin/user_attrs.js'

SetAttrsWithInit = (state, attrs) -> [InitUserAttrs, {attrs}]

## Effecters

# runIndexAttrsWithInit = createRunIndexAttrs({action: SetAttrsWithInit})
runIndexAttrsWithInit = createRunIndexAttrs()

# runIndexAttrsWithInit = createRunIndexAttrs({action: SetUserWithInit})
runShowUserWithInit = createRunShowUser()

main = ->
  id = getBasenameFromUrl(location)
  id = undefined if id == '*'
  mode = if id? then 'show' else 'new'

  queryParams = pickType(getQueryParamsFromUrl(location), SHOW_USER_PARAM_TYPES)

  init = [
    {mode, id, user: null, providers: null, attrs: null, groups: null, system: null, option: queryParams}
    [runShowSystem]
    [runIndexProviders]
    [runIndexGroupsNoSync]
    [runIndexAttrsWithInit]
    [runShowUserWithInit, {id}]
  ]

  view = ({mode, id, user, providers, attrs, groups, system, option}) ->
    if mode == 'none'
      return html.div {},
        html.strong {}, text 'ユーザーが見つかりませんでした。'

    if mode == 'new'
      return html.div {},
        html.strong {}, text '準備中です。'

    unless user? && providers? && attrs? && groups? && system?
      return html.div {}, text '読み込み中...'

    html.div {}, [
      userInfo {mode, user, groups}
      userGroup {mode, user, groups}
      userOperation {mode, user}
      userProvider {mode, user, providers}
      userAttr {mode, user, providers, attrs}
    ]

  node = document.getElementById('user')

  app {init, view, node}

main()
