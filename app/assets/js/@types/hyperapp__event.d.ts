declare module '@hyperapp/event' {
  import type {Action, Subscription} from "hyperapp";

  type OnEvent = <S>(action: Action<S>) => Subscription<S>

  const onMouseMove: OnEvent
  const onMouseDown: OnEvent
  const onMouseUp: OnEvent
  const onKeyDown: OnEvent
  const onKeyUp: OnEvent
  const onClick: OnEvent
  const onFocus: OnEvent
  const onBlur: OnEvent
}
