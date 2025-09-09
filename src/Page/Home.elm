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
    = Loaded (Result Http.Error C.CourseIndex)

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

cell : String -> Html msg
cell s =
    td [ A.class "px-4 py-3 text-2xl" ] [ text s ]

view : Model -> Html msg
view model =
    div []
        [ table [ A.class "table w-full border-2 border-base-300/60" ]
            [ thead [ A.class "bg-base-200" ]
                [ tr [ A.class "divide-x-2 divide-base-300/60" ]
                    [ th [ A.class "px-4 py-3 text-2xl font-bold" ] [ text "Name" ]
                    , th [ A.class "px-4 py-3 text-2xl font-bold" ] [ text "ID" ]
                    , th [ A.class "px-4 py-3 text-2xl font-bold" ] [ text "Size" ]
                    , th [ A.class "px-4 py-3 text-2xl font-bold" ] [ text "Coverage" ]
                    ]
                ]
            , tbody [ A.class "divide-y-2 divide-base-300/60" ]
                (List.map
                    (\c ->
                        tr [ A.class "divide-x-2 divide-base-300/60" ]
                            [ td [ A.class "px-4 py-3 text-2xl" ] [ a [ A.href ("/?subject=" ++ c.id), A.class "link" ] [ text c.name ] ]
                            , cell c.id
                            , cell (String.fromInt c.size)
                            , cell (String.fromInt c.coverage)
                            ]
                    )
                    model.courses
                )
            ]
        ]
