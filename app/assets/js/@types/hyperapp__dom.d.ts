declare module '@hyperapp/dom' {
  import type {Effect} from "hyperapp";

  const focus: <S>(id: string, props?: {preventScroll?: boolean}) => Effect<S>;
  const blure: <S>(id: string) => Effect<S>;
}
