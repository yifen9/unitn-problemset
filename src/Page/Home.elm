module Page.Home exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, a, div, table, tbody, td, th, thead, tr, text)
import Html.Attributes as A
import Lib.Courses as C
import Types exposing (Course)

type alias Model =
    { build : String
    , courses : List Course
    }

type Msg
    = Loaded C.LoadResult

init : ( Model, Cmd Msg )
init =
    ( { build = "", courses = [] }
    , C.load Loaded
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loaded (Ok idx) ->
            ( { model | build = idx.build, courses = idx.courses }, Cmd.none )

        Loaded (Err _) ->
            ( model, Cmd.none )

cellC : String -> Html msg
cellC s =
    td [ A.class "px-6 py-5 text-2xl text-center w-1/6" ] [ text s ]

view : Model -> Html msg
view model =
    div [ A.class "m-0" ]
        [ table [ A.class "table table-fixed w-full border-collapse m-0" ]
            [ thead [ A.class "bg-base-200" ]
                [ tr [ A.class "divide-x-2 divide-base-300/60" ]
                    [ th [ A.class "px-6 py-5 text-2xl font-bold uppercase text-center w-1/2" ] [ text "NAME" ]
                    , th [ A.class "px-6 py-5 text-2xl font-bold uppercase text-center w-1/6" ] [ text "ID" ]
                    , th [ A.class "px-6 py-5 text-2xl font-bold uppercase text-center w-1/6" ] [ text "SIZE" ]
                    , th [ A.class "px-6 py-5 text-2xl font-bold uppercase text-center w-1/6" ] [ text "COVERAGE" ]
                    ]
                ]
            , tbody [ A.class "divide-y-2 divide-base-300/60" ]
                (List.map
                    (\c ->
                        tr [ A.class "divide-x-2 divide-base-300/60" ]
                            [ td [ A.class "px-6 py-5 text-2xl w-1/2" ]
                                [ a [ A.href ("/?subject=" ++ c.id), A.class "link" ] [ text c.name ] ]
                            , cellC c.id
                            , cellC (String.fromInt c.size)
                            , cellC (String.fromInt c.coverage)
                            ]
                    )
                    model.courses
                )
            ]
        ]
