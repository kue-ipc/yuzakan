declare module '@hyperapp/time' {
  import type {Action, Subscription} from "hyperapp";

  const every: <S>(delay: number, action: Action<S, Date>) => Subscription<S>;
  const delay: <S>(delay: number, action: Action<S, Date>) => Subscription<S>;
  const now: <S>(action: Action<S, Date>) => Subscription<S>
}

