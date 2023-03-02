# /admin/user/*

import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import {pick, pickType, getBasenameFromUrl, getQueryParamsFromUrl, entityLabel} from '/assets/common/helper.js'

import {fetchJsonGet} from '/assets/api/fetch_json.js'

import {runShowSystem} from '/assets/api/system.js'
import {runIndexProviders} from '/assets/api/providers.js'
import {runIndexGroupsNoSync} from '/assets/api/groups.js'
import {createRunIndexAttrs} from '/assets/api/attrs.js'
import {SHOW_USER_PARAM_TYPES, createRunShowUser} from '/assets/api/users.js'

import userBasicInfo from '/assets/admin/user_basic_info.js'
import operationMenu from '/assets/admin/user_operation_menu.js'
import groupMembership from '/assets/admin/user_group_membership.js'
import providerReg from '/assets/admin/user_provider_reg.js'
import attrList from '/assets/admin/user_attr_list.js'

import {runGetUserWithInit} from '/assets/admin/user_get_user.js'

import {InitUserAttrs} from '/assets/admin/user_attrs.js'

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
    console.log {mode, id, user, providers, attrs, groups, system, option}
    if mode == 'none'
      return html.div {},
        html.strong {}, text 'ユーザーが見つかりませんでした。'

    unless user? && providers? && attrs? && groups? && system?
      return html.div {}, text '読み込み中...'

    html.div {}, [
      userBasicInfo {mode, user, groups}
      groupMembership {mode, user, groups}
      operationMenu {mode, user}
      # providerReg {mode, user, providers}
      # attrList {mode, user, providers, attrs}
    ]

  node = document.getElementById('user')

  app {init, view, node}

main()
