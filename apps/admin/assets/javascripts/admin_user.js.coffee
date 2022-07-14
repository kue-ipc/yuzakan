# /admin/user/*

import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

import {fetchJsonGet} from '../fetch_json.js'

import basicInfo from './admin_user_basic_info.js'
import operationMenu from './admin_user_operation_menu.js'
import groupMembership from './admin_user_group_membership.js'
import providerReg from './admin_user_provider_reg.js'
import attrList from './admin_user_attr_list.js'

import {CalcUserAttrs} from './admin_user_attrs.js'

ChangeUserName = (state, {name}) ->
  history.pushState(null, null, "/admin/users/#{name}") if name? && name != state.name
  {state..., name}

SetUser = (state, {user}) -> [CalcUserAttrs, {user}]

SetAllProviders = (state, {providers}) -> {state..., providers}

SetAllAttrs = (state, {attrs}) -> [CalcUserAttrs, {attrs}]

runGetUser = (dispatch, {name}) ->
  return unless name?

  response = await fetchJsonGet({url: "/api/users/#{name}"})
  if response.ok
    dispatch(SetUser, {user: response.data})
  else
    console.error respons

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

initUser = {
  name: ''
  clearance_level: 1
  userdata: {attrs: {}}
  userdata_list: []
}

init = [
  {mode, name, user: initUser, providers: [], attrs: []}
  [runGetAllProviders]
  [runGetAllAttrs]
  [runGetUser, {name}]
]

view = ({mode, name, user, providers, attrs}) ->
  html.div {}, [
    basicInfo {mode, user}
    operationMenu {mode, user}
    groupMembership {}
    providerReg {mode, user, providers}
    attrList {mode, user, providers, attrs}
  ]


node = document.getElementById('admin_user')

app {init, view, node}
