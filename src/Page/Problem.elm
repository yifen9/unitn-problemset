module Page.Problem exposing
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
import Lib.Courses as C
import Lib.Problems as P
import Types exposing (ProblemDetail, ProblemSummary, ProblemType(..))
import Ui.LeftPanel as LP
import Ui.ProblemSolution as Solution
import Ui.ProblemStatement as Statement
import Ui.SplitColumns as SplitColumns


type alias Model =
    { courseId : String
    , courseTitle : String
    , pid : String
    , summaries : List ProblemSummary
    , detail : Maybe ProblemDetail
    , selected : List String
    , revealed : Bool
    }


type Msg
    = LoadedIndex P.LoadIndexResult
    | LoadedOne P.LoadOneResult
    | LoadedCourse C.LoadResult
    | ToggleChoice String
    | Submit
    | NoOp


init : String -> String -> Bool -> ( Model, Cmd Msg )
init cid pid reveal =
    ( { courseId = cid
      , courseTitle = cid
      , pid = pid
      , summaries = []
      , detail = Nothing
      , selected = []
      , revealed = reveal
      }
    , Cmd.batch
        [ P.loadIndex cid LoadedIndex
        , C.load LoadedCourse
        ]
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

        LoadedIndex (Ok ix) ->
            let
                path =
                    findPath model.pid ix.problems
            in
            ( { model | summaries = ix.problems }
            , P.loadOne model.courseId path LoadedOne
            )

        LoadedIndex (Err _) ->
            ( model, Cmd.none )

        LoadedOne (Ok d) ->
            ( { model | detail = Just d }, Cmd.none )

        LoadedOne (Err _) ->
            ( model, Cmd.none )

        ToggleChoice cid ->
            case model.detail of
                Nothing ->
                    ( model, Cmd.none )

                Just d ->
                    let
                        chosen =
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
            ( { model | revealed = True }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model.detail of
        Nothing ->
            div [ A.class "p-6" ] [ text "Loading..." ]

        Just d ->
            if model.revealed then
                SplitColumns.view
                    { left = Statement.view d
                    , right = Solution.view { detail = d, selected = model.selected }
                    }

            else
                Statement.view d


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


findPath : String -> List ProblemSummary -> String
findPath pid summaries =
    summaries
        |> List.filter (\s -> s.id == pid)
        |> List.head
        |> Maybe.map .path
        |> Maybe.withDefault (pid ++ ".json")
