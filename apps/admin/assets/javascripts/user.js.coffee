# /admin/user/*

import {text, app} from '/assets/vendor/hyperapp.js'
import * as html from '/assets/vendor/hyperapp-html.js'

import {fetchJsonGet} from '/assets/api/fetch_json.js'

import {runGetSystem} from '/assets/api/get_system.js'
import {createRunGetAttrs} from '/assets/api/attrs.js'
import {runGetProviders} from '/assets/api/providers.js'
import {runGetGroups} from '/assets/api/groups.js'

import basicInfo from './user_basic_info.js'
import operationMenu from './user_operation_menu.js'
import groupMembership from './user_group_membership.js'
import providerReg from './user_provider_reg.js'
import attrList from './user_attr_list.js'
import {runGetUserWithInit} from './user_get_user.js'

import {InitUserAttrs} from './user_attrs.js'

SetAttrsWithInit = (state, attrs) -> [InitUserAttrs, {attrs}]

runGetAttrsWithInit = createRunGetAttrs(SetAttrsWithInit)

name = location.pathname.split('/').at(-1)
name = undefined if name == '*'
mode = if name? then 'show' else 'new'

init = [
  {mode, name, user: null, providers: null, attrs: null, groups: null}
  [runGetSystem]
  [runGetProviders]
  [runGetAttrsWithInit]
  [runGetGroups]
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
