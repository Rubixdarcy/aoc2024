import std/os/file
import std/os/path

fun parse-reports(input: string) : exn list<list<int>>
    with line <- input.split("\n").filter(is-notempty).map
    line.split(" ").map(fn(n) n.parse-int.unjust)


fun part1(input: string)
    val reports = parse-reports(input)
    val result = reports
        .filter fn(r)
            val (lo, hi) = r
                .zipwith(r.tail, fn(a, b) b - a)
                .foldl((100, -100)) fn((lo, hi), n)
                    (min(lo, n), max(hi, n))
            (hi >= 1 && hi < 4 && lo > 0) || (lo <= -1 && lo > -4 && hi < 0)
        .length
    println("Part 1: " ++ result.show)
            


fun main()
    val input = read-text-file(path("input/d02.txt"))
    part1(input)
