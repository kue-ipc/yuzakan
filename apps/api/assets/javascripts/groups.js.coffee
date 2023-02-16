# /api/groups

import {
  createRunIndexWithPage
  createRunShowWithId
  createRunCreateWithId
  createRunUpdateWithId
  createRunDestroyWithId
} from './hyper_json.js'

import {PAGINATION_PARAMS_TYPES} from './pagination.js'

import {pickType} from '/assets/utils.js'

export API_GROUPS = '/api/groups'

export GROUP_PROPERTIES = {
  groupname: 'string'
  display_name: 'string'
  note: 'string'
  primary: 'boolean'
  prohibited: 'boolean'
  deleted: 'boolean'
  deleted_at: 'datetime'
}

export INDEX_GROUPS_PARAM_TYPES = {
  sync: 'boolean'
  order: 'string'
  query: 'string'
  primary_only: 'boolean'
  hide_prohibited: 'boolean'
  show_deleted: 'boolean'
}

export INDEX_WITH_PAGE_GROUPS_PARAM_TYPES = {
  PAGINATION_PARAMS_TYPES...
  INDEX_GROUPS_PARAM_TYPES...
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

# Functions

export normalizeGroup = (group, types = {}) ->
  pickType(group, {
    GROUP_PROPERTIES...
    data: 'map'
    providers: 'map'
    types...
  })


# Actions

export SetGroups = (state, groups) -> {state..., groups}

export SetGroup = (state, group) -> {state..., group}

# create Effecters

export createRunIndexGroups = ({action = SetGroups, params...} = {}) ->
  createRunIndex({
    action
    url: API_GROUPS
    dataTypes: INDEX_GROUPS_PARAM_TYPES
    params...
  })

export createRunIndexWithPageGroups = ({action = SetGroups, params...} = {}) ->
  createRunIndexWithPage({
    action
    url: API_GROUPS
    dataTypes: INDEX_WITH_PAGE_GROUPS_PARAM_TYPES
    params...
  })

export createRunShowGroup = ({action = SetGroup, params...} = {}) ->
  createRunShowWithId({
    action
    url: API_GROUPS
    dataTypes: SHOW_GROUP_PARAM_TYPES
    params...
  })

export createRunCreateGroup = ({action = SetGroup, params...} = {}) ->
  createRunCreateWithId({
    action
    url: API_GROUPS
    dataTypes: CREATE_GROUP_PARAM_TYPES
    params...
  })

export createRunUpdateGroup = ({action = SetGroup, params...} = {}) ->
  createRunUpdateWithId({
    action
    url: API_GROUPS
    dataTypes: UPDATE_GROUP_PARAM_TYPES
    params...
  })

export createRunDestroyGroup = ({action = SetGroup, params...} = {}) ->
  createRunDestroyWithId({
    action
    url: API_GROUPS
    dataTypes: DESTROY_GROUP_PARAM_TYPES
    params...
  })
