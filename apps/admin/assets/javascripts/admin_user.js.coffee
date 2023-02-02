# /admin/user/*

import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

import {fetchJsonGet} from '../api/fetch_json.js'

import {runGetSystem} from '../api/get_system.js'
import {createRunGetAttrs} from '../api/attrs.js'
import {runGetProviders} from '../api/providers.js'
import {runGetGroups} from '../api/groups.js'

import basicInfo from './admin_user_basic_info.js'
import operationMenu from './admin_user_operation_menu.js'
import groupMembership from './admin_user_group_membership.js'
import providerReg from './admin_user_provider_reg.js'
import attrList from './admin_user_attr_list.js'
import {runGetUserWithInit} from './admin_user_get_user.js'

import {InitUserAttrs} from './admin_user_attrs.js'

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

node = document.getElementById('admin_user')

app {init, view, node}
