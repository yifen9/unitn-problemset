module Page.Course exposing (Model, Msg(..), init, leftPanel, topCenter, update, view)

import Html exposing (Html, div, text)
import Html.Attributes as A
import Lib.Courses as Courses
import Types exposing (Problem, ProblemSortBy(..))
import Ui.CourseSidebar as Sidebar
import Ui.ProblemTable as PT


type alias Model =
    { id : String
    , title : String
    , problems : List Problem
    , psort : ProblemSortBy
    , pasc : Bool
    }


type Msg
    = Loaded Courses.LoadResult
    | TogglePSort ProblemSortBy


init : String -> ( Model, Cmd Msg )
init cid =
    ( { id = cid
      , title = cid
      , problems = demo
      , psort = PByTitle
      , pasc = True
      }
    , Courses.load Loaded
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loaded (Ok idx) ->
            let
                found =
                    List.filter (\c -> c.id == model.id) idx.courses
                        |> List.head
                        |> Maybe.map .title
                        |> Maybe.withDefault model.title
            in
            ( { model | title = found }, Cmd.none )

        Loaded (Err _) ->
            ( model, Cmd.none )

        TogglePSort key ->
            if model.psort == key then
                ( { model | pasc = not model.pasc }, Cmd.none )

            else
                ( { model | psort = key, pasc = True }, Cmd.none )


view : Model -> Html Msg
view model =
    PT.view
        { problems = sortProblems model.psort model.pasc model.problems
        , sortBy = model.psort
        , asc = model.pasc
        , onSort = TogglePSort
        }


topCenter : Model -> Html Msg
topCenter model =
    div [ A.class "text-2xl font-extrabold uppercase tracking-wide" ] [ text model.title ]


leftPanel : Html Msg
leftPanel =
    Sidebar.view { startEnabled = True }


sortProblems : ProblemSortBy -> Bool -> List Problem -> List Problem
sortProblems key asc xs =
    let
        cmp : Problem -> Problem -> Order
        cmp a b =
            case key of
                PByTitle ->
                    compare a.title b.title

                PById ->
                    compare a.id b.id

                PByDate ->
                    compare a.date b.date

                PBySolved ->
                    let
                        ai =
                            if a.solved then
                                1

                            else
                                0

                        bi =
                            if b.solved then
                                1

                            else
                                0
                    in
                    case compare ai bi of
                        EQ ->
                            compare a.title b.title

                        ord ->
                            ord

        s =
            List.sortWith cmp xs
    in
    if asc then
        s

    else
        List.reverse s


demo : List Problem
demo =
    [ { id = "P1", title = "Sample Problem 1", date = "2025-01-03", solved = True }
    , { id = "P2", title = "Sample Problem 2", date = "2025-01-07", solved = False }
    , { id = "P3", title = "Sample Problem 3", date = "2025-01-02", solved = True }
    ]
