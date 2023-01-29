# await: true

puts 'hyperapp2'

module Hyperapp
  JSModule = JS.import('./hyperapp.js').__await__

  @@view_stack = []

  module_function

  def h(tag, **props, &block)
    children =
      if block_given?
        @@view_stack.push([])
        block.call
        @@view_stack.pop
      end
    view = JSModule.h(tag, props, children)
    @@viwe_stack.last&.push(view)
    $$.console.log(view)
    view
  end

  def text(content)
    view = JSModule.text(content)
    @@viwe_stack.last&.push(view)
    view
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

$$.console.log(Hyperapp::JSModule)


include Hyperapp

view = lambda { |state|
  puts state
  h('div') { text('テスト') }
}

app(
  view: view,
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
