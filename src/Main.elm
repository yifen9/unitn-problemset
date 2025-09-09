module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html as H exposing (Html)
import Layouts.Shell as Shell
import List
import Page.Course as Course
import Page.Home as Home
import Route
import Ui.CourseSidebar as Sidebar
import Ui.RightProblemPanel as RP
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

        ( hm, hc ) =
            Home.init
    in
    case route of
        Route.Course cid frag ->
            let
                ( cm, cc ) =
                    Course.init cid frag
            in
            ( { key = key, route = route, home = hm, course = Just cm }
            , Cmd.batch [ Cmd.map HomeMsg hc, Cmd.map CourseMsg cc ]
            )

        Route.Home ->
            ( { key = key, route = route, home = hm, course = Nothing }
            , Cmd.map HomeMsg hc
            )

viewHome : Model -> Browser.Document Msg
viewHome model =
    { title = "UniTN Problemset"
    , body =
        [ Shell.view
            (H.text "")
            (Sidebar.view { startEnabled = False } |> H.map HomeMsg)
            (H.map HomeMsg (Home.view model.home))
            RP.placeholder
        ]
    }


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
                Route.Course cid frag ->
                    case model.course of
                        Just cm ->
                            let
                                ( cm2, cc2 ) =
                                    Course.update (Course.SetFragment frag) cm
                            in
                            ( { model | route = route, course = Just cm2 }, Cmd.map CourseMsg cc2 )

                        Nothing ->
                            let
                                ( cm, cc ) =
                                    Course.init cid frag
                            in
                            ( { model | route = route, course = Just cm }, Cmd.map CourseMsg cc )

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
            viewHome model

        Route.Course _ _ ->
            viewCourse model


viewCourse : Model -> Browser.Document Msg
viewCourse model =
    case model.course of
        Just cm ->
            let
                rightPanel = renderRightPanel cm
            in
            { title = cm.title ++ " · UniTN Problemset"
            , body =
                [ Shell.view
                    (H.map CourseMsg (Course.topCenter cm))
                    (H.map CourseMsg Course.leftPanel)
                    (H.map CourseMsg (Course.view cm))
                    rightPanel
                ]
            }

        Nothing ->
            { title = "UniTN Problemset"
            , body = [ H.text "" ]
            }


renderRightPanel : Course.Model -> Html Msg
renderRightPanel cm =
    case Course.getCurrentDetail cm of
        Just d ->
            let
                submitEnabled =
                    case Course.getCurrentDetail cm of
                        Just _ ->
                            not (List.isEmpty cm.selected)

                        Nothing ->
                            False
            in
            RP.view
                { detail = d
                , selected = cm.selected
                , onToggle = Course.ToggleChoice
                , onPrev = Course.NoOp
                , onSubmit = Course.NoOp
                , onNext = Course.NoOp
                , navEnabled = cm.practice
                , submitEnabled = submitEnabled
                }
                |> H.map CourseMsg

        Nothing ->
            RP.placeholder