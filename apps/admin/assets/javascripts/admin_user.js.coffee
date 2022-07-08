# /admin/user/*

import {text, app} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

import {fetchJsonGet} from '../fetch_json.js'
import BsIcon from '../bs_icon.js'
import {toRomaji, toKatakana, toHiragana} from '../ja_conv.js'
import {capitalize} from '../string_utils.js'
import {xxh32, xxh64} from '../hash.js'

import basicInfo from './admin_user_basic_info.js'
import operationMenu from './admin_user_operation_menu.js'
import groupMembership from './admin_user_group_membership.js'
import providerReg from './admin_user_provider_reg.js'
import attrList from './admin_user_attr_list.js'



pointMerge = (obj, names, value) ->
  {
    obj...
    [names[0]]: if names.length == 1 then value else pointMerge(obj[names[0]], names.slice(1), value)
  }

userValueAction = (state, {name, value}) ->
  throw new Error('No name value aciton') unless name?
  pointMerge(state, ['user', name.split('.')...], value)

userAction = (state, {name, user}) ->
  history.pushState(null, null, "/admin/users/#{name}") if name? && name != state.name

  {
    state...
    name: name ? state.name
    user: {state.user..., user...}
  }


showUserRunner = (dispatch, {name}) ->
  return unless name?

  response = await fetchJsonGet({url: "/api/users/#{name}"})
  if response.ok
    dispatch(userAction, {user: response.data})
  else
    console.error respons

initAllProvidersAction = (state, {providers}) ->
  {state..., providers}

indexAllProvidersRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/providers'})
  if response.ok
    dispatch(initAllProvidersAction, {providers: response.data})
  else
    console.error response

initAllAttrsAction = (state, {attrs}) ->
  {state..., attrs}

indexAllAttrsRunner = (dispatch) ->
  response = await fetchJsonGet({url: '/api/attrs'})
  if response.ok
    dispatch(initAllAttrsAction, {attrs: response.data})
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
  {mode, name, user: initUser, providers: [], attrs: [], defaultAttrs: {}}
  [indexAllProvidersRunner]
  [indexAllAttrsRunner]
  [showUserRunner, {name}]
]

view = ({mode, name, user, providers, attrs, defaultAttrs}) ->
  provider_userdatas =
    for provider in providers
      (user.userdata_list.find (data) -> data.provider.name == provider.name)?.userdata

  html.div {}, [
    basicInfo {mode, user}
    operationMenu {mode, user}
    groupMembership {}
    providerReg {mode, user, providers}
    attrList {mode, user, providers, attrs, defaultAttrs}
  ]


node = document.getElementById('admin_user')

app {init, view, node}
