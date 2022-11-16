module Test.IxDict exposing (tests)

import Basics exposing (..)
import Dict
import Expect
import IxDict exposing (toDict)
import Maybe exposing (..)
import Test exposing (..)


animals : IxDict.IxDict String ( String, String )
animals =
    IxDict.fromListBy Tuple.first
        [ ( "Tom", "cat" )
        , ( "Jerry", "mouse" )
        ]


alice : { id : String, name : String }
alice =
    { id = "userIdAlice", name = "Alice" }


equalIxDicts : IxDict.IxDict k v -> IxDict.IxDict k v -> Expect.Expectation
equalIxDicts ixd1 ixd2 =
    Expect.equal (IxDict.toDict ixd1) (IxDict.toDict ixd2)


tests : Test
tests =
    let
        buildTests =
            describe "build Tests"
                [ test "empty" <|
                    \() -> Expect.equal (IxDict.toDict <| IxDict.fromListBy identity []) Dict.empty
                , test "singleton" <|
                    \() -> Expect.equal (Dict.fromList [ ( "k", ( "k", "v" ) ) ]) (toDict <| IxDict.singletonFromTuple ( "k", "v" ))
                , test "insert" <|
                    \() ->
                        equalIxDicts
                            (IxDict.singleton .id alice)
                            (IxDict.insert alice (IxDict.empty .id))
                , test "insert replace" <|
                    \() ->
                        equalIxDicts
                            (IxDict.singleton .id { alice | name = "Alice in Wonderland" })
                            (IxDict.insert { alice | name = "Alice in Wonderland" } (IxDict.singleton .id alice))
                , test "remove" <|
                    \() ->
                        equalIxDicts
                            (IxDict.empty Tuple.first)
                            (IxDict.remove "k" (IxDict.singletonFromTuple ( "k", "v" )))
                , test "remove not found" <|
                    \() ->
                        equalIxDicts
                            (IxDict.singletonFromTuple ( "k", "v" ))
                            (IxDict.remove "kk" (IxDict.singletonFromTuple ( "k", "v" )))
                ]

        queryTests =
            describe "query Tests"
                [ test "member 1" <|
                    \() -> Expect.equal True (IxDict.member "Tom" animals)
                , test "member 2" <|
                    \() -> Expect.equal False (IxDict.member "Spike" animals)
                , test "get 1" <|
                    \() -> Expect.equal (Just ( "Tom", "cat" )) (IxDict.get "Tom" animals)
                , test "get 2" <|
                    \() -> Expect.equal Nothing (IxDict.get "Spike" animals)
                , test "size of empty dictionary" <|
                    \() -> Expect.equal 0 (IxDict.size (IxDict.empty identity))
                , test "size of example dictionary" <|
                    \() -> Expect.equal 2 (IxDict.size animals)
                ]

        combineTests =
            describe "combine Tests"
                [ test "union" <|
                    \() ->
                        equalIxDicts
                            animals
                            (IxDict.union (IxDict.singletonFromTuple ( "Jerry", "mouse" )) (IxDict.singletonFromTuple ( "Tom", "cat" )))
                , test "union collison" <|
                    \() ->
                        equalIxDicts
                            (IxDict.singletonFromTuple ( "Tom", "cat" ))
                            (IxDict.union (IxDict.singletonFromTuple ( "Tom", "cat" )) (IxDict.singletonFromTuple ( "Tom", "mouse" )))
                , test "intersect" <|
                    \() ->
                        equalIxDicts
                            (IxDict.singletonFromTuple ( "Tom", "cat" ))
                            (IxDict.intersect animals (IxDict.singletonFromTuple ( "Tom", "cat" )))
                , test "diff" <|
                    \() ->
                        equalIxDicts
                            (IxDict.singletonFromTuple ( "Jerry", "mouse" ))
                            (IxDict.diff animals (IxDict.singletonFromTuple ( "Tom", "cat" )))
                ]

        transformTests =
            describe "transform Tests"
                [ test "filter" <|
                    \() ->
                        equalIxDicts
                            (IxDict.singletonFromTuple ( "Tom", "cat" ))
                            (IxDict.keep (\k _ -> k == "Tom") animals)
                , test "partition" <|
                    \() ->
                        Expect.equal
                            ( IxDict.singletonFromTuple ( "Tom", "cat" ), IxDict.singletonFromTuple ( "Jerry", "mouse" ) )
                            (IxDict.partition (\k _ -> k == "Tom") animals)
                , test "mapValuesUnsafe" <|
                    \() ->
                        let
                            ixd =
                                IxDict.singletonFromTuple ( "Tom", "cat" )

                            ixdT =
                                IxDict.singletonFromTuple ( "Tom", "CAT" )
                        in
                        equalIxDicts
                            ixdT
                            (IxDict.mapValuesUnsafe (\_ -> Tuple.mapSecond String.toUpper) ixd)
                ]
    in
    describe "Dict Tests"
        [ buildTests
        , queryTests
        , combineTests
        , transformTests
        ]
