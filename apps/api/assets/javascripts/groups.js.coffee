# /api/groups

import {
  createRunIndexWithPage
  createRunShowWithId
  createRunCreateWithId
  createRunUpdateWithId
  createRunDestroyWithId
} from './hyper_json.js'

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

# create Effecters

export createRunIndexGroups = ({action = SetGroups, params...} = {}) ->
  createRunIndex({
    action
    url: API_GROUPS
    dataTypes: omit(INDEX_GROUPS_PARAM_TYPES, ['page', 'per_page', 'sync'])
    data: {page: 'all'}
    params...
  })

export createRunIndexWithPageGroups = ({action = SetGroups, params...} = {}) ->
  createRunIndexWithPage({
    action
    url: API_GROUPS
    dataTypes: INDEX_GROUPS_PARAM_TYPES
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
