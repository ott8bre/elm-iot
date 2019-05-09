module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

--import Html exposing (..)
--import Plot exposing (view)

import Browser
import Html
import Html.Attributes exposing (class)
import Http
import Json.Decode as D
import LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Range as Range
import LineChart.Axis.Tick as Tick
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Title as Title
import LineChart.Axis.Values as Values
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk exposing (..)
import LineChart.Legends as Legends
import LineChart.Line as Line
import Task
import Time



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- COMMANDS


getData : Cmd Msg
getData =
    Http.get
        { url = "http://localhost:3000/"
        , expect = Http.expectJson GotData (D.list D.float)
        }



-- MODEL


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    , data : List ( Time.Posix, Float )
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0) []
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | GotData (Result Http.Error (List Float))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , getData
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )

        GotData result ->
            case result of
                Ok floats ->
                    case floats of
                        x :: xs ->
                            ( { model | data = ( model.time, x ) :: List.take 59 model.data }
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW
{-
   view : Model -> Html Msg
   view model =
       let
           hour =
               String.fromInt (Time.toHour model.zone model.time)

           minute =
               String.fromInt (Time.toMinute model.zone model.time)

           second =
               String.fromInt (Time.toSecond model.zone model.time)
       in
       h1 [] [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]
-}
{-
   view : Model -> Html.Html Msg
   view model =
       let
           fun ( p, f ) =
               let
                   second =
                       String.fromInt (Time.toSecond model.zone p)

                   value =
                       String.fromFloat f
               in
               Html.div [] [ Html.text (second ++ " " ++ value) ]

           xxx =
               List.map fun model.data
       in
       Html.h1 [] xxx
-}


getPoints : Model -> List Point
getPoints model =
    let
        fun ( p, f ) =
            Point (toFloat (Time.posixToMillis p - Time.posixToMillis model.time)) f
    in
    List.map fun model.data


view : Model -> Html.Html Msg
view model =
    chart1 model



{-
   Html.div [ class "container" ]
       [ chart1 model
       , chart2
       , chart3
       ]
-}


chart1 : Model -> Html.Html msg
chart1 model =
    --LineChart.view1 .x .y (getPoints model)
    LineChart.viewCustom chartConfig
        [ LineChart.line Colors.blueLight Dots.square "Chuck" (getPoints model)
        ]



-- DATA


type alias Point =
    { x : Float, y : Float }



--chartConfig : Config Info msg


chartConfig =
    { x = Axis.default 1200 "Time" .x
    , y = Axis.default 300 "CPU" .y
    , container = Container.responsive "line-chart-1"
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.none
    , events = Events.default
    , junk = Junk.default
    , grid = Grid.default
    , area = Area.default
    , line = Line.wider 3
    , dots = Dots.default
    }



{-


   myRowOfStuff : Model -> Element msg
   myRowOfStuff m =
       row [ width fill, centerY, spacing 30 ]
           [ myElement m
           , myElement m
           , el [ alignRight ] (myElement m)
           ]


   myElement : Model -> Element msg
   myElement model =
       el
           [ Background.color (rgb255 240 240 240)

           --, Font.color (rgb255 255 255 255)
           , Border.rounded 3
           , spacing 30
           , width fill
           ]
           (html
               (Plot.view model.data)
           )
-}
