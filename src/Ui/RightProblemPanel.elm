module Ui.RightProblemPanel exposing (Props, placeholder, view)

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
        , div [ A.class "p-4 grid gap-2 content-start math-scope" ]
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
                        [ span [ A.class "font-mono mr-2" ] [ text c.id ]
                        , span [] [ text c.textMd ]
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
