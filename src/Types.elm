module Types exposing (Course, Problem, SortBy(..))


type alias Course =
    { id : String
    , name : String
    , size : Int
    , coverage : Int
    }


type SortBy
    = ByName
    | ById
    | BySize
    | ByCoverage


type alias Problem =
    { id : String
    , title : String
    }
