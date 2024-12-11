# frozen_string_literal: true

# await: true

puts "hyperapp2"

module Hyperapp
  JSModule = JS.import("./hyperapp.js").__await__

  @@view_stack = [] # rubocop: disable Style/ClassVars

  module_function def h(tag, **props, &block)
    children =
      if block_given?
        @@view_stack.push([])
        block.call
        @@view_stack.pop
      end
    view = JSModule.JS.h(tag, props.to_n, children)
    @@view_stack.last&.push(view)
    view
  end

  module_function def text(content)
    view = JSModule.JS.text(content)
    @@view_stack.last&.push(view)
    view
  end

  module_function def app(init: {}, view: nil, node: nil, subscriptions: nil, dispatch: :itself.to_proc)
    JSModule.JS.app({
      init: init,
      view: view,
      node: node,
      subscriptions: subscriptions,
      dispatch: dispatch,
    }.to_n)
  end

  module_function def memo(view, data = nil)
    JSModule.memo(view, data)
  end
end

include Hyperapp # rubocop: disable Style/MixinUsage

view = ->(_state) {
  h("div") { text("テスト") }
}

app(
  view: view,
  node: $$.document.getElementById("test"))

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
