# apps for Hyperapp

それぞれの型は次のようになる

appの引数

- `init: Dispachable<S>`
- `subscriptions: (state: S) => readonly (boolean | undefined | Subscription<S>)[]`
- `dispatch: (dispatch: Dispatch<S>) => Dispatch<S>`
- `view: (state: S) => VNode<S>`
- `node: Node`

```civet
View: <S, P>(porps: P, children?: aybeVNode<S> | readonly MaybeVNode<S>[]) => VNode<S>
Action: Action<S, P> = (state: S, payload: P) => Dispatchable<S>
Effect: Effect<S, P> = 
    | Effecter<S, P>
    | readonly [effecter: Effecter<S, P>, payload: P]
Effecter: Effecter<S, P = any> = (dispatch: Dispatch<S>, payload: P) => void | Promise<void>
Subscription: Subscription<S, P> = readonly [
  subscriber: (dispatch: Dispatch<S>, payload: P) => Unsubscribe,
  payload: P
]
Subscriber: (dispatch: Dispatch<S>, payload: P) => Unsubscribe
Dispatch: Dispatch<S>
```

classはClassProp型を使う

```
type Dispatchable<S, P = any> =
    | S
    | [state: S, ...effects: MaybeEffect<S, P>[]]
    | Action<S, P>
    | readonly [action: Action<S, P>, payload: P]
```
