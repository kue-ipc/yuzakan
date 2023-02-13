# /api/groups

import {
  createRunIndexWithPage
  createRunShowWithId
  createRunUpdateWithId
  createRunDestroyWithId
} from './hyper_json.js'

export API_GROUPS = '/api/groups'

export GROUP_PROPERTIES = {
  groupname: 'string'
  display_name: 'string'
  note: 'string'
  primary: 'boolean'
  obsoleted: 'boolean'
  deleted: 'boolean'
  deleted_at: 'datetime'
}

export INDEX_GROUPS_PARAM_TYPES = {
  page: 'integer'
  per_page: 'integer'
  sync: 'boolean'
  order: 'string'
  query: 'string'
  primary_only: 'boolean'
  show_deleted: 'boolean'
}

export SHOW_GROUP_PARAM_TYPES = {
  sync: 'boolean'
}

export CREATE_GROUP_PARAM_TYPES = {
  GROUP_PROPERTIES...
}

export UPDATE_GROUP_PARAM_TYPES = {
  GROUP_PROPERTIES...
}

export DESTROY_GROUP_PARAM_TYPES = {
  permanent: 'boolean'
}

# Actions

export SetGroups = (state, groups) -> {state..., groups}

export SetGroup = (state, group) -> {state..., group}

# create Actions

export createSetGroups = (action = null) ->
  if action?
    runAction = (dispatch, groups) -> dispatch(action, groups)
    (state, groups) ->
      [
        SetGroups(state, groups)...,
        [runAction, groups]
      ]
  else
    SetGroups

export createSetGroup = (action = null) ->
  if action?
    runAction = (dispatch, group) -> dispatch(action, group)
    (state, group) ->
      [
        SetGroup(state, group)...,
        [runAction, group]
      ]
  else
    SetGroup

# create Effecters

export createRunIndexWithPageGroups = ({action = null, params...} = {}) ->
  createRunIndexWithPage({
    params...
    action: createSetGroups(action)
    url: API_GROUPS
    dataTypes: INDEX_GROUPS_PARAM_TYPES
  })

export createRunShowGroup = ({action = null, params...} = {}) ->
  createRunShowWithId({
    params...
    action: createSetGroup(action)
    url: API_GROUPS
    idKey: 'name'
    dataTypes: SHOW_GROUP_PARAM_TYPES})

# Effecters

export runIndexWithPageGroups = createRunIndexWithPageGroups()

export runShowGroup = createRunShowGroup()
