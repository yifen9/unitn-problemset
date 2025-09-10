module Ui.AppPage exposing (view)

import Html exposing (Html)
import Layouts.Shell as Shell


type alias Regions msg =
    { top : Html msg
    , left : Html msg
    , center : Html msg
    , right : Html msg
    }


view : Regions msg -> Html msg
view r =
    Shell.view r.top r.left r.center r.right
