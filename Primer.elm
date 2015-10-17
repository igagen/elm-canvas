
module Primer where


{-| Just triggers an event on a signal to propagate its initial value.

```elm

import Window
import StartApp
import Awesome exposing (init, update, view, Action(Viewport))
import Primer


viewport : Signal Action
viewport =
    Signal.map Viewport (Primer.prime Window.dimensions)


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = [ viewport ]
    }

```

@docs prime
-}


import Native.Primer


{-| Takes a signal, schedules an immediate event, and returns the signal. -}
prime : Signal a -> Signal a
prime =
    Native.Primer.prime
