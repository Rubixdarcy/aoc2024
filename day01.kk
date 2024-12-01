
import std/text/parse
import std/os/file
import std/os/path

// Seems there's no builtin sort
fun sorted(xs: list<int>) : div list<int>
    match xs
        Nil -> Nil
        Cons(x0, Nil) -> Cons(x0, Nil)
        Cons(x0, xs') ->
            val (le, gt) = xs'.partition(fn(x) x <= x0)
            le.sorted ++ [x0] ++ gt.sorted

fun p-int() : <pure,parse> int
    digits().parse-int.unjust

fun p-list() : <pure,parse> list<(int, int)>
    with many
    val n1 = p-int()
    whitespace0()
    val n2 = p-int()
    whitespace0()
    (n1, n2)

fun part1(input: string)
    val pairs = parse(input.slice, p-list).maybe.unjust
    val ns1 = pairs.map(fn((n, _)) {n}).sorted
    val ns2 = pairs.map(fn((_, n)) {n}).sorted
    zipwith(ns1, ns2, fn(a, b) abs(a - b)).sum

fun part2(input: string)
    val pairs = parse(input.slice, p-list).maybe.unjust
    val ns1 = pairs.map(fn((n, _)) {n}).sorted
    val ns2 = pairs.map(fn((_, n)) {n}).sorted
    ns2.filter(fn(n2) ns1.any(fn(n1) n1 == n2)).sum

fun main()
    val input = read-text-file(path("input/d01p1.txt"))

    println("Part 1: " ++ part1(input).show)
    println("Part 2: " ++ part2(input).show)
