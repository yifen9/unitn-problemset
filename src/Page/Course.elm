module Page.Course exposing
    ( Model
    , Msg(..)
    , init
    , leftPanel
    , topCenter
    , update
    , view
    )

import Html exposing (Html, a, div, text)
import Html.Attributes as A
import Html.Events as E
import Lib.Courses as Courses
import Lib.ProblemOps as POps
import Lib.Problems as P
import Types exposing (Problem, ProblemSortBy(..), ProblemSummary)
import Ui.LeftPanel as Sidebar
import Ui.ProblemTable as PT


type alias Model =
    { id : String
    , title : String
    , problems : List Problem
    , summaries : List ProblemSummary
    , psort : ProblemSortBy
    , pasc : Bool
    }


type Msg
    = Loaded Courses.LoadResult
    | LoadedIndex P.LoadIndexResult
    | TogglePSort ProblemSortBy


init : String -> Maybe String -> ( Model, Cmd Msg )
init cid _ =
    ( { id = cid
      , title = cid
      , problems = []
      , summaries = []
      , psort = PByTitle
      , pasc = True
      }
    , Cmd.batch
        [ Courses.load Loaded
        , P.loadIndex cid LoadedIndex
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loaded (Ok idx) ->
            let
                found =
                    idx.courses
                        |> List.filter (\c -> c.id == model.id)
                        |> List.head
                        |> Maybe.map .title
                        |> Maybe.withDefault model.title
            in
            ( { model | title = found }, Cmd.none )

        Loaded (Err _) ->
            ( model, Cmd.none )

        LoadedIndex (Ok ix) ->
            let
                tbl =
                    List.map (\s -> { id = s.id, title = s.title, date = s.date, solved = False }) ix.problems
            in
            ( { model | summaries = ix.problems, problems = tbl }, Cmd.none )

        LoadedIndex (Err _) ->
            ( model, Cmd.none )

        TogglePSort key ->
            if model.psort == key then
                ( { model | pasc = not model.pasc }, Cmd.none )

            else
                ( { model | psort = key, pasc = True }, Cmd.none )


view : Model -> Html Msg
view model =
    PT.view
        { courseId = model.id
        , problems = POps.sortProblems model.psort model.pasc model.problems
        , sortBy = model.psort
        , asc = model.pasc
        , onSort = TogglePSort
        }


topCenter : Model -> Html Msg
topCenter model =
    a
        [ A.href ("/?course=" ++ model.id)
        , A.class "text-2xl font-extrabold uppercase tracking-wide link"
        , E.onClick (TogglePSort model.psort)
        ]
        [ text model.title ]


leftPanel : Html Msg
leftPanel =
    Sidebar.view { startEnabled = False }
