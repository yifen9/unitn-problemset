module Ui.RightPaneWiring exposing (propsForCourse, propsForProblem)

import Page.Course as Course
import Page.Problem as Problem
import Ui.RightPanel as RP


propsForCourse : Course.Model -> Maybe (RP.Props Course.Msg)
propsForCourse _ =
    Nothing


propsForProblem : Problem.Model -> Maybe (RP.Props Problem.Msg)
propsForProblem pm =
    case pm.detail of
        Just d ->
            let
                submitEnabled =
                    not (List.isEmpty pm.selected) && not pm.revealed
            in
            Just
                { detail = d
                , selected = pm.selected
                , onToggle = Problem.ToggleChoice
                , onPrev = Problem.NoOp
                , onSubmit = Problem.Submit
                , onNext = Problem.NoOp
                , navEnabled = False
                , submitEnabled = submitEnabled
                }

        Nothing ->
            Nothing
