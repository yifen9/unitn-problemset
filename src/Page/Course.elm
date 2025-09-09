module Page.Course exposing (Model, Msg(..), init, leftPanel, topCenter, update, view)

import Html exposing (Html, div, text)
import Html.Attributes as A
import Lib.Courses as Courses
import Types exposing (Problem)
import Ui.CourseSidebar as Sidebar
import Ui.ProblemTable as PT


type alias Model =
    { id : String
    , title : String
    , problems : List Problem
    }


type Msg
    = Loaded Courses.LoadResult


init : String -> ( Model, Cmd Msg )
init cid =
    ( { id = cid, title = cid, problems = demo }, Courses.load Loaded )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loaded (Ok idx) ->
            let
                found =
                    List.filter (\c -> c.id == model.id) idx.courses
                        |> List.head
                        |> Maybe.map .name
                        |> Maybe.withDefault model.title
            in
            ( { model | title = found }, Cmd.none )

        Loaded (Err _) ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    PT.view { problems = model.problems }


topCenter : Model -> Html Msg
topCenter model =
    div [ A.class "text-2xl font-extrabold uppercase tracking-wide" ] [ text model.title ]


leftPanel : Html Msg
leftPanel =
    Sidebar.view { startEnabled = True }


demo : List Problem
demo =
    [ { id = "P1", title = "Sample Problem 1" }
    , { id = "P2", title = "Sample Problem 2" }
    , { id = "P3", title = "Sample Problem 3" }
    ]
