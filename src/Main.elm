module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html as H exposing (Html)
import Page.Course as Course
import Page.Home as Home
import Page.Problem as Problem
import Page.Result as Result
import Route
import Types
import Ui.AppPage as AppPage
import Ui.LeftPanel as Sidebar
import Ui.RightPaneWiring as Wire
import Ui.RightPanel as RP
import Url


type alias Model =
    { key : Nav.Key
    , route : Route.Route
    , home : Home.Model
    , course : Maybe Course.Model
    , problem : Maybe Problem.Model
    , result : Maybe Result.Model
    }


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url
    | HomeMsg Home.Msg
    | CourseMsg Course.Msg
    | ProblemMsg Problem.Msg
    | ResultMsg Result.Msg


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
                    Problem.init cid pid False
            in
            ( { key = key, route = route, home = hm, course = Nothing, problem = Just pm, result = Nothing }
            , Cmd.batch [ Cmd.map HomeMsg hc, Cmd.map ProblemMsg pc ]
            )

        Route.ProblemResult cid pid ->
            let
                ( pm, pc ) =
                    Problem.init cid pid True
            in
            ( { key = key, route = route, home = hm, course = Nothing, problem = Just pm, result = Nothing }
            , Cmd.batch [ Cmd.map HomeMsg hc, Cmd.map ProblemMsg pc ]
            )

        Route.Course cid ->
            let
                ( cm, cc ) =
                    Course.init cid Nothing
            in
            ( { key = key, route = route, home = hm, course = Just cm, problem = Nothing, result = Nothing }
            , Cmd.batch [ Cmd.map HomeMsg hc, Cmd.map CourseMsg cc ]
            )

        Route.Result cid ->
            let
                ( rm, rc ) =
                    Result.init cid
            in
            ( { key = key, route = route, home = hm, course = Nothing, problem = Nothing, result = Just rm }
            , Cmd.batch [ Cmd.map HomeMsg hc, Cmd.map ResultMsg rc ]
            )

        Route.Home ->
            ( { key = key, route = route, home = hm, course = Nothing, problem = Nothing, result = Nothing }
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
                        Just pm ->
                            if pm.courseId == cid && pm.pid == pid then
                                ( { model | route = route, result = Nothing, problem = Just { pm | revealed = False } }
                                , Cmd.none
                                )

                            else
                                let
                                    ( pm2, pc2 ) =
                                        Problem.init cid pid False
                                in
                                ( { model | route = route, course = Nothing, result = Nothing, problem = Just pm2 }, Cmd.map ProblemMsg pc2 )

                        Nothing ->
                            let
                                ( pm, pc ) =
                                    Problem.init cid pid False
                            in
                            ( { model | route = route, course = Nothing, result = Nothing, problem = Just pm }, Cmd.map ProblemMsg pc )

                Route.ProblemResult cid pid ->
                    case model.problem of
                        Just pm ->
                            if pm.courseId == cid && pm.pid == pid then
                                ( { model | route = route, result = Nothing, problem = Just { pm | revealed = True } }
                                , Cmd.none
                                )

                            else
                                let
                                    ( pm2, pc2 ) =
                                        Problem.init cid pid True
                                in
                                ( { model | route = route, course = Nothing, result = Nothing, problem = Just pm2 }, Cmd.map ProblemMsg pc2 )

                        Nothing ->
                            let
                                ( pm, pc ) =
                                    Problem.init cid pid True
                            in
                            ( { model | route = route, course = Nothing, result = Nothing, problem = Just pm }, Cmd.map ProblemMsg pc )

                Route.Course cid ->
                    let
                        ( cm, cc ) =
                            Course.init cid Nothing
                    in
                    ( { model | route = route, course = Just cm, problem = Nothing, result = Nothing }, Cmd.map CourseMsg cc )

                Route.Result cid ->
                    let
                        ( rm, rc ) =
                            Result.init cid
                    in
                    ( { model | route = route, course = Nothing, problem = Nothing, result = Just rm }, Cmd.map ResultMsg rc )

                Route.Home ->
                    ( { model | route = route, course = Nothing, problem = Nothing, result = Nothing }, Cmd.none )

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

        ProblemMsg Problem.Submit ->
            case model.problem of
                Just pm ->
                    ( model
                    , Nav.pushUrl model.key ("/?course=" ++ pm.courseId ++ "&problem=" ++ pm.pid ++ "&solution=1")
                    )

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

        ResultMsg sub ->
            case model.result of
                Just rm ->
                    let
                        ( rm2, rc2 ) =
                            Result.update sub rm
                    in
                    ( { model | result = Just rm2 }, Cmd.map ResultMsg rc2 )

                Nothing ->
                    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    case model.route of
        Route.Home ->
            { title = "UniTN Problemset"
            , body =
                [ AppPage.view
                    { top = H.text ""
                    , left = Sidebar.view { startEnabled = False } |> H.map HomeMsg
                    , center = H.map HomeMsg (Home.view model.home)
                    , right = RP.placeholder
                    }
                ]
            }

        Route.Course _ ->
            case model.course of
                Just cm ->
                    { title = cm.title ++ " · UniTN Problemset"
                    , body =
                        [ AppPage.view
                            { top = H.map CourseMsg (Course.topCenter cm)
                            , left = H.map CourseMsg Course.leftPanel
                            , center = H.map CourseMsg (Course.view cm)
                            , right = RP.placeholder
                            }
                        ]
                    }

                Nothing ->
                    { title = "UniTN Problemset", body = [ H.text "" ] }

        Route.Problem _ _ ->
            case model.problem of
                Just pm ->
                    let
                        rightPane =
                            case Wire.propsForProblem pm of
                                Just props ->
                                    RP.view props |> H.map ProblemMsg

                                Nothing ->
                                    RP.placeholder
                    in
                    { title = pm.pid ++ " · UniTN Problemset"
                    , body =
                        [ AppPage.view
                            { top = H.map ProblemMsg (Problem.topCenter pm)
                            , left = H.map ProblemMsg Problem.leftPanel
                            , center = H.map ProblemMsg (Problem.view pm)
                            , right = rightPane
                            }
                        ]
                    }

                Nothing ->
                    { title = "UniTN Problemset", body = [ H.text "" ] }

        Route.ProblemResult _ _ ->
            case model.problem of
                Just pm ->
                    let
                        rightPane =
                            case Wire.propsForProblem pm of
                                Just props ->
                                    RP.view props |> H.map ProblemMsg

                                Nothing ->
                                    RP.placeholder
                    in
                    { title = pm.pid ++ " · UniTN Problemset"
                    , body =
                        [ AppPage.view
                            { top = H.map ProblemMsg (Problem.topCenter pm)
                            , left = H.map ProblemMsg Problem.leftPanel
                            , center = H.map ProblemMsg (Problem.view pm)
                            , right = rightPane
                            }
                        ]
                    }

                Nothing ->
                    { title = "UniTN Problemset", body = [ H.text "" ] }

        Route.Result _ ->
            case model.result of
                Just rm ->
                    { title = "Result · UniTN Problemset"
                    , body =
                        [ AppPage.view
                            { top = H.map ResultMsg (Result.topCenter rm)
                            , left = H.map ResultMsg Result.leftPanel
                            , center = H.map ResultMsg (Result.view rm)
                            , right = RP.placeholder
                            }
                        ]
                    }

                Nothing ->
                    { title = "UniTN Problemset", body = [ H.text "" ] }
