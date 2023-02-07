# /api/groups

import {
  createRunIndexWithPage
  createRunShowWithId
  createRunUpdateWithId
  createRunDestroyWithId
} from './hyper_json.js'

export API_GROUPS = '/api/groups'

export INDEX_GROUPS_ALLOW_KEYS = ['page', 'per_page', 'sync', 'order', 'query', 'sync', 'primary_only', 'show_deleted']

export SHOW_GROUP_ALLOW_KEYS = ['sync']

# Actions

export SetGroups = (state, groups) -> {state..., groups}

export SetGroup = (state, group) -> {state..., group}

# create Actions

export createSetGroups = (action = null) ->
  if action?
    (state, groups) ->
      action(SetGroups(state, groups), groups)
  else
    SetGroups

export createSetGroup = (action = null) ->
  if action?
    (state, group) ->
      action(SetGroup(state, group), group)
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
