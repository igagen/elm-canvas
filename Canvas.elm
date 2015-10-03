module Canvas where

import Graphics.Element exposing (Element)
import Basics exposing (pi)
import Color exposing (..)
import Native.Canvas
import Task exposing (Task)

-- Line Styles

type LineCap = ButtCap | RoundCap | SquareCap
type LineJoin = RoundJoin | BevelJoin | MiterJoin

-- Composite Operations

type CompositeOperation
  = SourceOver
  | SourceIn
  | SourceOut
  | SourceAtop
  | DestinationOver
  | DestinationIn
  | DestinationOut
  | DestinationAtop
  | Lighter
  | Copy
  | Xor
  | Multiply
  | Screen
  | Overlay
  | Darken
  | Lighten
  | ColorDodge
  | ColorBurn
  | HardLight
  | SoftLight
  | Difference
  | Exclusion
  | Hue
  | Saturation
  | Color
  | Luminosity

-- Paths

type alias HasPoint a = { a | x: Float, y: Float }
type alias HasCircle a = HasPoint { a | r: Float }
type alias HasRect a = HasPoint { a | w: Float, h: Float }
type alias Point = HasPoint {}
type alias Circle = HasCircle {}
type alias Rectangle = HasRect {}

type PathMethod
  = MoveTo Point
  | LineTo Point
  | Rect Rectangle
  | Arc { x: Float, y: Float, r: Float, startAngle: Float, endAngle: Float, ccw: Bool }
  | ArcTo { x1: Float, y1: Float, x2: Float, y2: Float, r: Float }
  | ClosePath

type alias Path = List PathMethod

-- Images

type Image = Image

type PatternRepeat
  = Repeat
  | RepeatX
  | RepeatY
  | NoRepeat

type Pattern
  = PatternImage Image PatternRepeat

-- Commands

type Command
  -- Draw Commands
  = Clear Rectangle
  | FillPath Path
  | StrokePath Path
  | FillText String Float Float
  | StrokeText String Float Float
  | DrawImage Float Float Image

  -- State Commands
  | FillColor Color
  | StrokeColor Color
  | FillGrad Gradient
  | StrokeGrad Gradient
  | FillPattern Pattern
  | StrokePattern Pattern

  | LineWidth Float
  | LineCapStyle LineCap
  | LineJoinStyle LineJoin
  | LineMiterLimit Float

  | ShadowBlur Float
  | ShadowColor Color
  | ShadowOffset Float Float

  | Translate Float Float
  | Rotate Float
  | Scale Float Float

  | Font String
  | Alpha Float
  | Composite CompositeOperation

  -- Wraps Commands in Save/Restore
  | Context (List Command)

-- Draw Commands

clearRect rect = Clear rect
fillRect x y w h = FillPath [Rect (rect x y w h)]
strokeRect x y w h = StrokePath [Rect (rect x y w h)]

fillPath path = FillPath path
strokePath path = StrokePath path

fillCircle circle = FillPath [Arc circle]
strokeCircle circle = StrokePath [Arc circle]

fillText text x y = FillText text x y
strokeText text x y = StrokeText text x y

-- Style Commands

fillColor color = FillColor color
strokeColor color = StrokeColor color
fillGrad grad = FillGrad grad
strokeGrad grad = StrokeGrad grad
fillPattern image repeat = FillPattern (PatternImage image repeat)
strokePattern image repeat = StrokePattern (PatternImage image repeat)

lineWidth width = LineWidth width
lineCap cap = LineCapStyle cap
lineJoin join = LineJoinStyle join
lineMiterLimit length = LineMiterLimit length

shadowBlur blurRadius = ShadowBlur blurRadius
shadowColor color = ShadowColor color
shadowOffset offsetX offsetY = ShadowOffset offsetX offsetY

translate x y = Translate x y
rotate angle = Rotate angle
scale scaleX scaleY = Scale scaleX scaleY

font fnt = Font fnt
alpha a = Alpha a
composite compositeOp = Composite compositeOp

context commands = Context commands

-- Path Methods

moveTo x y = MoveTo { x = x, y = y }
lineTo x y = LineTo { x = x, y = y }

rect x y w h = { x = x, y = y, w = w, h = h }

circle x y r = arc x y r 0.0 (2.0 * pi)

arcWithDir x y r startAngle endAngle ccw =
  { x = x, y = y, r = r, startAngle = startAngle, endAngle = endAngle, ccw = ccw }

arc x y r startAngle endAngle = arcWithDir x y r startAngle endAngle False

arcTo x1 y1 x2 y2 r = ArcTo { x1 = x1, y1 = y1, x2 = x2, y2 = y2, r = r }

-- Images

drawImage : Float -> Float -> Image -> Command
drawImage x y img = DrawImage x y img

loadImage : String -> Task String Image
loadImage = Native.Canvas.loadImage

-- Canvas

canvas : (Int, Int) -> List Command -> Element
canvas = Native.Canvas.canvas
