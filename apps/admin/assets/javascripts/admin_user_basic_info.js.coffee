import {text} from '../hyperapp.js'
import * as html from '../hyperapp-html.js'

import * as dlh from '../dl_horizontal.js'
import {CLEARANCE_LEVELS} from '../definition.js'
import {createEventValueAction} from '../input_event.js'

import {CalcUserAttrs} from './admin_user_attrs.js'

SetUserUsername = (state, username) ->
  email =
    if !state.user.email || state.user.email == "#{state.user.username}@#{state.system.domain}"
      if username
        "#{username}@#{state.system.domain}"
      else
        ''
    else
      state.user.email

  [CalcUserAttrs, {user: {state.user..., username, email}}]
SetUserUsernameByEvent = createEventValueAction(SetUserUsername)

SetUserDisplayName = (state, display_name) -> [CalcUserAttrs, {user: {state.user..., display_name}}]
SetUserDisplayNameByEvent = createEventValueAction(SetUserDisplayName)

SetUserEmail = (state, email) -> [CalcUserAttrs, {user: {state.user..., email}}]
SetUserEmailByEvent = createEventValueAction(SetUserEmail)

SetUserClearanceLevel = (state, clearance_level) -> {state..., user: {state.user..., clearance_level}}
SetUserClearanceLevelByEvent = createEventValueAction(SetUserClearanceLevel, {type: 'integer'})

SetUserPrimaryGroup = (state, primary_group) -> [CalcUserAttrs, {user: {state.user..., primary_group}}]
SetUserPrimaryGroupByEvent = createEventValueAction(SetUserPrimaryGroup)

export default basicInfo = ({mode, user, groups}) ->
  html.div {}, [
    html.h4 {}, text '基本情報'
    dlh.dl {}, [
      dlh.dt {},
        html.label {class: 'form-label', for: 'user-username'}, text 'ユーザー名'
      dlh.dd {},
        switch mode
          when 'new'
            html.input {
              id: 'user-username'
              class: 'form-control'
              type: 'text'
              required: true
              value: user.username ? ''
              oninput: SetUserUsernameByEvent
            }
          when 'edit'
            html.input {
              id: 'user-username'
              class: 'form-control-plaintext'
              readonly: true
              type: 'text'
              value: user.username ? ''
            }
          when 'show'
            text user.username
      dlh.dt {},
        text '表示名'
      dlh.dd {},
        if mode == 'show'
          text user.display_name ? ''
        else
          html.input {
            id: 'user-display_name'
            class: 'form-control'
            type: 'text'
            required: true
            value: user.display_name ? ''
            oninput: SetUserDisplayNameByEvent
          }
      dlh.dt {},
        text 'メールアドレス'
      dlh.dd {},
        if mode == 'show'
          text user.email ? ''
        else
          html.input {
            id: 'user-display_name'
            class: 'form-control'
            type: 'text'
            required: true
            value: user.email ? ''
            oninput: SetUserEmailByEvent
          }
      dlh.dt {},
        text '権限レベル'
      dlh.dd {},
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
      dlh.dt {},
        text 'プライマリーグループ'
      dlh.dd {},
        if mode == 'show'
          if user.primary_group
            primary_group = groups.find (group) -> group.groupname == user.primary_group
            text if primary_group.display_name
              "#{primary_group.display_name} (#{primary_group.groupname})"
            else
              primary_group.groupname
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
                  value: group.groupname
                  selected: group.groupname == user.primary_group
                }, text if group.display_name then "#{group.display_name} (#{group.groupname})" else group.groupname
            )...
          ]
    ]
  ]
