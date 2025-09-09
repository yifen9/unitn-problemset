module Ui.RightProblemPanel exposing (Props, view)

import Html exposing (Html, button, div, span, text)
import Html.Attributes as A
import Html.Events as E
import Types exposing (ProblemDetail, ProblemType(..))


type alias Props msg =
    { detail : ProblemDetail
    , selected : List String
    , onToggle : String -> msg
    , onPrev : msg
    , onSubmit : msg
    , onNext : msg
    , navEnabled : Bool
    , submitEnabled : Bool
    }


isSelected : String -> List String -> Bool
isSelected id sel =
    List.member id sel


view : Props msg -> Html msg
view props =
    div [ A.class "grid grid-rows-[4rem_1fr] h-full" ]
        [ div [ A.class "grid grid-cols-3 gap-2 p-2 h-16 items-center justify-items-center" ]
            [ button
                ([ A.class "btn w-full" ]
                    ++ (if props.navEnabled then
                            []

                        else
                            [ A.class "btn-disabled", A.disabled True ]
                       )
                )
                [ text "PREV" ]
            , button
                ([ A.class "btn btn-primary w-full" ]
                    ++ (if props.submitEnabled then
                            []

                        else
                            [ A.class "btn-disabled", A.disabled True ]
                       )
                )
                [ text "SUBMIT" ]
            , button
                ([ A.class "btn w-full" ]
                    ++ (if props.navEnabled then
                            []

                        else
                            [ A.class "btn-disabled", A.disabled True ]
                       )
                )
                [ text "NEXT" ]
            ]
        , div [ A.class "p-3 grid gap-2 content-start" ]
            (List.map
                (\c ->
                    let
                        active =
                            isSelected c.id props.selected

                        base =
                            "btn w-full justify-start"

                        cls =
                            if active then
                                base ++ " btn-secondary"

                            else
                                base
                    in
                    button
                        [ A.class cls
                        , E.onClick (props.onToggle c.id)
                        ]
                        [ span [ A.class "font-mono mr-3" ] [ text c.id ]
                        , span [] [ text c.textMd ]
                        ]
                )
                props.detail.choices
            )
        ]
