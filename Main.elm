module Main where

import Graphics.Element exposing (..)
import Time exposing (..)
import Canvas exposing (..)
import Mouse
import Basics exposing (pi)
import Color exposing (..)
import Task exposing (Task, andThen, toResult)

w = 1024
h = 768

c = circle 512 384 32

styleCmds =
  [ strokeColor red
  , shadowBlur 10
  , shadowColor blue
  , shadowOffset 5 5
  , lineWidth 2
  , lineCap ButtCap
  , lineJoin RoundJoin
  ]

linGrad = linear (0, 0) (w, h)
  [ (0, green)
  , (1, lightBlue)
  ]

radGrad = radial (75, 50) 5 (90, 60) 100
  [ (0, red), (1, white) ]

drawCmds =
  [ fillGrad linGrad
  , fillRect 0 0 w h
  , fillColor orange
  , strokePath
    [ moveTo 20 20
    , lineTo 100 20
    , arcTo 150 20 150 70 50
    , lineTo 150 120
    ]
  , fillCircle c
  , strokeCircle c
  , context
    [ composite HardLight
    , translate -100 -100
    , fillCircle c
    ]
  , strokeColor purple

  , font "50px Arial"
  , fillText "Elm-Canvas" 450 100
  ]

commands = styleCmds ++ drawCmds

type alias Model =
  { w : Int
  , h : Int
  , commands : List Command
  }

model = Signal.constant
  { w = 1024
  , h = 768
  , commands = commands
  }

view : Model -> Result String Image -> Element
view model result =
  let
    drawImg = case result of
      Err _ -> []
      Ok img -> [fillPattern img Repeat, fillCircle (circle 200 200 128)]
  in
    canvas (model.w, model.h) (model.commands ++ drawImg)

main : Signal Element
main = Signal.map2 view model results.signal

results : Signal.Mailbox (Result String Image)
results = Signal.mailbox (Err "Image not found")

imageSrc = "http://inkarnate.com/images/map-builder/skins/darkfantasy-world/objects/compass.png"

port updateImage : Task String ()
port updateImage =
  (loadImage imageSrc |> Task.toResult) `andThen` Signal.send results.address
