# /api/groups

import {
  createRunIndexWithPage
  createRunShowWithId
  createRunUpdateWithId
  createRunDestroyWithId
} from './hyper_json.js'

export API_GROUPS = '/api/groups'

export INDEX_GROUPS_ALLOW_KEYS = {
  page: 'integer'
  per_page: 'integer'
  sync: 'boolean'
  order: 'string'
  query: 'string'
  primary_only: 'boolean'
  show_deleted: 'boolean'
}

export SHOW_GROUP_ALLOW_KEYS = {
  sync: 'boolean'
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
    dataKeys: INDEX_GROUPS_ALLOW_KEYS
  })

export createRunShowGroup = ({action = null, params...} = {}) ->
  createRunShowWithId({
    params...
    action: createSetGroup(action)
    url: API_GROUPS
    idKey: 'name'
    dataKeys: SHOW_GROUP_ALLOW_KEYS})

# Effecters

export runIndexWithPageGroups = createRunIndexWithPageGroups()

export runShowGroup = createRunShowGroup()
