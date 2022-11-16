module Basic exposing (..)

import Dict exposing (Dict)
import IxDict



{- The new, lazy and safe way

   Initialize the IxDict with the helper `empty`
   Or Initialize using singleton
-}


type alias User =
    { id : String
    , name : String
    }


users : IxDict.IxDict String User
users =
    IxDict.fromListBy .id
        [ User "alice" "Alice"
        , User "bob" "Bob"
        ]


updated : IxDict.IxDict String User
updated =
    users
        |> IxDict.insert (User "charlie" "Charlie")
        |> IxDict.remove "bob"



{- The old way

   We are about to create a `Dict String String` that uses the `.id` as key,
   so the following should not be possible.

   Also accessing .id everytime is just inconvenient.
-}


bob : User
bob =
    User "bob" "Bob"


usersOld : Dict String User
usersOld =
    Dict.empty
        -- | Wrong key
        |> Dict.insert "charlie" (User "alice" "Alice")
        -- | Inconvenient
        |> Dict.insert bob.id bob



-- Fun stuff


tuples : Maybe ( number, String )
tuples =
    IxDict.empty Tuple.first
        |> IxDict.insert ( 2, "Twice the fun" )
        |> IxDict.insert ( 3, "Three" )
        |> IxDict.get 3


{-| You also get sets out of the box.
(Although you might want to use the core/Set library)

    setOfStrings =
        IxDict.singleton identity "0I8V-QZFNC3LHhQavdQmz"

    setOfNumbers =
        IxDict.singleton identity 8985373

    setOfTuples =
        IxDict.singleton identity ( 100, 200 )

-}
set : IxDict.IxDict comparable comparable
set =
    IxDict.empty identity
