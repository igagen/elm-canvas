module Main where

import Graphics.Element exposing (..)
import Time exposing (..)
import Canvas exposing (..)
import Mouse
import Basics exposing (pi)
import Color exposing (..)
import Task exposing (Task, andThen, toResult)
import Window

-- Model

softBrush x y r =
  let
    stops =
      [ (0, rgba 0 0 0 1)
      , (0.05, rgba 0 0 0 0.97)
      , (0.10, rgba 0 0 0 0.92)
      , (0.15, rgba 0 0 0 0.87)
      , (0.25, rgba 0 0 0 0.75)
      , (0.5, rgba 0 0 0 0.5)
      , (0.75, rgba 0 0 0 0.20)
      , (0.85, rgba 0 0 0 0.1)
      , (0.9, rgba 0 0 0 0.05)
      , (0.95, rgba 0 0 0 0.02)
      , (1, rgba 0 0 0 0)
      ]
    radGrad = radial (x, y) 0 (x, y) r stops
  in
    [ fillGrad radGrad, fillCircle (circle x y r) ]

drawCmds = (softBrush 512 384 128) ++ (softBrush 576 384 64) ++ (softBrush 640 384 64)

colorWheel = List.concatMap wheelArc [0..11519]

wheelArc i =
  let
    angleInc = 2 * pi / 11520
    startAngle = i * angleInc
    endAngle = startAngle + angleInc
    x = 512
    y = 384
    r = 192
    s =
      [ (0, (hsl (degrees (i / 32)) 0 1))
      , (0.1, (hsl (degrees (i / 32)) 0 1))
      , (1, (hsl (degrees (i / 32)) 1 0.5))
      ]
    radGrad = radial (x, y) 0 (x, y) r s
  in
    [ fillGrad radGrad
    , fillPath [arc x y r startAngle endAngle, lineTo x y]
    ]

commands = [fillColor (rgb 32 32 32), fillRect 0 0 1024 768] ++ colorWheel

type alias Model =
  { w : Int
  , h : Int
  , commands : List Command
  }

initialModel : Model
initialModel =
  { w = 1024
  , h = 768
  , commands = commands
  }


-- Update

type Action = Resize (Int, Int)

update : Action -> Model -> Model
update action model =
  case action of
    Resize (w, h) ->
      { model
      | w <- w
      , h <- h
      , commands <- [fillColor (rgb 32 32 32), fillRect 0 0 (toFloat w) (toFloat h)] ++ colorWheel
      }

-- View

view : Model -> Element
view model =
  layers [canvas "fg" (model.w, model.h) model.commands]


-- Signals

dimensions : Signal Action
dimensions = Signal.map (\(w, h) -> Resize (w, h)) Window.dimensions

input : Signal Action
input =
  Signal.mergeMany [dimensions]

model : Signal Model
model = Signal.foldp update initialModel input

main : Signal Element
main = Signal.map view model


-- results : Signal.Mailbox (Result String Image)
-- results = Signal.mailbox (Err "Image not found")

-- imageSrc = "http://inkarnate.com/images/map-builder/skins/darkfantasy-world/textures/land.jpg"

-- port runner : Task String ()
-- port runner =
--   (loadImage imageSrc |> Task.toResult) `andThen` Signal.send results.address
