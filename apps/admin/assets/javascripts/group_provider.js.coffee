# グループ

import {text} from 'hyperapp'
import * as html from '@hyperapp/html'

import {entityLabel} from '~/common/helper.js'
import valueDisplay from '~/app/value_display.js'

# Views

export default groupProvider = ({mode, group, providers}) ->
  html.div {key: 'group-provider'}, [
    html.h4 {}, text '登録状況'
    html.table {class: 'table'}, [
      html.thead {},
        html.tr {}, [
          html.th {}, text ''
          (html.th({}, text entityLabel(provider)) for provider in providers)...
        ]
      html.tbody {},
        for {name, label, type} in [
          {name: 'name', label: 'グループ名', type: 'string'}
          {name: 'display_name', label: '表示名', type: 'string'}
          {name: 'primary', label: 'プライマリ', type: 'boolean'}
        ]
          html.tr {}, [
            html.td {}, text label
            # html.td {}, valueDisplay {value: group[name], type}
            (for provider in providers
              groupdata = group.providers_data?.get(provider.name)
              html.td {},
                valueDisplay {
                  value: groupdata?[name]
                  type
                  color: if group[name]
                    if group[name] == groupdata?[name]
                      'success'
                    else
                      'danger'
                  else
                    'body'
                }
            )...
          ]
    ]
  ]
