# check modern browser

# ES2018

# Test cods copied from 'ECMAScript compatibility tables'
# https://github.com/kangax/compat-table/
# Copyright (c) 2010-2013 Juriy Zaytsev
# MIT License

# object rest/spread properties
objectRestProperties = ->
  {a, ...rest} = a: 1, b: 2, c: 3
  a == 1 && rest.a == undefined && rest.b == 2 && rest.c == 3

objectSpreadProperties = ->
  spread = b: 2, c: 3
  O = {a: 1, ...spread}
  O != spread && (O.a + O.b + O.c) == 6;

# Asynchronous Iterators
asyncTestPassed = ->

asyncGenerators = ->
  generator = ->
    yield await new Promise((r) -> r(42))
  iterator = generator()
  iterator.next().then (step) ->
    if iterator[Symbol.asyncIterator]() == iterator &&
        step.done == false && step.value == 42
      asyncTestPassed()

asyncGenerators()

if objectRestProperties() && objectRestProperties()
  window.MODERN_BROWESER = true
else
  throw 'no modern browser'
