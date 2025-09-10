module Ui.RightPanel exposing (Props, placeholder, view)

import Html exposing (Html, div)
import Html.Attributes as A
import Types exposing (ProblemDetail)
import Ui.ChoiceList as ChoiceList
import Ui.PanelActions as Actions


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


view : Props msg -> Html msg
view props =
    div [ A.class "h-full grid grid-rows-[4rem_1fr]" ]
        [ Actions.view
            { left = { label = "PREV", kind = Actions.Default, onClick = Just props.onPrev, enabled = props.navEnabled }
            , middle = { label = "SUBMIT", kind = Actions.Primary, onClick = Just props.onSubmit, enabled = props.submitEnabled }
            , right = { label = "NEXT", kind = Actions.Default, onClick = Just props.onNext, enabled = props.navEnabled }
            }
        , ChoiceList.view
            { ptype = props.detail.ptype
            , choices = props.detail.choices
            , selected = props.selected
            , onToggle = props.onToggle
            }
        ]


placeholder : Html msg
placeholder =
    div [ A.class "h-full grid grid-rows-[4rem_1fr]" ]
        [ Actions.view
            { left = { label = "PREV", kind = Actions.Default, onClick = Nothing, enabled = False }
            , middle = { label = "SUBMIT", kind = Actions.Primary, onClick = Nothing, enabled = False }
            , right = { label = "NEXT", kind = Actions.Default, onClick = Nothing, enabled = False }
            }
        , div [] []
        ]
