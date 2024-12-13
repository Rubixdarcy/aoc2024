import std/os/file
import std/os/path
import std/fixpoint/memo
import std/data/rb-map

val log-enabled = False
val input-filename = "input/d11.txt"
val input-gen = 25

effect fun log(msg: string) : ()

fun main()
    with fun log(msg: string)
        if log-enabled then console/string/println(msg)

    val input = parse-input(read-text-file(path(input-filename)))

    log("Input " ++ input.show)
    part1(input)

fun part1(input: list<int>)
    val inputs = input.map fn(n) (n, input-gen)
    val result: rbmap<(int, int), int> =
        with cache
        val pair = inputs.each
        stones(pair)

    val total = inputs.map(fn(i) result.lookup(i).unjust).sum

    println("Part 1: " ++ total.show)

fun parse-input(input: string) : exn list<int>
    input.trim().split(" ").filter(is-notempty).map(fn(s) s.parse-int().unjust)


fun stones((n, gen): (int, int)) : <pure,log,cache<(int, int), int>> int
    with memo((n, gen))
    log(n.show ++ " " ++ gen.show)
    if gen == 0 then
        1
    else
        val gen' = gen - 1
        val n-slice = n.show.slice
        val n-digits = n-slice.count
        if n == 0 then
            stones((1, gen'))
        elif n-digits % 2 == 0 then
            val half = n-digits / 2
            val a = n-slice.subslice(0, half).string.parse-int.unjust
            val b = n-slice.subslice(half, n-digits).string.parse-int.unjust
            stones((a, gen')) + stones((b, gen'))
        else
            stones((n * 2024, gen'))


fun order2((x1, y1): (int, int), (x2, y2): (int, int)) : order2<(int,int)>
    if x1 < x2 then
        Lt2((x1, y1), (x2, y2))
    elif x1 > x2 then
        Gt2((x2, y2), (x1, y1))
    else
        if y1 < y2 then
            Lt2((x1, y1), (x2, y2))
        elif y1 > y2 then
            Gt2((x2, y2), (x1, y1))
        else
            Eq2((x1, y1))

