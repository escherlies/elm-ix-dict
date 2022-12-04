module IxDict exposing
    ( IxDict
    , toDict, fromListBy, fromDictBy, empty, singleton
    , insert, remove
    , isEmpty, member, memberByIx, memberExact, get, size
    , keys, values, toList
    , map, mapWith, foldl, foldr, filter, keep, reject, partition
    , union, intersect, diff
    , emptyFromTuple, emptyFromId, singletonFromTuple, singletonFromId
    )

{-| A Dict data structure that derives keys from values. The keys can be any comparable
type. This includes `Int`, `Float`, `Time`, `Char`, `String`, and tuples or
lists of comparable types.
Since it uses the underlying core/Dict module, insert, remove, and query operations all take _O(log n)_ time.


# Indexed Dictionaries

@docs IxDict


# Create

@docs toDict, fromListBy, fromDictBy, empty, singleton


# Manipulate

@docs insert, remove


# Query

@docs isEmpty, member, memberByIx, memberExact, get, size


# Lists

@docs keys, values, toList


# Transform

@docs map, mapWith, foldl, foldr, filter, keep, reject, partition


# Combine

@docs union, intersect, diff


# Convenience

@docs emptyFromTuple, emptyFromId, singletonFromTuple, singletonFromId

-}

import Dict exposing (Dict)


type IxDict k v
    = IxDict (v -> k) (Dict k v)


toDict : IxDict k v -> Dict k v
toDict (IxDict _ dict) =
    dict


{-| Create an indexed dictionary from list by providing a key fn.

    users : IxDict.IxDict String User
    users =
        IxDict.fromListBy .id
            [ User "alice" "Alice"
            , User "bob" "Bob"
            ]

    type alias User =
        { id : String, name : String }

    updated : IxDict.IxDict String User
    updated =
        users
            |> IxDict.insert (User "charlie" "Charlie")
            |> IxDict.remove "bob"

-}
fromListBy : (v -> comparable) -> List v -> IxDict comparable v
fromListBy keyFn =
    IxDict keyFn << Dict.fromList << List.map (\v -> ( keyFn v, v ))


fromDictBy : (v -> comparable) -> Dict k v -> IxDict comparable v
fromDictBy keyFn =
    fromListBy keyFn << Dict.values


{-| Create an empty indexed dictionary using a keyFn
-}
empty : (v -> comparable) -> IxDict comparable v
empty keyFn =
    IxDict keyFn Dict.empty


{-| Create a dictionary with one key-value pair and a keyFn
-}
singleton : (v -> comparable) -> v -> IxDict comparable v
singleton keyFn v =
    fromDictBy keyFn <| Dict.singleton (keyFn v) v


{-| Insert a value into an indexed dictionary. Replaces value when there is
a collision.
-}
insert : v -> IxDict comparable v -> IxDict comparable v
insert v (IxDict keyFn dict) =
    IxDict keyFn <| Dict.insert (keyFn v) v dict


{-| Remove a key-value pair from the dictionary. If the key is not found, no changes are made.
-}
remove : comparable -> IxDict comparable v -> IxDict comparable v
remove k (IxDict keyFn dict) =
    IxDict keyFn <| Dict.remove k dict


{-| Determine if a dictionary is empty.
-}
isEmpty : IxDict k v -> Bool
isEmpty (IxDict _ dict) =
    Dict.isEmpty dict


{-| Determine if a key is in a dictionary.
-}
member : comparable -> IxDict comparable v -> Bool
member key (IxDict _ dict) =
    Dict.member key dict


{-| Determine if a value is in a dictionary, only by comparing keys.
-}
memberByIx : v -> IxDict comparable v -> Bool
memberByIx value (IxDict keyFn dict) =
    Dict.member (keyFn value) dict


{-| Determine if a value is structually in a dictionary.
-}
memberExact : v -> IxDict comparable v -> Bool
memberExact value (IxDict keyFn dict) =
    Dict.get (keyFn value) dict
        |> Maybe.map (\dictV -> dictV == value)
        |> Maybe.withDefault False


