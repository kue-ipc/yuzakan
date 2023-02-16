# pagination

import {pickType, getQueryParamsFromUrl} from '/assets/utils.js'

export DEFAULT_PAGE = 1
export DEFAULT_PER_PAGE = 20
export MIN_PAGE = 1
export MAX_PAGE = 10000
export MIN_PER_PAGE = 10
export MAX_PER_PAGE = 100
export PAGE_PARAMS_TYPES = {
  page: 'integer'
  per_page: 'integer'
}
CONTENT_RANGE_TYPES = {
  total: 'integer'
  start: 'integer'
  end: 'integer'
}

export PAGINATION_KEY = 'pagination'

CONTENT_RANGE_REGEXP = /^items\s+(?<start>\d+)-(?<end>\d+)\/(?<total>\d+)$/

export extractPagination = (contentRange, location) ->
  match = CONTENT_RANGE_REGEXP.exec(contentRange)
  if match
    {
      pickType(getQueryParamsFromUrl(new URL(location, globalThis.location)), PAGE_PARAMS_TYPES)...
      pickType(match.groups, CONTENT_RANGE_TYPES)...
    }
  else
    console.error 'invalid content range: %s', contentRange
    {}
