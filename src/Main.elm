module Main exposing (main)

import Browser
import Html exposing (Html)
import Layouts.Shell as Shell
import Page.Home as Home

type alias Model =
    { home : Home.Model }

type Msg
    = HomeMsg Home.Msg

main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> let ( m, c ) = Home.init in ( { home = m }, Cmd.map HomeMsg c )
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HomeMsg sub ->
            let
                ( m2, c2 ) =
                    Home.update sub model.home
            in
            ( { model | home = m2 }, Cmd.map HomeMsg c2 )

view : Model -> Html Msg
view model =
    Shell.view (Home.view model.home) (Html.text "")
