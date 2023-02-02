import {fetchJsonGet} from '/assets/api/fetch_json.js'
import {InitUserAttrs} from './user_attrs.js'

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

SetMode = (state, mode) -> {state..., mode}

export runGetUserWithInit = (dispatch, {name}) ->
  if name?
    response = await fetchJsonGet({url: "/api/users/#{name}"})
    if response.ok
      dispatch(SetUserWithInit, {user: response.data})
    else if response.code == 404
      dispatch(SetMode, 'none')
    else
      console.error response
  else
    dispatch(SetUserWithInit, {user: newUser})
