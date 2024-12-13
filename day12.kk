import std/os/file
import std/os/path
import std/data/hashset
import std/data/hash
import std/num/int64

val log-enabled = False
val input-filename = "input/d12.txt"

effect fun log(msg: string) : ()

fun main()
    with fun log(msg)
        if log-enabled then println(msg)

    val input = parse-input(read-text-file(path(input-filename)))
    part1(input)
    part2(input)

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
                if region-open.length > 1000 then throw("region-open too big")
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


fun hash(((x1, y1), (x2, y2)): ((int, int), (int, int)), n: int64, ?hash : (int, int64) -> int) : int
    hash(x1 * 1000 * 1000 * 1000 + y1 * 1000 * 1000 + x2 * 1000 + y2, n)

fun part2(input: map)
    var closed: hash-set<int> := thread/hash-set()
    var cost := 0
    var area := 0
    var fences: list<((int, int), (int, int))> := []
    var region-open := []

    input.foreach-indexed fn(point as (x, y), c)
        val point-n = y * 1000 + x
        if !closed.contains(point-n) then
            area := 0
            fences := []
            region-open := [point]
            while { region-open != Nil }
                if region-open.length > 1000 then throw("region-open too big")
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
                            fences := Cons((region-point, neigh), fences)
                    closed := closed.insert(region-point-n)
            val fence-set = fences.hash-set-seeded(7.int64)
            val sides = fences.flatmap(fn((p1, p2)) [(p1 + (1,0), p2 + (1,0)), (p1 + (0,1), p2 + (0,1))])
                .foldl(fence-set) fn(fence-set-acc, fence)
                    if fence-set-acc.contains(fence) then fence-set-acc.remove(fence)
                    else fence-set-acc
                .length
            log(sides.show)
            cost := cost + area * sides

    println("Part 2: " ++ cost.show)



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
