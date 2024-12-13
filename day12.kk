import std/os/file
import std/os/path
import std/data/hashset
import std/data/hash

val log-enabled = True
val input-filename = "input/d12.txt"

effect fun log(msg: string) : ()

fun main()
    with fun log(msg)
        if log-enabled then println(msg)

    val input = parse-input(read-text-file(path(input-filename)))
    part1(input)

val directions = [
    (1, 0),
    (0, 1),
    (-1, 0),
    (0, -1)
]

fun (+)((x1, y1): (int, int), (x2, y2): (int, int)) : (int, int)
    (x1 + x2, y1 + y2)

fun part1(input: map)
    var closed: hash-set<int> := thread/hash-set()
    var cost := 0
    var area := 0
    var perimiter := 0
    var region-open := []

    input.foreach-indexed fn(point as (x, y), c)
        val point-n = y * 1000 + x
        if !closed.contains(point-n) then
            area := 0
            perimiter := 0
            region-open := [point]
            while { region-open != Nil }
                if region-open.length > 800 then throw("region-open too big")
                val region-point as (rx, ry) = region-open.head.unjust
                region-open := region-open.tail

                val region-point-n = ry * 1000 + rx
                if !closed.contains(region-point-n) then
                    area := area + 1
                    directions.foreach fn(dir)
                        val neigh = region-point + dir
                        if input.at(neigh) == Just(c) then
                            region-open := Cons(neigh, region-open)
                        else
                            perimiter := perimiter + 1
                    closed := closed.insert(region-point-n)
            cost := cost + area * perimiter

    println("Part 1: " ++ cost.show)




struct map
    width: int
    height: int
    tiles: vector<vector<char>>

fun map/at(m: map, (x, y): (int, int)) : maybe<char>
    m.tiles.at(y).maybe(Nothing, fn(row) row.at(x))

fun map/foreach-indexed(m: map, f: ((int, int), char) -> e ()) : e ()
    m.tiles.foreach-indexed fn(y, row)
        row.foreach-indexed fn(x, c)
            f((x, y), c)



fun parse-input(input: string) : exn map
    val tiles = input.trim()
        .split("\n")
        .map(vector)
        .vector

    Map(
        width = tiles.at(0).maybe(0, fn(row) row.length),
        height = tiles.length,
        tiles = tiles
    )
