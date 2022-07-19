import {text} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

import {DL_CLASSES, DT_CLASSES, DD_CLASSES} from '../dl_horizontal.js'
import {CLEARANCE_LEVELS} from '../definition.js'
import {createEventValueAction} from '../input_event.js'

import {CalcUserAttrs} from './admin_user_attrs.js'

SetUserName = (state, name) -> [CalcUserAttrs, {user: {state.user..., name}}]
SetUserNameByEvent = createEventValueAction(SetUserName)

SetUserClearanceLevel = (state, clearance_level) -> {state..., user: {state.user..., clearance_level}}
SetUserClearanceLevelByEvent = createEventValueAction(SetUserClearanceLevel, {type: 'integer'})

SetUserPrimaryGroup = (state, primary_group) -> {state..., user: {state.user..., primary_group}}
SetUserPrimaryGroupByEvent = createEventValueAction(SetUserPrimaryGroup, {type: 'string'})

export default basicInfo = ({mode, user, groups}) ->
  html.div {}, [
    html.h4 {}, text '基本情報'
    html.dl {class: DL_CLASSES}, [
      html.dt {class: DT_CLASSES},
        html.label {class: 'form-label', for: 'user-name'}, text 'ユーザー名'
      html.dd {class: DD_CLASSES},
        switch mode
          when 'new'
            html.input {
              id: 'user-name'
              class: 'form-control'
              type: 'text'
              required: true
              value: user.name
              oninput: SetUserNameByEvent
            }
          when 'edit'
            html.input {
              id: 'user-name'
              class: 'form-control-plaintext'
              readonly: true
              type: 'text'
              value: user.name
            }
          when 'show'
            text user.name
      html.dt {class: DT_CLASSES},
        text '表示名'
      html.dd {class: DD_CLASSES},
        if mode == 'new'
          html.span {class: 'text-muted'}, text '(属性値にて設定)'
        else
          text user.display_name ? ''
      html.dt {class: DT_CLASSES},
        text 'メールアドレス'
      html.dd {class: DD_CLASSES},
        if mode == 'new'
          html.span {class: 'text-muted'}, text '(属性値にて設定)'
        else
          text user.email ? ''
      html.dt {class: DT_CLASSES},
        text '権限レベル'
      html.dd {class: DD_CLASSES},
        if mode == 'show'
          text (CLEARANCE_LEVELS.find (level) -> level.value == user.clearance_level).label
        else
          html.select {
            class: 'form-select'
            oninput: SetUserClearanceLevelByEvent
          },
            for level in CLEARANCE_LEVELS
              html.option {
                value: level.value
                selected: level.value == user.clearance_level
              }, text level.label
      html.dt {class: DT_CLASSES},
        text 'プライマリーグループ'
      html.dd {class: DD_CLASSES},
        if mode == 'show'
          if user.primary_group
            primary_group = groups.find (group) -> group.name == user.primary_group
            text "#{primary_group.display_name} (#{primary_group.name})"
          else
            text "(無し)"
        else
          html.select {
            class: 'form-select'
            oninput: SetUserPrimaryGroupByEvent
          }, [
            if mode == 'new'
              html.option {
                selected: !user.primary_group?
              }, text "選択してください。"
            (
              for group in groups
                html.option {
                  value: group.name
                  selected: group.name == user.primary_group
                }, text "#{group.display_name} (#{group.name})"
            )...
          ]
       ]
  ]
