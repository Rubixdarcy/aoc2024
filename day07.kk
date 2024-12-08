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

val ops1: list<(int, int) -> <exn,log,pick> int> = [(+), (*)]
val ops2: list<(int, int) -> <exn,log,pick> int> = [
    (+), (*), fn(x, y) (x.show ++ y.show).parse-int.unjust]

fun compute(x: int, y: int, ops: list<(int, int) -> <pick|e> int>) : <pick|e> int
    val op = pick(ops)
    op(x, y)

fun compute-list(xs: list<int>, l: int,
                 ops: list<(int, int) -> <pick,exn|e> int>) : <pick,exn|e> int
    xs.foldl1(fn(x, y) compute(x, y, ops).limit(l))

fun limit(x: int, limit: int) : pick int
    if x > limit then
        pick([])
    x

fun all-options(action: () -> <pick|e> a) : e list<a>
    val h = handler
        ctl pick(xs)
            xs.flatmap(fn(x) resume(x))
    h({ [action()] })

fun part(input: list<(int, list<int>)>,
         ops: list<(int, int) -> <exn,log,pick> int>) : <exn,log> int
    input
        .filter fn((total, operands))
            log("Total " ++ total.show)
            all-options({ operands.compute-list(total, ops) }).any(fn(t) t == total)
        .map(fn((t, _l)) t)
        .sum()

fun part1(input: list<(int, list<int>)>)
    println("Part 1: " ++ part(input, ops1).show)

fun part2(input: list<(int, list<int>)>)
    println("Part 2: " ++ part(input, ops2).show)

effect fun log(msg: string) : ()

fun main()
    val log-enabled = False
    with fun log(msg)
        if log-enabled then println(msg)

    val input = parse-input(read-text-file(path("input/d07.txt")))

    part1(input)
    part2(input)
