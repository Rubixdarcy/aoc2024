import std/os/file
import std/os/path

alias rules-reports = (list<(int, int)>, list<list<int>>)

effect fun log(msg: string) : ()

fun sorted-key(xs: list<int>, key: (int) -> pure int) : pure list<int>
    match xs
        Nil -> Nil
        Cons(x0, Nil) -> Cons(x0, Nil)
        Cons(x0, xs') ->
            val x0-key = x0.key
            val (le, gt) = xs'.partition(fn(x) x.key <= x0-key)
            le.sorted-key(key) ++ [x0] ++ gt.sorted-key(key)

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

effect visit
    fun visit(node: int) : ()
    fun previsit(node: int) : bool

fun tsort(graph: vector<list<int>>)

    val idxs-mut = vector-init(100, fn(_i) ref(-1))
    var current := 0

    val record-idxs = handler
        fun visit(node)
            log("Visit " ++ node.show)
            val idx = idxs-mut.at(node).unjust
            idx := current
            current := current + 1
            ()

        fun previsit(node)
            log("Is visited? " ++ node.show ++ " " ++ current.show)
            val idx = idxs-mut.at(node).unjust
            val result = !idx != -1
            if !idx == -1 then idx := -2
            result

    record-idxs()
        graph.foreach-indexed fn(i, _nodes)
            tsort-single(graph, i)

    idxs-mut.map fn(idx) !idx

fun tsort-single(graph: vector<list<int>>, i: int) : <pure,visit> ()
    if previsit(i) then return ()
    graph.at(i).unjust.foreach(fn(n) tsort-single(graph, n))
    visit(i)


fun part2((rules-list, reports): rules-reports)
    val rules-mut = vector-init(100, fn(_i) ref(Nil))

    rules-list.foreach fn((l, r))
        val rule = rules-mut.at(r).unjust
        rule := Cons(l, !rule)

    val rules = rules-mut.map(fn(r) !r)
    val order = tsort(rules)

    val total = reports
        .filter fn(report)
            log("Report idxs: " ++ report.map(fn(i) order.at(i).unjust).show)
            report.zip(report.tail)
                .any(fn((a, b)) order.at(a).unjust > order.at(b).unjust)
        .map fn(report)
            val fixed = report.sorted-key(fn(i) order.at(i).unjust)
            if fixed.zip(fixed.tail).any(fn((a, b)) order.at(a).unjust > order.at(b).unjust) then
                println("FAILED report " ++ fixed.show)
            middle-acc(fixed, fixed)
        .sum

    println("Part 2: " ++ total.show)

fun main()
    val log-enabled = True
    with fun log(msg)
        if log-enabled then println(msg)

    val input = parse-input(read-text-file(path("input/d05.txt")))

    part2(input)


