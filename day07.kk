import std/os/file
import std/os/path


fun parse-input(input: string) : exn list<(int, list<int>)>
    with line <- input.split("\n").filter(is-notempty).map

    val Cons(total, Cons(operand-string, _)) = line.split(":")

    val operands = operand-string.split(" ")
        .filter(is-notempty)
        .map fn(n) n.parse-int.unjust
    (total.parse-int.unjust, operands)

effect ctl pick(xs: list<a>) : a

val ops: list<(int, int) -> int> = [(+), (*)]

fun compute(x: int, y: int) : pick int
    pick(ops)(x, y)

fun compute-list(xs: list<int>, l: int) : <exn,pick> int
    xs.foldl1(fn(x, y) compute(x, y).limit(l))

fun limit(x: int, limit: int) : pick int
    if x > limit then
        pick([])
    x

fun all-options(action: () -> <pick|e> a) : e list<a>
    val h = handler
        ctl pick(xs)
            xs.flatmap(fn(x) resume(x))
    h({ [action()] })

fun part1(input: list<(int, list<int>)>)
    println("Input: " ++ input.show)
    val total = input
        .filter fn((total, ops))
            println("Total " ++ total.show)
            all-options({ ops.compute-list(total) }).any(fn(t) t == total)
        .map(fn((t, _l)) t)
        .sum()

    println("Part 1: " ++ total.show)

effect fun log(msg: string) : ()

fun main()
    val log-enabled = True
    with fun log(msg)
        if log-enabled then println(msg)

    val input = parse-input(read-text-file(path("input/d07.txt")))

    part1(input)
