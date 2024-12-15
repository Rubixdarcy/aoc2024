import std/os/file
import std/os/path
import std/text/regex
import std/os/readline

val log-enabled = False

// val input-filename = "input/d14_sample.txt"
// val input-width = 11
// val input-height = 7
// val input-seconds = 100

val input-filename = "input/d14.txt"
val input-width = 101
val input-height = 103
val input-seconds = 100


effect fun log(msg: string) : ()

fun main()
    with fun log(msg: string)
        if log-enabled then console/string/println(msg)

    val input = parse-input(read-text-file(path(input-filename)))

    log("Input " ++ input.show)
    part1(input)
    part2(input)

fun part1(input: list<(position, velocity)>)
    var quads := vector(4, 0)
    input
        .filter-map fn((p, v))
            sim(p, v, input-seconds).quadrant(input-width, input-height)
        .foreach fn(q)
            quads[q] := quads[q] + 1
    val total = quads.list.foldl1((*))
    println("Part 1: " ++ total.show)

fun part2(input: list<(position, velocity)>)
    var t := 2
    while { readline().is-empty }
        val map = vector-init(input-width * input-height, fn(_i) ref(' '))
        println(t.show)
        println("")
        input.foreach fn((p, v))
            val Position(x, y) = sim(p, v, t).bound(input-width, input-height)
            val i = y * input-width + x
            val r = map.at(i).unjust
            r := '#'
        val map-s = map.list
            .map-indexed fn(i, c)
                if i % input-width == 0 then
                    "\n" ++ (!c).string
                else
                    (!c).string
            .join
        println(map-s)
        t := t + 101






value struct position { x: int; y: int}
fun position/show(Position(x, y) : position) "Position" ++ (x, y).show

fun position/quadrant(Position(x, y), width: int, height: int) : maybe<int>
    val (w2, _) = divmod(width, 2)
    val (h2, _) = divmod(height, 2)

    val x' = x % width
    val y' = y % height

    if x' == w2 || y' == h2 then return Nothing

    val qh = if x' < w2 then 0 else 1
    val qv = if y' < h2 then 0 else 1

    Just(qv * 2 + qh)

fun position/bound(Position(x, y), width: int, height: int) : position
    Position(x % width, y % height)


value struct velocity { x: int; y: int}
fun velocity/show(Velocity(x, y) : velocity) "Velocity" ++ (x, y).show

fip fun sim(Position(x, y), Velocity(vx, vy), t: int) : position
    Position(x + vx * t, y + vy * t)

fun parse-input(input: string) : <exn,log> list<(position, velocity)>
    val r = regex(r"(?<=[,=])-?\d+")

    with line <- input.trim.split("\n").map
    log(line.find-all(r).show)
    val [px, py, vx, vy] = line.find-all(r).map(fn(s) s.parse-int.unjust)
    (Position(px, py), Velocity(vx, vy))
