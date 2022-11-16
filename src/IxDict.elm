module IxDict exposing (IxDict, bimap, diff, empty, emptyFromId, emptyFromTuple, foldl, foldr, fromDictBy, fromListBy, get, insert, intersect, isEmpty, keep, keys, mapValuesUnsafe, member, partition, reject, remove, singleton, singletonFromId, singletonFromTuple, size, toDict, toList, union, values)

import Dict exposing (Dict)


type IxDict k v
    = IxDict (v -> k) (Dict k v)


toDict : IxDict k v -> Dict k v
toDict (IxDict _ dict) =
    dict


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


{-| Get the value associated with a key. If the key is not found, return
`Nothing`. This is useful when you are not sure if a key will be in the
dictionary.

    animals = fromListBy Tuple.first [ ("Tom", Cat), ("Jerry", Mouse) ]
    get "Tom" animals == Just Cat
    get "Jerry" animals == Just Mouse
    get "Spike" animals == Nothing

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


{-| Unsafely map over values.

It's unsafe because one can change the id values.

This implementation is also expensive as it rebuilds the dictionary.

Of course you cannot change the data type of the values.

For that, use bimap and provide a fresh keyFn.

-}
mapValuesUnsafe : (comparable -> b -> b) -> IxDict comparable b -> IxDict comparable b
mapValuesUnsafe fn (IxDict keyFn current) =
    fromDictBy keyFn (Dict.map fn current)


{-| Transform keys and value

Since keyFn relys on the values of that dict, mapping the values requires also providing a new mapping function, due to the limitations of Elm

-}
bimap : (b -> comparable) -> (comparable -> a -> b) -> IxDict comparable a -> IxDict comparable b
bimap ixfn fn current =
    fromDictBy ixfn (Dict.map fn (toDict current))



-- Reduce


foldl : (k -> v -> b -> b) -> b -> IxDict k v -> b
foldl fn acc =
    Dict.foldl fn acc << toDict


foldr : (k -> v -> b -> b) -> b -> IxDict k v -> b
foldr fn acc =
    Dict.foldr fn acc << toDict



-- Save operations that do not alter the data structure


keep : (comparable -> v -> Bool) -> IxDict comparable v -> IxDict comparable v
keep fn (IxDict keyFn dict) =
    IxDict keyFn (Dict.filter fn dict)


reject : (comparable -> v -> Bool) -> IxDict comparable v -> IxDict comparable v
reject fn (IxDict keyFn dict) =
    IxDict keyFn (Dict.filter (\k v -> not (fn k v)) dict)


partition : (comparable -> v -> Bool) -> IxDict comparable v -> ( IxDict comparable v, IxDict comparable v )
partition fn (IxDict keyFn dict) =
    Tuple.mapBoth (IxDict keyFn) (IxDict keyFn) (Dict.partition fn dict)


union : IxDict comparable v -> IxDict comparable v -> IxDict comparable v
union (IxDict keyFn d1) ixd2 =
    IxDict keyFn <| Dict.union d1 (toDict ixd2)


intersect : IxDict comparable v -> IxDict comparable v -> IxDict comparable v
intersect (IxDict keyFn d1) ixd2 =
    IxDict keyFn <| Dict.intersect d1 (toDict ixd2)


diff : IxDict comparable v -> IxDict comparable v -> IxDict comparable v
diff (IxDict keyFn d1) ixd2 =
    IxDict keyFn <| Dict.diff d1 (toDict ixd2)



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
