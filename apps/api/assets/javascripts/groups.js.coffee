# /api/groupscreateRunCreateWithId

import {
  createRunIndex
  createRunIndexWithPage
  createRunShowWithId
  createRunCreateWithId
  createRunUpdateWithId
  createRunDestroyWithId
} from '/assets/api/hyper_json.js'

import {PAGINATION_PARAM_TYPES} from '/assets/api/pagination.js'
import {SEARCH_PARAM_TYPES} from '/assets/api/search.js'
import {ORDER_PARAM_TYPES} from '/assets/api/order.js'

import {pickType} from '/assets/common/helper.js'

# Contants

export API_GROUPS = '/api/groups'

export GROUP_PROPERTIES = {
  name: 'string'
  display_name: 'string'
  note: 'string'
  primary: 'boolean'
  prohibited: 'boolean'
  deleted: 'boolean'
  deleted_at: 'datetime'
}

export GROUP_DATA_PROPERTIES = {
  groupname: 'string'
  display_name: 'string'
  primary: 'boolean'
}

export INDEX_GROUPS_OPTION_PARAM_TYPES = {
  no_sync: 'boolean'
  primary_only: 'boolean'
  hide_prohibited: 'boolean'
  show_deleted: 'boolean'
}

export INDEX_GROUPS_PARAM_TYPES = {
  SEARCH_PARAM_TYPES...
  ORDER_PARAM_TYPES...
  INDEX_GROUPS_OPTION_PARAM_TYPES...
}

export INDEX_WITH_PAGE_GROUPS_PARAM_TYPES = {
  PAGINATION_PARAM_TYPES...
  INDEX_GROUPS_PARAM_TYPES...
}

export SHOW_GROUP_PARAM_TYPES = {
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

export normalizeGroups = (groups, type ={}) ->
  normalizeGroup(group, type) for group in groups

export normalizeGroup = (group, types = {}) ->
  providersData =
    if !group.providers?
      {}
    else if group.providers instanceof Array
      {providers: group.providers}
    else
      {
        providers: (provider for provider, data of group.providers when data?)
        providers_data: new Map(
          [provider, pickType(data, GROUP_DATA_PROPERTIES)] for provider, data of group.providers when data?
        )
      }

  {
    pickType(group, {GROUP_PROPERTIES..., types...})...
    providersData...
  }

# Actions

export SetGroups = (state, groups) -> {
  state...
  groups
}

export SetGroup = (state, group) -> {
  state...
  group
}

# create Effecters

export createRunIndexGroupsNoSnyc = ({data = {}, params...} = {}) ->
  createRunIndex({
    action: SetGroups
    normalizer: normalizeGroups
    url: API_GROUPS
    dataTypes: INDEX_GROUPS_PARAM_TYPES
    data: {no_sync: true, data...}
    params...
  })

export createRunIndexWithPageGroups = (params = {}) ->
  createRunIndexWithPage({
    action: SetGroups
    normalizer: normalizeGroups
    url: API_GROUPS
    dataTypes: INDEX_WITH_PAGE_GROUPS_PARAM_TYPES
    params...
  })

export createRunShowGroup = (params = {}) ->
  createRunShowWithId({
    action: SetGroup
    normalizer: normalizeGroup
    url: API_GROUPS
    dataTypes: SHOW_GROUP_PARAM_TYPES
    params...
  })

export createRunCreateGroup = (params = {}) ->
  createRunCreateWithId({
    action: SetGroup
    normalizer: normalizeGroup
    url: API_GROUPS
    dataTypes: CREATE_GROUP_PARAM_TYPES
    params...
  })

export createRunUpdateGroup = (params = {}) ->
  createRunUpdateWithId({
    action: SetGroup
    normalizer: normalizeGroup
    url: API_GROUPS
    dataTypes: UPDATE_GROUP_PARAM_TYPES
    params...
  })

export createRunDestroyGroup = (params = {}) ->
  createRunDestroyWithId({
    action: SetGroup
    normalizer: normalizeGroup
    url: API_GROUPS
    dataTypes: DESTROY_GROUP_PARAM_TYPES
    params...
  })
