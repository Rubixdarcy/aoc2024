import std/fixpoint/memo

fun main()
    cache
        test(5)

fun test(n: int) : cache<int, int> int
    with memo(n)
    n + 1
