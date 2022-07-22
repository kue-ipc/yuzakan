# header

import {app, text} from './hyperapp.js'
import * as html from './hyperapp-html.js'

import {fetchJsonGet} from '../fetch_json.js'

USER_MENU = {path: '/', name: '利用者メニュー'}
ADMIN_MENU = {path: '/admin', name: '管理者メニュー'}

USER_MENU_LIST = [
  {path: '/user/password/edit', name: 'パスワード変更'}
]

ADMIN_MENU_LIST = [
  {path: '/admin/users/*', name: 'ユーザー作成'}
  {path: '/admin/users', name: 'ユーザー一覧'}
  {path: '/admin/groups', name: 'グループ一覧'}
]



headerNav = ({system, session}) ->
  html.nav {class: 'navbar navbar-expand-sm navbar-dark bg-dark-bar'},
    html.div {class: 'container-fluid'}
      if system? && session?
        navContents({system, session})
      else
        []

navContents = ({system, session}) ->
  [
    html.a {class: 'navbar-brand', href: system}, text system.title || system.app.name
    html.button {
      class: 'navbar-toggler'
      type: 'button'
      'data-bs-toggle': 'collapse'
      'data-bs-target': '#navbar-content'
      'aria-controls': 'navbar-content'
      'aria-expanded': "false"
      'aria-label': "ナビゲーション切替"
    },
      html.span {class: 'navbar-toggler-icon'}
    html.div {id: 'navbar-content', class: 'collapse navbar-collapse'},
      if session.current_user
        html.ul {class: 'navbar-nav me-auto'},
          html.li {class: 'nav-item'}
            = link_to routes.path(:root), class: 'nav-link d-flex align-items-center' do
              - text bs_icon('house', class: 'flex-shrink-0 me-1')
              - span class: 'd-none d-lg-inline' do
                - text '利用者用メニュー'
          - if current_level >= 2
            li.nav-item
              = link_to Admin.routes.path(:root), class: 'nav-link d-flex align-items-center' do
                - text bs_icon('house-heart', class: 'flex-shrink-0 me-1')
                - span class: 'd-none d-lg-inline' do
                  - text '管理者用メニュー'
          li.nav-item
            = link_to routes.path(:edit_user_password), class: 'nav-link d-flex align-items-center' do
              - text bs_icon('input-cursor-text', class: 'flex-shrink-0 me-1')
              - span class: 'd-none d-lg-inline' do
                - text 'パスワード'
          li.nav-item
            = link_to routes.path(:google), class: 'nav-link d-flex align-items-center' do
              - text bs_icon('google', class: 'flex-shrink-0 me-1')
              - span class: 'd-none d-lg-inline' do
                - text 'Google Workspace'

        = link_to routes.path(:user), class: 'me-2 link-user d-flex align-items-center' do
          - text bs_icon('person', class: 'flex-shrink-0 me-1')
          - span class: 'd-none d-lg-inline' do
            - text current_user.label_name
        .logout-button
        = javascript 'logout', defer: true, type: 'module'
      - else
        ul.navbar-nav.me-auto
          li.nav-item
            = link_to routes.path(:root), class: 'nav-link' do
              - text bs_icon('box-arrow-in-left')
              - span class: 'd-none d-lg-inline' do
                - text 'ログイン'
        span.navbar-text
          = '未ログイン'

navItem = (url, )

          html.li {class: 'nav-item'}
            = link_to routes.path(:root), class: 'nav-link d-flex align-items-center' do
              - text bs_icon('house', class: 'flex-shrink-0 me-1')
              - span class: 'd-none d-lg-inline' do
                - text '利用者用メニュー'



SetSystem = (state, {system}) ->
  {state..., system}

SetSession = (state, {session}) ->
  {state..., system}

SetMenus = (state, {menus}) ->
  {state..., menu}

runGetSystem = (dispatch) ->
  response = await fetchJsonGet({url: '/api/system'})
  if response.ok
    dispatch(SetSystem, {system: response.data})
  else
    console.error response


runGetSession = (dispatch) ->
  response = await fetchJsonGet({url: '/api/session', chace: 'reload'})
  if response.ok
    dispatch(SetSystem, {sesion: response.data})
  else if response.code == 404
    # no login
    dispatch(SetSystem, {sesion: {}})
  else
    console.error response

initState = {
  system: null
  current_user: null
}

view = (state) ->
  html.header {id: 'header'},
    headerNav state

node = document.getElementById('header')

app {
  init: [
    initState
    runGetSystem
    runGetSession
  ]
  view
  node: 
}
