module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html as H
import Html exposing (Html)
import Layouts.Shell as Shell
import Page.Course as Course
import Page.Home as Home
import Route
import Url


type alias Model =
    { key : Nav.Key
    , route : Route.Route
    , home : Home.Model
    , course : Maybe Course.Model
    }


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | CourseMsg Course.Msg


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        route =
            Route.fromUrl url

        ( homeModel, homeCmd ) =
            Home.init
    in
    case route of
        Route.Course cid ->
            let
                ( courseModel, courseCmd ) =
                    Course.init cid
            in
            ( { key = key
              , route = route
              , home = homeModel
              , course = Just courseModel
              }
            , Cmd.batch [ Cmd.map HomeMsg homeCmd, Cmd.map CourseMsg courseCmd ]
            )

        Route.Home ->
            ( { key = key
              , route = route
              , home = homeModel
              , course = Nothing
              }
            , Cmd.map HomeMsg homeCmd
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested req ->
            case req of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                route =
                    Route.fromUrl url
            in
            case route of
                Route.Course cid ->
                    let
                        ( cm, cc ) =
                            Course.init cid
                    in
                    ( { model | route = route, course = Just cm }
                    , Cmd.map CourseMsg cc
                    )

                Route.Home ->
                    ( { model | route = route, course = Nothing }, Cmd.none )

        HomeMsg sub ->
            let
                ( hm, hc ) =
                    Home.update sub model.home
            in
            ( { model | home = hm }, Cmd.map HomeMsg hc )

        CourseMsg sub ->
            case model.course of
                Just cm ->
                    let
                        ( cm2, cc2 ) =
                            Course.update sub cm
                    in
                    ( { model | course = Just cm2 }, Cmd.map CourseMsg cc2 )

                Nothing ->
                    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    case model.route of
        Route.Home ->
            { title = "UniTN Problemset"
            , body =
                [ Shell.view
                    (H.text "")
                    (H.text "")
                    (H.map HomeMsg (Home.view model.home))
                    (H.text "")
                ]
            }

        Route.Course _ ->
            case model.course of
                Just cm ->
                    { title = cm.title ++ " · UniTN Problemset"
                    , body =
                        [ Shell.view
                            (H.map CourseMsg (Course.topCenter cm))
                            (H.map CourseMsg Course.leftPanel)
                            (H.map CourseMsg (Course.view cm))
                            (H.text "")
                        ]
                    }

                Nothing ->
                    { title = "UniTN Problemset", body = [ H.text "" ] }
