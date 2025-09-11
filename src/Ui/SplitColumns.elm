module Ui.SplitColumns exposing (view)

import Html exposing (Html, div)
import Html.Attributes as A

type alias Props msg =
    { left : Html msg
    , right : Html msg
    }

view : Props msg -> Html msg
view props =
    div [ A.class "h-full grid grid-cols-2" ]
        [ div [ A.class "h-full overflow-y-auto" ] [ props.left ]
        , div [ A.class "h-full overflow-y-auto border-l-2 border-base-300/60" ] [ props.right ]
        ]