module Page.Home exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, a, div, input, table, tbody, td, th, thead, tr, text)
import Html.Attributes as A
import Html.Events as E
import Lib.Courses as C
import String
import Types exposing (Course)

type SortBy
    = ByName
    | ById
    | BySize
    | ByCoverage

type alias Model =
    { build : String
    , courses : List Course
    , query : String
    , sortBy : SortBy
    , asc : Bool
    }

type Msg
    = Loaded C.LoadResult
    | SetQuery String
    | Sort SortBy

init : ( Model, Cmd Msg )
init =
    ( { build = "", courses = [], query = "", sortBy = ByName, asc = True }
    , C.load Loaded
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loaded (Ok idx) ->
            ( { model | build = idx.build, courses = idx.courses }, Cmd.none )

        Loaded (Err _) ->
            ( model, Cmd.none )

        SetQuery q ->
            ( { model | query = q }, Cmd.none )

        Sort key ->
            if model.sortBy == key then
                ( { model | asc = not model.asc }, Cmd.none )
            else
                ( { model | sortBy = key, asc = True }, Cmd.none )

cellC : String -> Html msg
cellC s =
    td [ A.class "px-6 py-5 text-2xl text-center w-1/6 border-r-2 last:border-r-0 border-base-300/60" ] [ text s ]

headerCell : String -> SortBy -> Model -> Html Msg
headerCell label key model =
    th
        [ A.class "px-6 py-5 text-2xl font-bold uppercase text-center border-r-2 last:border-r-0 border-base-300/60 bg-base-200"
        , E.onClick (Sort key)
        ]
        [ text label ]

applyFilter : String -> List Course -> List Course
applyFilter q xs =
    let
        t = String.toLower q
        f c =
            String.contains t (String.toLower c.name)
                || String.contains t (String.toLower c.id)
    in
    if String.length t == 0 then
        xs
    else
        List.filter f xs

applySort : SortBy -> Bool -> List Course -> List Course
applySort key asc xs =
    let
        k c =
            case key of
                ByName ->
                    c.name

                ById ->
                    c.id

                BySize ->
                    String.fromInt c.size

                ByCoverage ->
                    String.fromInt c.coverage

        sorted = List.sortBy k xs
    in
    if asc then
        sorted
    else
        List.reverse sorted

view : Model -> Html Msg
view model =
    let
        filtered = applyFilter model.query model.courses
        sorted = applySort model.sortBy model.asc filtered
    in
    div [ A.class "h-full overflow-y-auto" ]
        [ div [ A.class "w-full border-b-2 border-base-300/60" ]
            [ input
                [ A.class "input input-bordered w-full rounded-none text-2xl px-6 py-4"
                , A.placeholder "Filter by name or id"
                , E.onInput SetQuery
                , A.value model.query
                ]
                []
            ]
        , table [ A.class "w-full table-fixed border-collapse m-0" ]
            [ thead [ A.class "sticky top-0 z-10" ]
                [ tr []
                    [ headerCell "NAME" ByName model
                    , headerCell "ID" ById model
                    , headerCell "SIZE" BySize model
                    , headerCell "COVERAGE" ByCoverage model
                    ]
                ]
            , tbody []
                (List.map
                    (\c ->
                        tr [ A.class "border-b-2 border-base-300/60" ]
                            [ td [ A.class "px-6 py-5 text-2xl w-1/2 border-r-2 border-base-300/60" ]
                                [ a [ A.href ("/?subject=" ++ c.id), A.class "link" ] [ text c.name ] ]
                            , cellC c.id
                            , cellC (String.fromInt c.size)
                            , cellC (String.fromInt c.coverage)
                            ]
                    )
                    sorted
                )
            ]
        ]
