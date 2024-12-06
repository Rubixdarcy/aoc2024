import std/os/file
import std/os/path

alias rules-reports = (list<(int, int)>, list<list<int>>)

effect fun log(msg: string) : ()

fun middle-acc(l: list<a>, mid: list<a>) : pure a
    match l
        Nil -> mid.head.unjust
        Cons(_, Nil) -> mid.head.unjust
        Cons(_, Cons(_, l')) -> middle-acc(l', mid.tail)

fun notdisjoint(xs: list<int>, ys: list<int>) : bool
    xs.any fn(x)
        ys.any fn(y) x == y

fun is-valid(report: list<int>, rules: vector<list<int>>) : pure bool
    match report
        Nil -> True
        Cons(n, ns) ->
            if notdisjoint(ns, rules.at(n).unjust) then False
            else is-valid(ns, rules)

fun parse-input(input: string) : <exn,log> rules-reports
    val Cons(rules-s, Cons(reports-s, _)) = input.split("\n\n")

    val rules = rules-s.split("\n").map fn(line)
        val Cons(l, Cons(r, _)) = line.split("|")
        (l.parse-int.unjust, r.parse-int.unjust)

    val reports = reports-s.split("\n")
        .filter(is-notempty)
        .map fn(line)
            line.split(",").map(fn(n) n.parse-int.unjust)

    (rules, reports)


fun part1((rules-list, reports): rules-reports)
    val rules-mut = vector-init(100, fn(_i) ref(Nil))

    rules-list.foreach fn((l, r))
        val rule = rules-mut.at(r).unjust
        rule := Cons(l, !rule)

    val rules = rules-mut.map(fn(r) !r)

    val result = reports
        .filter(fn(r) is-valid(r, rules))
        .map(fn(r) middle-acc(r, r))
        .sum()

    println("Part 1: " ++ result.show)


fun main()
    val log-enabled = True
    with fun log(msg)
        if log-enabled then println(msg)

    val input = parse-input(read-text-file(path("input/d05.txt")))

    part1(input)


