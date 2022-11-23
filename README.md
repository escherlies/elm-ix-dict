# elm-ix-dict

An experimental Dict data structure that derives keys from values. It provides a safe and lazy way to work with indexed data structures and wraps around elm/core/Dict.

## Quick start

Use `singleton`, `empty` or `fromListBy` to create and IxDict using a key function:

```elm
type alias User =
    { id : String
    , name : String
    }

users : IxDict.IxDict comparable User
users =
    IxDict.fromListBy .id
        [ User "alice" "Alice"
        , User "bob" "Bob"
        ]
```

Use the `IxDict` lib to build, query, list, transform and combine `IxDict`s. For example:

```elm
updated : IxDict.IxDict comparable User
updated =
    users
        |> IxDict.insert (User "charlie" "Charlie")
        |> IxDict.remove "bob"
```

And that's it!

Note that you can use not just records, but any data type that can be converted to a `comparable` via the `keyFn`. This also applies to keys. For example:

```elm
tuples : Maybe ( number, String )
tuples =
    IxDict.empty Tuple.first
        |> IxDict.insert ( 2, "Twice the fun" )
        |> IxDict.insert ( 3, "Three" )
        |> IxDict.get 3
```

You also get sets out of the box. (Although you might want to use the core/Set library, which actually uses `Dict s ()` under the hood!)

```elm
set =
    IxDict.empty identity

setOfStrings =
    IxDict.singleton identity "0I8V-QZFNC3LHhQavdQmz"

setOfNumbers =
    IxDict.singleton identity 8985373

setOfTuples =
    IxDict.singleton identity ( 100, 200 )
```

## Problem using a conventional Dict

Given a conventional `Dict` of type `Dict String User`,

```elm
usersOld : Dict String User
usersOld =
    Dict.empty
        -- | Wrong key
        |> Dict.insert "charlie" (User "alice" "Alice")
        -- | Inconvenient
        |> Dict.insert bob.id bob -- bob = User "bob" "Bob"
```

two problems arise from this approach:

1. We have no guarantee that the `Dict` keys map to the same `.id` field in users.
2. Having to deal with accessing .id everythime we want to do a `Dict` operation is just inconvenient. This also applies to other Data structures used as values, i.e. Tuples


## Notes

Having encountered the same problem in PureScript, Michael inspired me to generalize it into a small library. Check out his [purescript-ix-maps](https://github.com/thought2/purescript-ix-maps)

### Structural non-perserving 

Using the IxDict data constructor alone is unsafe when doing operations, since it is not guaranteed that the keyFn is applied. It is not exported and you have to use `empty`, `singleton`, `fromListBy` or `fromDictBy` to construct your IxDict.

Also, the map fn is not a valid Functor as it is not structure-preserving. An example case: mapping const x over an ixDict with n > 1 elements will result in a set with one element.