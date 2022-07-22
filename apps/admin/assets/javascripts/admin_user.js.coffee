# /admin/user/*

import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

import {fetchJsonGet} from '../fetch_json.js'

import basicInfo from './admin_user_basic_info.js'
import operationMenu from './admin_user_operation_menu.js'
import groupMembership from './admin_user_group_membership.js'
import providerReg from './admin_user_provider_reg.js'
import attrList from './admin_user_attr_list.js'

import {InitUserAttrs} from './admin_user_attrs.js'

SetUser = (state, {user}) ->
  providers = (provider_userdata.provider.name for provider_userdata in user.provider_userdatas)
  primary_group = user.userdata.primary_group
  groups = user.userdata.groups || []
  [InitUserAttrs, {user: {user..., providers, primary_group, groups}}]

SetAllProviders = (state, {providers}) -> {state..., providers}

SetAllAttrs = (state, {attrs}) -> [InitUserAttrs, {attrs}]

SetAllGroups = (state, {groups}) -> {state..., groups}

newUser = {
  name: ''
  clearance_level: 1
  userdata: {attrs: {}}
  provider_userdatas: []
}

runGetUser = (dispatch, {name}) ->
  if name?
    response = await fetchJsonGet({url: "/api/users/#{name}"})
    if response.ok
      dispatch(SetUser, {user: response.data})
    else
      console.error respons
  else
    dispatch(SetUser, {user: newUser})

runGetAllProviders = (dispatch) ->
  response = await fetchJsonGet({url: '/api/providers'})
  if response.ok
    dispatch(SetAllProviders, {providers: response.data})
  else
    console.error response

runGetAllAttrs = (dispatch) ->
  response = await fetchJsonGet({url: '/api/attrs'})
  if response.ok
    dispatch(SetAllAttrs, {attrs: response.data})
  else
    console.error response

runGetAllGroups = (dispatch) ->
  groups = []

  for page in [1..10000]
    response = await fetchJsonGet({url: '/api/groups', data: {page, per_page: 100}})
    if response.ok
      groups = [groups..., response.data...]
      break if groups.length >= response.total
    else
      console.error response
      return

  dispatch(SetAllGroups, {groups})

name = location.pathname.split('/').at(-1)
name = undefined if name == '*'
mode = if name? then 'show' else 'new'

init = [
  {mode, name, user: null, providers: null, attrs: null, groups: null}
  [runGetAllProviders]
  [runGetAllAttrs]
  [runGetAllGroups]
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
