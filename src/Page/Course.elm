module Page.Course exposing
    ( Model
    , Msg(..)
    , getCurrentDetail
    , init
    , leftPanel
    , topCenter
    , update
    , view
    )

import Dict exposing (Dict)
import Html exposing (Html, a, div, text)
import Html.Attributes as A
import Html.Events as E
import Lib.Courses as Courses
import Lib.Problems as P
import Types exposing (Problem, ProblemDetail, ProblemSortBy(..), ProblemSummary, ProblemType(..))
import Ui.CourseSidebar as Sidebar
import Ui.ProblemContent as PC
import Ui.ProblemTable as PT
import Ui.RightProblemPanel as RP


type ViewMode
    = TableView
    | ProblemView String


type alias Model =
    { id : String
    , title : String
    , problems : List Problem
    , summaries : List ProblemSummary
    , details : Dict String ProblemDetail
    , mode : ViewMode
    , psort : ProblemSortBy
    , pasc : Bool
    , selected : List String
    , practice : Bool
    }


type Msg
    = Loaded Courses.LoadResult
    | LoadedIndex P.LoadIndexResult
    | LoadedOne String P.LoadOneResult
    | TogglePSort ProblemSortBy
    | SetFragment (Maybe String)
    | ToggleChoice String
    | NoOp
    | GoList


init : String -> Maybe String -> ( Model, Cmd Msg )
init cid frag =
    let
        vm =
            case frag of
                Just f ->
                    case String.split "problem-" f of
                        [ "", pid ] ->
                            ProblemView pid

                        _ ->
                            TableView

                Nothing ->
                    TableView
    in
    ( { id = cid
      , title = cid
      , problems = []
      , summaries = []
      , details = Dict.empty
      , mode = vm
      , psort = PByTitle
      , pasc = True
      , selected = []
      , practice = False
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
                    List.filter (\c -> c.id == model.id) idx.courses
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
            case model.mode of
                ProblemView pid ->
                    ( { model | summaries = ix.problems, problems = tbl }, P.loadOne model.id (findPath pid ix.problems) (LoadedOne pid) )

                TableView ->
                    ( { model | summaries = ix.problems, problems = tbl }, Cmd.none )

        LoadedIndex (Err _) ->
            ( model, Cmd.none )

        LoadedOne pid (Ok d) ->
            ( { model | details = Dict.insert pid d model.details }, Cmd.none )

        LoadedOne _ (Err _) ->
            ( model, Cmd.none )

        TogglePSort key ->
            if model.psort == key then
                ( { model | pasc = not model.pasc }, Cmd.none )

            else
                ( { model | psort = key, pasc = True }, Cmd.none )

        SetFragment frag ->
            case frag of
                Just f ->
                    case String.split "problem-" f of
                        [ "", pid ] ->
                            let
                                cmd =
                                    if Dict.member pid model.details then
                                        Cmd.none

                                    else
                                        P.loadOne model.id (findPath pid model.summaries) (LoadedOne pid)
                            in
                            ( { model | mode = ProblemView pid, selected = [] }, cmd )

                        _ ->
                            ( { model | mode = TableView }, Cmd.none )

                Nothing ->
                    ( { model | mode = TableView }, Cmd.none )

        ToggleChoice cid ->
            let
                chosen =
                    case getCurrentDetail model of
                        Nothing ->
                            model.selected

                        Just d ->
                            case d.ptype of
                                Single ->
                                    if List.member cid model.selected then
                                        []

                                    else
                                        [ cid ]

                                Multi ->
                                    if List.member cid model.selected then
                                        List.filter ((/=) cid) model.selected

                                    else
                                        cid :: model.selected
            in
            ( { model | selected = chosen }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        GoList ->
            ( { model | mode = TableView }, Cmd.none )


view : Model -> Html Msg
view model =
    case model.mode of
        TableView ->
            PT.view
                { problems = sortProblems model.psort model.pasc model.problems
                , sortBy = model.psort
                , asc = model.pasc
                , onSort = TogglePSort
                }

        ProblemView pid ->
            case Dict.get pid model.details of
                Just d ->
                    PC.view d

                Nothing ->
                    div [ A.class "p-6" ] [ text "Loading..." ]


topCenter : Model -> Html Msg
topCenter model =
    a
        [ A.href ("/?course=" ++ model.id)
        , A.class "text-2xl font-extrabold uppercase tracking-wide link"
        , E.onClick GoList
        ]
        [ text model.title ]


leftPanel : Html Msg
leftPanel =
    Sidebar.view { startEnabled = True }


sortProblems : ProblemSortBy -> Bool -> List Problem -> List Problem
sortProblems key asc xs =
    let
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


findPath : String -> List ProblemSummary -> String
findPath pid summaries =
    summaries
        |> List.filter (\s -> s.id == pid)
        |> List.head
        |> Maybe.map .path
        |> Maybe.withDefault (pid ++ ".json")


getCurrentDetail : Model -> Maybe ProblemDetail
getCurrentDetail model =
    case model.mode of
        ProblemView pid ->
            Dict.get pid model.details

        TableView ->
            Nothing
