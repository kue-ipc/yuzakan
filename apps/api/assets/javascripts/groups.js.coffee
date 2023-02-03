# /api/groups

import {
  createRunIndexWithPage
  createRunShowWithId
  createRunUpdateWithId
  createRunDestroyWithId
} from './hyper_json.js'

export API_GROUPS = '/api/groups'

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
  createRunIndexWithPage({params..., action: createSetGroups(action), url: API_GROUPS, dataKeys: [
    'sync'
    'query'
    'filters'
  ]})

export createRunShowGroup = ({action = null, params...} = {}) ->
  createRunShowWithId({params..., action: createSetGroup(action), url: API_GROUPS, idKey: 'name', dataKeys: [
    'sync'
  ]})

# Effecters

export runIndexWithPageGroups = createRunIndexWithPageGroups()

export runShowGroup = createRunShowGroup()
