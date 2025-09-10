module Ui.PanelActions exposing (Action, Kind(..), Props, view)

import Html exposing (Html, button, div, text)
import Html.Attributes as A
import Html.Events as E


type Kind
    = Primary
    | Secondary
    | Default


type alias Action msg =
    { label : String
    , kind : Kind
    , onClick : Maybe msg
    , enabled : Bool
    }


type alias Props msg =
    { left : Action msg
    , middle : Action msg
    , right : Action msg
    }


view : Props msg -> Html msg
view props =
    let
        btnAttrs : Action msg -> List (Html.Attribute msg)
        btnAttrs a =
            let
                base =
                    [ A.class "btn w-full" ]

                tone =
                    case a.kind of
                        Primary ->
                            [ A.class "btn-primary" ]

                        Secondary ->
                            [ A.class "btn-secondary" ]

                        Default ->
                            []

                gate =
                    if a.enabled then
                        case a.onClick of
                            Just msg ->
                                [ E.onClick msg ]

                            Nothing ->
                                []

                    else
                        [ A.class "btn-disabled", A.disabled True ]
            in
            base ++ tone ++ gate

        one a =
            button (btnAttrs a) [ text a.label ]
    in
    div
        [ A.class "h-16 grid grid-cols-3 gap-2 p-2 items-center justify-items-center border-b-2 border-base-300/60" ]
        [ one props.left, one props.middle, one props.right ]
