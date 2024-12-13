import std/os/file
import std/os/path
import std/text/regex

val log-enabled = True
val input-filename = "input/d13.txt"

effect fun log(msg: string) : ()

fun main()
    with fun log(msg: string)
        if log-enabled then console/string/println(msg)

    val input = parse-input(read-text-file(path(input-filename)))

    log("Input " ++ input.show)
    part1(input)

fun part1(input: list<problem>)
    val total = input
        .filter-map(solve)
        .map(fn((a, b)) a * 3 + b)
        .sum

    println("Part 1: " ++ total.show)



fun parse-input(input: string) : exn list<problem>
    val r = regex(r"X.(\d+).*Y.(\d+)")

    with prob <- input.trim().split("\n\n").map
    val Cons(a-line, Cons(b-line, Cons(p-line, Nil))) = prob.split("\n")
    val a = r.exec(a-line).vector
    val b = r.exec(b-line).vector
    val p = r.exec(p-line).vector

    fun slice2int(s: sslice)
        s.string.parse-int.unjust

    Problem(
        xa = slice2int(a[1]),
        ya = slice2int(a[2]),
        xb = slice2int(b[1]),
        yb = slice2int(b[2]),
        xp = slice2int(p[1]),
        yp = slice2int(p[2])
    )


struct problem
    xa : int
    ya : int
    xb : int
    yb : int
    xp : int
    yp : int

fun problem/show(p: problem) : string
    (
        "{" ++
        "xa=" ++ p.xa.show ++
        ", ya=" ++ p.ya.show ++
        ", xb=" ++ p.xb.show ++
        ", yb=" ++ p.yb.show ++
        ", xp=" ++ p.xp.show ++
        ", yp=" ++ p.yp.show ++
        "}"
    )

fun solve(p: problem) : maybe<(int, int)>
    val (b, m) = divmod((p.xa * p.yp - p.ya * p.xp), (p.xa * p.yb - p.xb * p.ya))
    if m != 0 then return Nothing

    val (a, m2) = divmod(p.xp - p.xb * b, p.xa)
    if m2 != 0 then return Nothing

    Just((a, b))


