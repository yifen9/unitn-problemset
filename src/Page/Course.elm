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
import Html exposing (Html, a, div, h2, p, text)
import Html.Attributes as A
import Html.Events as E
import Lib.Courses as Courses
import Lib.Problems as P
import Types exposing (Problem, ProblemDetail, ProblemSortBy(..), ProblemSummary, ProblemType(..))
import Ui.LeftPanel as Sidebar
import Ui.Math as Math
import Ui.ProblemContent as PC
import Ui.ProblemTable as PT
import Ui.RightPanel as RP


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
    , revealed : Bool
    , lastPid : Maybe String
    }


type Msg
    = Loaded Courses.LoadResult
    | LoadedIndex P.LoadIndexResult
    | LoadedOne String P.LoadOneResult
    | TogglePSort ProblemSortBy
    | SetFragment (Maybe String)
    | ToggleChoice String
    | Submit
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
      , revealed = False
      , lastPid = Nothing
      }
    , Cmd.batch
        [ Courses.load Loaded
        , P.loadIndex cid LoadedIndex
        ]
    )


eqSet : List String -> List String -> Bool
eqSet a b =
    List.sort a == List.sort b


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
                            ( { model | mode = ProblemView pid, selected = [], revealed = False, lastPid = Just pid }, cmd )

                        _ ->
                            ( { model | mode = TableView, revealed = False, lastPid = Nothing }, Cmd.none )

                Nothing ->
                    ( { model | mode = TableView, revealed = False, lastPid = Nothing }, Cmd.none )

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

        Submit ->
            case model.mode of
                ProblemView pid ->
                    case Dict.get pid model.details of
                        Just d ->
                            let
                                correct =
                                    eqSet model.selected d.answer

                                updateSolved p =
                                    if p.id == pid then
                                        { p | solved = correct }

                                    else
                                        p
                            in
                            ( { model
                                | problems = List.map updateSolved model.problems
                                , revealed = True
                                , lastPid = Just pid
                              }
                            , Cmd.none
                            )

                        Nothing ->
                            ( model, Cmd.none )

                TableView ->
                    ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        GoList ->
            ( { model | mode = TableView, revealed = False, lastPid = Nothing }, Cmd.none )


view : Model -> Html Msg
view model =
    case model.mode of
        TableView ->
            PT.view
                { courseId = model.id
                , problems = sortProblems model.psort model.pasc model.problems
                , sortBy = model.psort
                , asc = model.pasc
                , onSort = TogglePSort
                }

        ProblemView pid ->
            case Dict.get pid model.details of
                Just d ->
                    div []
                        [ PC.view d
                        , solutionBlock model pid d
                        ]

                Nothing ->
                    div [ A.class "p-6" ] [ text "Loading..." ]


solutionBlock : Model -> String -> ProblemDetail -> Html Msg
solutionBlock model pid detail =
    if model.revealed && model.lastPid == Just pid then
        let
            correct =
                eqSet model.selected detail.answer

            verdictClass =
                if correct then
                    "alert alert-success"

                else
                    "alert alert-error"

            yourAns =
                if List.isEmpty model.selected then
                    "—"

                else
                    String.join ", " model.selected

            rightAns =
                if List.isEmpty detail.answer then
                    "—"

                else
                    String.join ", " detail.answer

            hasExp =
                String.trim detail.explanationMd /= ""
        in
        div [ A.class "p-6 grid gap-4 content-start" ]
            [ div [ A.class verdictClass ]
                [ h2 [ A.class "font-bold text-xl" ]
                    [ text
                        (if correct then
                            "Correct"

                         else
                            "Incorrect"
                        )
                    ]
                , p [] [ text ("Your answer: " ++ yourAns) ]
                , p [] [ text ("Correct answer: " ++ rightAns) ]
                ]
            , if hasExp then
                div [ A.class "grid gap-2" ]
                    [ h2 [ A.class "text-xl font-semibold uppercase tracking-wide" ] [ text "Explanation" ]
                    , Math.block detail.explanationMd
                    ]

              else
                text ""
            ]

    else
        text ""


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
    Sidebar.view { startEnabled = False }


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
