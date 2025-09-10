module Ui.LeftPanel exposing (Props, view, viewActions, viewSettings)

import Html exposing (Html, div, text)
import Html.Attributes as A
import Ui.PanelActions as Actions


type alias Props =
    { startEnabled : Bool
    }


view : Props -> Html msg
view props =
    div [ A.class "grid grid-rows-[4rem_1fr] h-full" ]
        [ viewActions props
        , viewSettings
        ]


viewActions : Props -> Html msg
viewActions props =
    Actions.view
        { left = { label = "IMPORT", kind = Actions.Primary, onClick = Nothing, enabled = True }
        , middle =
            { label = "START"
            , kind = Actions.Secondary
            , onClick = Nothing
            , enabled = props.startEnabled
            }
        , right = { label = "EXPORT", kind = Actions.Default, onClick = Nothing, enabled = False }
        }


viewSettings : Html msg
viewSettings =
    div [ A.class "p-4 grid gap-4 content-start" ] []
