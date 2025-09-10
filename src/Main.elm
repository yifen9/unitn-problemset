module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html as H exposing (Html)
import Layouts.Shell as Shell
import List
import Page.Course as Course
import Page.Home as Home
import Page.Problem as Problem
import Route
import Types
import Ui.LeftPanel as Sidebar
import Ui.RightPanel as RP
import Url


type alias Model =
    { key : Nav.Key
    , route : Route.Route
    , home : Home.Model
    , course : Maybe Course.Model
    , problem : Maybe Problem.Model
    }


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | CourseMsg Course.Msg
    | ProblemMsg Problem.Msg


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
        Route.Problem cid pid ->
            let
                ( pm, pc ) =
                    Problem.init cid pid
            in
            ( { key = key, route = route, home = hm, course = Nothing, problem = Just pm }
            , Cmd.batch [ Cmd.map HomeMsg hc, Cmd.map ProblemMsg pc ]
            )

        Route.Course cid ->
            let
                ( cm, cc ) =
                    Course.init cid Nothing
            in
            ( { key = key, route = route, home = hm, course = Just cm, problem = Nothing }
            , Cmd.batch [ Cmd.map HomeMsg hc, Cmd.map CourseMsg cc ]
            )

        Route.Home ->
            ( { key = key, route = route, home = hm, course = Nothing, problem = Nothing }
            , Cmd.map HomeMsg hc
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
                Route.Problem cid pid ->
                    case model.problem of
                        Just _ ->
                            let
                                ( pm, pc ) =
                                    Problem.init cid pid
                            in
                            ( { model | route = route, course = Nothing, problem = Just pm }, Cmd.map ProblemMsg pc )

                        Nothing ->
                            let
                                ( pm, pc ) =
                                    Problem.init cid pid
                            in
                            ( { model | route = route, course = Nothing, problem = Just pm }, Cmd.map ProblemMsg pc )

                Route.Course cid ->
                    case model.course of
                        Just _ ->
                            let
                                ( cm, cc ) =
                                    Course.init cid Nothing
                            in
                            ( { model | route = route, course = Just cm, problem = Nothing }, Cmd.map CourseMsg cc )

                        Nothing ->
                            let
                                ( cm, cc ) =
                                    Course.init cid Nothing
                            in
                            ( { model | route = route, course = Just cm, problem = Nothing }, Cmd.map CourseMsg cc )

                Route.Home ->
                    ( { model | route = route, course = Nothing, problem = Nothing }, Cmd.none )

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

        ProblemMsg sub ->
            case model.problem of
                Just pm ->
                    let
                        ( pm2, pc2 ) =
                            Problem.update sub pm
                    in
                    ( { model | problem = Just pm2 }, Cmd.map ProblemMsg pc2 )

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
                    (Sidebar.view { startEnabled = False } |> H.map HomeMsg)
                    (H.map HomeMsg (Home.view model.home))
                    RP.placeholder
                ]
            }

        Route.Course _ ->
            viewCourse model

        Route.Problem _ _ ->
            viewProblem model


viewCourse : Model -> Browser.Document Msg
viewCourse model =
    case model.course of
        Just cm ->
            let
                rightPanel =
                    renderRightPanel cm
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
                            not (List.isEmpty cm.selected) && not cm.revealed

                        Nothing ->
                            False
            in
            RP.view
                { detail = d
                , selected = cm.selected
                , onToggle = Course.ToggleChoice
                , onPrev = Course.NoOp
                , onSubmit = Course.Submit
                , onNext = Course.NoOp
                , navEnabled = cm.practice
                , submitEnabled = submitEnabled
                }
                |> H.map CourseMsg

        Nothing ->
            RP.placeholder


viewProblem : Model -> Browser.Document Msg
viewProblem model =
    case model.problem of
        Just pm ->
            let
                submitEnabled =
                    case pm.detail of
                        Just _ ->
                            not (List.isEmpty pm.selected) && not pm.revealed

                        Nothing ->
                            False
            in
            { title = pm.pid ++ " · UniTN Problemset"
            , body =
                [ Shell.view
                    (H.map ProblemMsg (Problem.topCenter pm))
                    (H.map ProblemMsg Problem.leftPanel)
                    (H.map ProblemMsg (Problem.view pm))
                    (RP.view
                        { detail = Maybe.withDefault dummyDetail pm.detail
                        , selected = pm.selected
                        , onToggle = Problem.ToggleChoice
                        , onPrev = Problem.NoOp
                        , onSubmit = Problem.Submit
                        , onNext = Problem.NoOp
                        , navEnabled = False
                        , submitEnabled = submitEnabled
                        }
                        |> H.map ProblemMsg
                    )
                ]
            }

        Nothing ->
            { title = "UniTN Problemset"
            , body = [ H.text "" ]
            }


dummyDetail : Types.ProblemDetail
dummyDetail =
    { id = ""
    , title = ""
    , date = ""
    , ptype = Types.Single
    , questionMd = ""
    , choices = []
    , answer = []
    , explanationMd = ""
    }
