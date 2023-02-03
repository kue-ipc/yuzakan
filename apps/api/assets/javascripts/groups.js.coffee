# /api/groups

# import {createRunPage, createRunGetWithPagination} from './run_json.js'

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

export createSetGroups = (action) ->
  (state, groups) ->
    action(SetGroups(state, groups), groups)

export createSetGroup = (action) ->
  (state, group) ->
    action(SetGroup(state, group), group)

export createRunIndexGroups = ({action = null} = {}) ->
  setAction =
    if action?
      createSetGroups(action)
    else
      SetGroups
  createRunIndexWithPage({action: setAction, url: API_GROUPS, dataKeys: [
    'sync'
    'query'
    'filters'
  ]})

export runIndexGroups = createRunIndexGroups()

export createRunShowGroup = ({action = null} = {}) ->
  setAction =
    if action?
      createSetGroup(action)
    else
      SetGroup
  createRunShowWithId({action: setAction, url: API_GROUPS, idKey: 'name', dataKeys: [
    'sync'
  ]})

export runShowGroup = createRunShowGroup()


# export createRunGetGroups = (action = SetGroups) -> createRunGetWithPagination(action, API_GROUPS)



# export createRunPageGroups = (action = SetGroups) -> createRunPage(action, API_GROUPS, ['query'])

# export PageGroups = (state) -> [state, [runPageGroups, state]]



# export runGetGroups = createRunGetGroups()

# export runPageGroups = createRunPageGroups()


