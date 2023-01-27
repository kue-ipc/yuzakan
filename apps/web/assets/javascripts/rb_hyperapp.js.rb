puts 'a'

module Hyperapp
  JSModule = Native.import('./hyperapp.js')

  module_function

  def h(tag, **_props, &chidren_block)
    children = chidren_block.call
    JSModule.h(tag, pros, children)
  end

  def text(content)
    JSModule.text(content)
  end

  def app(init: {}, view: nil, node: nil, subscriptions: nil, dispatch: :itself.to_proc)
    JSModule.app({
      init: init,
      view: view,
      node: node,
      subscriptions: subscriptions,
      dispatch: dispatch,
    })
  end

  def memo(view, data = nil)
    JSModule.memo(view, data)
  end
end

include Hyperapp

app(
  view: lambda { |_state|
    h('div') { text('テスト') }
  },
  node: $$.document.getElementById('test'))

# add_todo = lambda do |state|
#   {
#     **state,
#     value: '',
#     todos: state.todos.concat(state.value),
#   }
# end

# new_value = lambda do |state, event|
#   {
#     **state,
#     value: event.target.value,
#   }
# end

# hyperapp.app({
#   init: {todos: [], value: ''},
#   view: lambda do |_todos, _value|
#     hyperapp.h('main', {}, [
#                  hyperapp.h('p', {}, hyperapp.text('To do list')),
#                ])
#   end,
#   node: document.JS.getElementById('test'),
# })

# class Hyperapp
# end

# `
# const view = (state, actions) => /*#__PURE__*/
# React.createElement("main", null, /*#__PURE__*/React.createElement("h1", null, state.count), /*#__PURE__*/React.createElement("button", {
#   onclick: actions.down
# }, "-"), /*#__PURE__*/React.createElement("button", {
#   onclick: actions.up
# }, "+"));
# `
