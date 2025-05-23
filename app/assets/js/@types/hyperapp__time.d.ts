declare module '@hyperapp/time' {
  import type {Action, Effect, Subscription} from "hyperapp";

  const every: <S>(delay: number, action: Action<S, Date>) => Subscription<S>;
  const delay: <S>(delay: number, action: Action<S, Date>) => Effect<S>;
  const now: <S>(action: Action<S, Date>) => Effect<S>
}
