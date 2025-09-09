module Types exposing (Course, SortBy(..))

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
