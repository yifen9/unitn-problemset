module Ui.RightPanel exposing (Props, placeholder, view)

import Html exposing (Html, button, div, span, text)
import Html.Attributes as A
import Html.Events as E
import Types exposing (ProblemDetail, ProblemType(..))
import Ui.Math as Math
import Ui.Subheader as Sub


type alias Props msg =
    { detail : ProblemDetail
    , selected : List String
    , onToggle : String -> msg
    , onPrev : msg
    , onSubmit : msg
    , onNext : msg
    , navEnabled : Bool
    , submitEnabled : Bool
    , disabled : Bool
    }


isSelected : String -> List String -> Bool
isSelected id sel =
    List.member id sel


view : Props msg -> Html msg
view props =
    let
        isMulti =
            case props.detail.ptype of
                Multi ->
                    True

                Single ->
                    False

        groupRole =
            if isMulti then
                "group"

            else
                "radiogroup"

        itemRole =
            if isMulti then
                "checkbox"

            else
                "radio"

        indicator active =
            if isMulti then
                if active then
                    "☑"

                else
                    "☐"

            else if active then
                "●"

            else
                "○"

        itemAttrs active cid =
            let
                base =
                    "btn btn-lg justify-start"

                cls =
                    if active then
                        base ++ " btn-primary"

                    else
                        base ++ " btn-outline"

                disabledAttrs =
                    if props.disabled then
                        [ A.class "btn-disabled", A.disabled True ]

                    else
                        []

                clickAttrs =
                    if props.disabled then
                        []

                    else
                        [ E.onClick (props.onToggle cid) ]
            in
            [ A.class cls
            , A.attribute "role" itemRole
            , A.attribute "aria-checked"
                (if active then
                    "true"

                 else
                    "false"
                )
            ]
                ++ disabledAttrs
                ++ clickAttrs
    in
    div [ A.class "h-full grid grid-rows-[4rem_4rem_1fr]" ]
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
                    ++ (if props.submitEnabled then
                            [ E.onClick props.onSubmit ]

                        else
                            []
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
        , Sub.view "CHOICE"
        , div
            [ A.class "p-2 grid gap-2 content-start"
            , A.attribute "role" groupRole
            , A.attribute "aria-label"
                (if isMulti then
                    "Multiple choice"

                 else
                    "Single choice"
                )
            ]
            (List.map
                (\c ->
                    let
                        active =
                            isSelected c.id props.selected
                    in
                    button
                        (itemAttrs active c.id)
                        [ span [ A.class "text-2xl font-mono mr-3" ] [ text (indicator active) ]
                        , span [ A.class "text-2xl font-mono mr-3" ] [ text c.id ]
                        , span [ A.class "text-2xl" ] [ Math.inline c.textMd ]
                        ]
                )
                props.detail.choices
            )
        ]


placeholder : Html msg
placeholder =
    div [ A.class "h-full grid grid-rows-[4rem_4rem_1fr]" ]
        [ div [ A.class "h-16 grid grid-cols-3 gap-2 p-2 items-center justify-items-center border-b-2 border-base-300/60" ]
            [ button [ A.class "btn w-full btn-disabled", A.disabled True ] [ text "PREV" ]
            , button [ A.class "btn btn-primary w-full btn-disabled", A.disabled True ] [ text "SUBMIT" ]
            , button [ A.class "btn w-full btn-disabled", A.disabled True ] [ text "NEXT" ]
            ]
        , Sub.view "CHOICE"
        , div [ A.class "p-2 overflow-y-auto" ] []
        ]