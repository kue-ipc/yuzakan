# /admin/user/*

import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import {fetchJsonGet} from '/assets/api/fetch_json.js'

import {createRunShowSystem} from '/assets/api/system.js'
import {createRunIndexAttrs} from '/assets/api/attrs.js'
import {createRunIndexProviders} from '/assets/api/providers.js'
import {createRunIndexGroupsNoSync} from '/assets/api/groups.js'

import basicInfo from '/assets/admin/user_basic_info.js'
import operationMenu from '/assets/admin/user_operation_menu.js'
import groupMembership from '/assets/admin/user_group_membership.js'
import providerReg from '/assets/admin/user_provider_reg.js'
import attrList from '/assets/admin/user_attr_list.js'
import {runGetUserWithInit} from '/assets/admin/user_get_user.js'

import {InitUserAttrs} from '/assets/admin/user_attrs.js'

SetAttrsWithInit = (state, attrs) -> [InitUserAttrs, {attrs}]

## Effecters

runIndexGroups = createRunIndexGroupsNoSync()

runIndexProviders = createRunIndexProviders()

runShowSystem = createRunShowSystem()

runIndexAttrsWithInit = createRunIndexAttrs(SetAttrsWithInit)

name = location.pathname.split('/').at(-1)
name = undefined if name == '*'
mode = if name? then 'show' else 'new'

init = [
  {mode, name, user: null, providers: null, attrs: null, groups: null}
  [runShowSystem]
  [runIndexProviders]
  [runIndexAttrsWithInit]
  [runIndexGroups]
  [runGetUserWithInit, {name}]
]

view = ({mode, name, user, providers, attrs, groups, system}) ->
  if mode == 'none'
    return html.div {},
      html.strong {}, text 'ユーザーが見つかりませんでした。'

  unless user? && providers? && attrs? && groups? && system?
    return html.div {}, text '読み込み中...'

  html.div {}, [
    basicInfo {mode, user, groups}
    operationMenu {mode, user}
    # groupMembership {mode, user, groups}
    providerReg {mode, user, providers}
    attrList {mode, user, providers, attrs}
  ]

node = document.getElementById('user')

app {init, view, node}
