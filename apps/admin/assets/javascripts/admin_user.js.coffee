# /admin/user/*

import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

import {fetchJsonGet} from '../api/fetch_json.js'

import {createRunGetAttrs} from '../api/get_attrs.js'
import {runGetProviders} from '../api/get_providers.js'
import {runGetGroups} from '../api/get_groups.js'

import basicInfo from './admin_user_basic_info.js'
import operationMenu from './admin_user_operation_menu.js'
import groupMembership from './admin_user_group_membership.js'
import providerReg from './admin_user_provider_reg.js'
import attrList from './admin_user_attr_list.js'

import {InitUserAttrs} from './admin_user_attrs.js'

newUser = {
  username: ''
  clearance_level: 1
  userdata: {attrs: {}}
  provider_userdatas: []
}

SetUserWithInit = (state, {user}) ->
  providers = (provider_userdata.provider.name for provider_userdata in user.provider_userdatas)
  primary_group = user.userdata.primary_group
  groups = user.userdata.groups || []
  [InitUserAttrs, {user: {user..., providers, primary_group, groups}}]

SetAttrsWithInit = (state, attrs) -> [InitUserAttrs, {attrs}]

runGetUser = (dispatch, {name}) ->
  if name?
    response = await fetchJsonGet({url: "/api/users/#{name}"})
    if response.ok
      dispatch(SetUserWithInit, {user: response.data})
    else
      console.error respons
  else
    dispatch(SetUserWithInit, {user: newUser})

runGetAttrsWithInit = createRunGetAttrs(SetAttrsWithInit)

name = location.pathname.split('/').at(-1)
name = undefined if name == '*'
mode = if name? then 'show' else 'new'

init = [
  {mode, name, user: null, providers: null, attrs: null, groups: null}
  [runGetProviders]
  [runGetAttrsWithInit]
  [runGetGroups]
  [runGetUser, {name}]
]

view = ({mode, name, user, providers, attrs, groups}) ->
  unless user? && providers? && attrs? && groups?
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
