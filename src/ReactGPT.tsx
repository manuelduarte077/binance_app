import { RouterProvider } from "react-router-dom";
import { routes } from "./presentation/router/router";

export const ReactGPT = () => {
  return (
    <RouterProvider
      router={routes}
    />
  );
};
