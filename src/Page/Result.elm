module Page.Result exposing
    ( Model
    , Msg(..)
    , init
    , leftPanel
    , topCenter
    , update
    , view
    )

import Html exposing (Html, a, div, h1, p, text)
import Html.Attributes as A
import Lib.Courses as Courses
import Ui.LeftPanel as LP


type alias Model =
    { courseId : String
    , courseTitle : String
    }


type Msg
    = LoadedCourse Courses.LoadResult
    | NoOp


init : String -> ( Model, Cmd Msg )
init cid =
    ( { courseId = cid, courseTitle = cid }
    , Courses.load LoadedCourse
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadedCourse (Ok idx) ->
            let
                title =
                    idx.courses
                        |> List.filter (\c -> c.id == model.courseId)
                        |> List.head
                        |> Maybe.map .title
                        |> Maybe.withDefault model.courseTitle
            in
            ( { model | courseTitle = title }, Cmd.none )

        LoadedCourse (Err _) ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [ A.class "p-6 grid gap-4 content-start" ]
        [ h1 [ A.class "text-3xl font-extrabold uppercase tracking-wide" ] [ text "Result" ]
        , p [] [ text ("Course: " ++ model.courseTitle) ]
        , p [] [ text "Coming soon: summary, per-problem status, and links." ]
        ]


topCenter : Model -> Html Msg
topCenter model =
    a
        [ A.href ("/?course=" ++ model.courseId)
        , A.class "text-2xl font-extrabold uppercase tracking-wide link"
        ]
        [ text model.courseTitle ]


leftPanel : Html Msg
leftPanel =
    LP.view { startEnabled = False }