{-| Get the value associated with a key.
-}
get : comparable -> IxDict comparable v -> Maybe v
get k (IxDict _ dict) =
    Dict.get k dict


{-| Determine the number of key-value pairs in the dictionary.
-}
size : IxDict k v -> Int
size =
    Dict.size << toDict


{-| Get all of the keys in a dictionary, sorted from lowest to highest.
-}
keys : IxDict k v -> List k
keys =
    Dict.keys << toDict


{-| Get all of the values in a dictionary, in the order of their keys.
-}
values : IxDict k v -> List v
values =
    Dict.values << toDict


{-| Convert a dictionary into an association list of key-value pairs, sorted by keys.
-}
toList : IxDict k v -> List ( k, v )
toList =
    Dict.toList << toDict


{-| Map a function onto a ixDict, creating a new ixDict with no duplicates.

This operation is not structure-preserving for sets, so is not a valid Functor. An example case: mapping const x over a ixDict with n > 0 elements will result in a ixDict with one element.

-}
map : (comparable -> b -> b) -> IxDict comparable b -> IxDict comparable b
map fn (IxDict keyFn current) =
    fromDictBy keyFn (Dict.map fn current)


{-| Transform values and rebuild the dict with a new keyFn
-}
mapWith : (b -> comparable) -> (comparable -> a -> b) -> IxDict comparable a -> IxDict comparable b
mapWith ixfn fn current =
    fromDictBy ixfn (Dict.map fn (toDict current))



-- Reduce


foldl : (k -> v -> b -> b) -> b -> IxDict k v -> b
foldl fn acc =
    Dict.foldl fn acc << toDict


foldr : (k -> v -> b -> b) -> b -> IxDict k v -> b
foldr fn acc =
    Dict.foldr fn acc << toDict



-- Save operations that do not alter the data structure


{-| Filter... use `keep` or `reject` instead.

Because, what does it filter? Do you want the filtered product like coffee
(in this case, use reject) or the remaining good part like gold pannig (in this
case, use keep)

-}
filter : Never -> a
filter =
    never


{-| Keep only the key-value pairs that pass the given test.
-}
keep : (comparable -> v -> Bool) -> IxDict comparable v -> IxDict comparable v
keep fn (IxDict keyFn dict) =
    IxDict keyFn (Dict.filter fn dict)


{-| Reject all key-value pairs that for a given test
-}
reject : (comparable -> v -> Bool) -> IxDict comparable v -> IxDict comparable v
reject fn (IxDict keyFn dict) =
    IxDict keyFn (Dict.filter (\k v -> not (fn k v)) dict)


partition : (comparable -> v -> Bool) -> IxDict comparable v -> ( IxDict comparable v, IxDict comparable v )
partition fn (IxDict keyFn dict) =
    Tuple.mapBoth (IxDict keyFn) (IxDict keyFn) (Dict.partition fn dict)


union : IxDict comparable v -> IxDict comparable v -> IxDict comparable v
union (IxDict keyFn d1) (IxDict _ d2) =
    IxDict keyFn <| Dict.union d1 d2


intersect : IxDict comparable v -> IxDict comparable v -> IxDict comparable v
intersect (IxDict keyFn d1) (IxDict _ d2) =
    IxDict keyFn <| Dict.intersect d1 d2


diff : IxDict comparable v -> IxDict comparable v -> IxDict comparable v
diff (IxDict keyFn d1) (IxDict _ d2) =
    IxDict keyFn <| Dict.diff d1 d2



-- Convenience


{-| Uses Tuple.first as keyFn
-}
emptyFromTuple : IxDict comparable ( comparable, b )
emptyFromTuple =
    empty Tuple.first


{-| Uses .id as keyFn
-}
emptyFromId : IxDict comparable { a | id : comparable }
emptyFromId =
    empty .id


{-| Uses Tuple.first as keyFn
-}
singletonFromTuple : ( comparable, b ) -> IxDict comparable ( comparable, b )
singletonFromTuple =
    singleton Tuple.first


{-| Uses .id as keyFn
-}
singletonFromId : { a | id : comparable } -> IxDict comparable { a | id : comparable }
singletonFromId =
    singleton .id
