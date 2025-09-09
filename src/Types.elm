module Types exposing (Course, Problem, ProblemSortBy(..), SortBy(..))


type alias Course =
    { id : String
    , title : String
    , date : String
    , count : Int
    }


type SortBy
    = CByTitle
    | CById
    | CByDate
    | CByCount


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
