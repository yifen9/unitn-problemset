module Page.Home exposing (Model, Msg(..), init, update, view)

import Html exposing (Html, div)
import Html.Attributes as A
import Lib.CourseOps as Ops
import Lib.Courses as C
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
            }
        ]
