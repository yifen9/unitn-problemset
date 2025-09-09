module Main exposing (main)

import Browser
import Html exposing (Html)
import Layouts.Shell as Shell
import Page.Home as Home
import Types exposing (User)

type alias Model =
    { user : Maybe User }

type Msg
    = NoOp

main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }

init : Model
init =
    { user = Nothing }

update : Msg -> Model -> Model
update _ model =
    model

view : Model -> Html Msg
view model =
    Shell.view model.user Home.view
