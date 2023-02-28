# /api/system

import {
  createRunShow
} from './hyper_json.js'

import {pickType} from '/assets/common/helper.js'

# Contants

export API_SYSTEM = '/api/system'

export SYSTEM_PROPERTIES = {
  title: 'string'
  url: 'string'
  domain: 'string'
  app: 'object'
  contact: 'object'
}

SYSTEM_APP_PROPERTIES = {
  name: 'string'
  version: 'string'
  license: 'string'
}

SYSTEM_CONTACT_PROPERTIES = {
  name: 'string'
  email: 'string'
  phone: 'string'
}

# Functions

export normalizeSystem = (system, types = {}) ->
  system = pickType(system, {SYSTEM_PROPERTIES..., types...})
  system.app = pickType(system.app, SYSTEM_APP_PROPERTIES) if system.app
  system.contact = pickType(system.contact, SYSTEM_CONTACT_PROPERTIES) if system.contact
  system

# Actions

export SetSystem = (state, system) -> {
  state...
  system
}

# create Effecters

export createRunShowSystem = (params = {}) ->
  createRunShow({
    action: SetSystem
    normalizer: normalizeSystem
    url: API_SYSTEM
    params...
  })
