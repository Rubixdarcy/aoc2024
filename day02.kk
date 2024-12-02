import std/os/file
import std/os/path

fun parse-reports(input: string) : exn list<list<int>>
    with line <- input.split("\n").filter(is-notempty).map
    line.split(" ").map(fn(n) n.parse-int.unjust)

fun is-safe(report: list<int>) : bool
    val (lo, hi) = report
        .zipwith(report.tail, fn(a, b) b - a)
        .foldl((100, -100)) fn((lo, hi), n)
            (min(lo, n), max(hi, n))
    (hi >= 1 && hi < 4 && lo > 0) || (lo <= -1 && lo > -4 && hi < 0)

fun part1(input: string)
    val reports = parse-reports(input)
    val result = reports.filter(is-safe).length
    println("Part 1: " ++ result.show)

// Really inefficient, but most convenient approach
fun delete-index(l: list<a>, i: int) : list<a>
    val (left, right) = l.split(i)
    left ++ right.tail
            
fun part2(input: string)
    val reports = parse-reports(input)
    val result = reports
        .filter fn(report)
            val result = for-while(report.length) fn(i)
                if is-safe(report.delete-index(i)) then Just (())
                else Nothing
            result.is-just
        .length
    println("Part 2: " ++ result.show)

fun main()
    val input = read-text-file(path("input/d02.txt"))
    part1(input)
    part2(input)
