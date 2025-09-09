module Ui.RightProblemPanel exposing (Props, placeholder, view)

import Html exposing (Html, button, div, span, text)
import Html.Attributes as A
import Html.Events as E
import Types exposing (ProblemDetail, ProblemType(..))
import Ui.Math as Math


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
    div [ A.class "h-full grid grid-rows-[4rem_1fr]" ]
        [ div [ A.class "h-16 grid grid-cols-3 gap-2 p-2 items-center justify-items-center border-b-2 border-base-300/60" ]
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
        , div [ A.class "p-2 grid gap-2 content-start" ]
            (List.map
                (\c ->
                    let
                        active =
                            isSelected c.id props.selected

                        base =
                            "btn btn-lg justify-start"

                        cls =
                            if active then
                                base ++ " btn-primary"

                            else
                                base ++ " btn-outline"
                    in
                    button
                        [ A.class cls
                        , E.onClick (props.onToggle c.id)
                        ]
                        [ span [ A.class "text-2xl font-mono mr-2" ] [ text c.id ]
                        , Html.span [ A.class "text-2xl" ] [ Math.inline c.textMd ]
                        ]
                )
                props.detail.choices
            )
        ]


placeholder : Html msg
placeholder =
    div [ A.class "h-full grid grid-rows-[4rem_1fr]" ]
        [ div [ A.class "h-16 grid grid-cols-3 gap-2 p-2 items-center justify-items-center border-b-2 border-base-300/60" ]
            [ button [ A.class "btn w-full btn-disabled", A.disabled True ] [ text "PREV" ]
            , button [ A.class "btn btn-primary w-full btn-disabled", A.disabled True ] [ text "SUBMIT" ]
            , button [ A.class "btn w-full btn-disabled", A.disabled True ] [ text "NEXT" ]
            ]
        , div [] []
        ]
