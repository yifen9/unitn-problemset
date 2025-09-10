module Ui.ChoiceList exposing (Props, view)

import Html exposing (Html, button, div, span, text)
import Html.Attributes as A
import Html.Events as E
import Json.Decode as D
import Types exposing (Choice, ProblemType(..))
import Ui.Math as Math


type alias Props msg =
    { ptype : ProblemType
    , choices : List Choice
    , selected : List String
    , onToggle : String -> msg
    }


isSelected : String -> List String -> Bool
isSelected id sel =
    List.member id sel


onKeyActivate : msg -> Html.Attribute msg
onKeyActivate msg =
    E.on "keydown"
        (D.field "key" D.string
            |> D.andThen
                (\k ->
                    if k == " " || k == "Enter" then
                        D.succeed msg

                    else
                        D.fail "ignore"
                )
        )


view : Props msg -> Html msg
view props =
    let
        isMulti =
            case props.ptype of
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

        baseBtn =
            "btn btn-lg justify-start"
    in
    div
        [ A.class "p-2 grid gap-2 content-start"
        , A.attribute "role" groupRole
        , A.attribute "aria-label"
            (if isMulti then
                "Multiple choice"

             else
                "Single choice"
            )
        ]
        (List.indexedMap
            (\idx c ->
                let
                    active =
                        isSelected c.id props.selected

                    cls =
                        if active then
                            baseBtn ++ " btn-primary"

                        else
                            baseBtn ++ " btn-outline"

                    tab =
                        if active || (not isMulti && idx == 0) then
                            "0"

                        else
                            "-1"
                in
                button
                    [ A.class cls
                    , A.attribute "role" itemRole
                    , A.attribute "aria-checked"
                        (if active then
                            "true"

                         else
                            "false"
                        )
                    , A.attribute "tabindex" tab
                    , E.onClick (props.onToggle c.id)
                    , onKeyActivate (props.onToggle c.id)
                    ]
                    [ span [ A.class "text-2xl font-mono mr-3" ] [ text (indicator active) ]
                    , span [ A.class "text-2xl font-mono mr-3" ] [ text c.id ]
                    , span [ A.class "text-2xl" ] [ Math.inline c.textMd ]
                    ]
            )
            props.choices
        )
