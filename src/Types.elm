module Types exposing (Course)


type alias Course =
    { id : String
    , name : String
    , size : Int
    , coverage : Int
    }
