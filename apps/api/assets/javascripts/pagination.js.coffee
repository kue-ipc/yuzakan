# pagination

# see lib/yuzakan/utils/pager.rb

import {pickType, getQueryParamsFromUrl} from '~/common/helper.js'

export DEFAULT_PAGE = 1
export DEFAULT_PER_PAGE = 20
export MIN_PAGE = 1
export MAX_PAGE = 10000
export MIN_PER_PAGE = 10
export MAX_PER_PAGE = 100
export PAGINATION_PARAM_TYPES = {
  page: 'integer'
  per_page: 'integer'
}
CONTENT_RANGE_TYPES = {
  total: 'integer'
  start: 'integer'
  end: 'integer'
}

CONTENT_RANGE_REGEXP = /^items\s+(?<start>\d+)-(?<end>\d+)\/(?<total>\d+)$/

export extractPagination = (contentRange, location) ->
  match = CONTENT_RANGE_REGEXP.exec(contentRange)
  if match
    {
      pickType(getQueryParamsFromUrl(new URL(location, globalThis.location)), PAGINATION_PARAM_TYPES)...
      pickType(match.groups, CONTENT_RANGE_TYPES)...
    }
  else
    console.error 'invalid content range: %s', contentRange
    {}
