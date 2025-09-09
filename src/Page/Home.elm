module Page.Home exposing (Model, Msg(..), init, update, view)

import Browser.Dom as Dom
import Html exposing (Html, div)
import Html.Attributes as A
import Lib.CourseOps as Ops
import Lib.Courses as C
import Task
import Ui.CourseTable as T
import Types exposing (Course, SortBy(..))

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
    | ToggleSort SortBy
    | RowKey Int String
    | FocusId String

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

        ToggleSort key ->
            if model.sortBy == key then
                ( { model | asc = not model.asc }, Cmd.none )
            else
                ( { model | sortBy = key, asc = True }, Cmd.none )

        RowKey i payload ->
            let
                parts = String.split "|" payload
                key = Maybe.withDefault "" (List.tail parts |> Maybe.andThen List.head)
                len = List.length model.courses
                next =
                    case key of
                        "ArrowDown" -> min (i + 1) (len - 1)
                        "ArrowUp" -> max (i - 1) 0
                        "Home" -> 0
                        "End" -> max (len - 1) 0
                        _ -> i
                nextId = "row-" ++ String.fromInt next
            in
            ( model, Task.attempt (\_ -> FocusId nextId) (Dom.focus nextId) )

        FocusId _ ->
            ( model, Cmd.none )

view : Model -> Html Msg
view model =
    let
        filtered = Ops.filter model.query model.courses
        sorted = Ops.sort model.sortBy model.asc filtered
    in
    div [ A.class "h-full" ]
        [ T.view
            { courses = sorted
            , sortBy = model.sortBy
            , asc = model.asc
            , onSort = ToggleSort
            , onRowKey = \i payload -> RowKey i payload
            }
        ]
