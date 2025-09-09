module Types exposing (Course, Problem, ProblemSortBy(..), SortBy(..))


type alias Course =
    { id : String
    , name : String
    , size : Int
    , coverage : Int
    }


type SortBy
    = CByTitle
    | CById
    | CBySize
    | CByCoverage


type alias Problem =
    { id : String
    , title : String
    , date : String
    , solved : Bool
    }


type ProblemSortBy
    = PByTitle
    | PById
    | PByDate
    | PBySolved
