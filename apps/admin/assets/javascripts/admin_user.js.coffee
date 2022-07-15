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

ChangeUserName = (state, {name}) ->
  history.pushState(null, null, "/admin/users/#{name}") if name? && name != state.name
  {state..., name}

SetUser = (state, {user}) ->
  providers = (provider_userdata.provider.name for provider_userdata in user.provider_userdatas)
  [InitUserAttrs, {user: {user..., providers}}]

SetAllProviders = (state, {providers}) -> {state..., providers}

SetAllAttrs = (state, {attrs}) -> [InitUserAttrs, {attrs}]

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

name = location.pathname.split('/').at(-1)
name = undefined if name == '*'
mode = if name? then 'show' else 'new'

init = [
  {mode, name, user: null, providers: null, attrs: null}
  [runGetAllProviders]
  [runGetAllAttrs]
  [runGetUser, {name}]
]

view = ({mode, name, user, providers, attrs}) ->
  console.log user
  unless user? && providers? && attrs?
    return html.div {}, text '読み込み中...'

  html.div {}, [
    basicInfo {mode, user}
    operationMenu {mode, user}
    groupMembership {}
    providerReg {mode, user, providers}
    attrList {mode, user, providers, attrs}
  ]


node = document.getElementById('admin_user')

app {init, view, node}
