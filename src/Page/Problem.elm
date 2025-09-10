module Page.Problem exposing
    ( Model
    , Msg(..)
    , init
    , leftPanel
    , topCenter
    , update
    , view
    )

import Dict
import Html exposing (Html, a, div, h2, p, text)
import Html.Attributes as A
import Html.Events as E
import Lib.Problems as P
import Types exposing (ProblemDetail, ProblemSummary, ProblemType(..))
import Ui.LeftPanel as Sidebar
import Ui.Math as Math
import Ui.ProblemContent as PC
import Ui.RightPanel as RP


type alias Model =
    { courseId : String
    , pid : String
    , summaries : List ProblemSummary
    , detail : Maybe ProblemDetail
    , selected : List String
    , revealed : Bool
    }


type Msg
    = LoadedIndex P.LoadIndexResult
    | LoadedOne P.LoadOneResult
    | ToggleChoice String
    | Submit
    | NoOp


init : String -> String -> ( Model, Cmd Msg )
init cid pid =
    ( { courseId = cid
      , pid = pid
      , summaries = []
      , detail = Nothing
      , selected = []
      , revealed = False
      }
    , P.loadIndex cid LoadedIndex
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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
            div []
                [ PC.view d
                , solutionBlock model d
                ]


topCenter : Model -> Html Msg
topCenter model =
    a
        [ A.href ("/?course=" ++ model.courseId)
        , A.class "text-2xl font-extrabold uppercase tracking-wide link"
        ]
        [ text (model.courseId ++ " · " ++ model.pid) ]


leftPanel : Html Msg
leftPanel =
    Sidebar.view { startEnabled = False }


findPath : String -> List ProblemSummary -> String
findPath pid summaries =
    summaries
        |> List.filter (\s -> s.id == pid)
        |> List.head
        |> Maybe.map .path
        |> Maybe.withDefault (pid ++ ".json")


eqSet : List String -> List String -> Bool
eqSet a b =
    List.sort a == List.sort b


solutionBlock : Model -> ProblemDetail -> Html Msg
solutionBlock model detail =
    if model.revealed then
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
