import std/text/regex
import std/os/file
import std/os/path

fun part1(input: string)
    var matches := regex(r"mul\(([\d]{1,3}),([\d]{1,3})\)").exec-all(input)
    matches := matches.tail
    var result := 0
    while { !matches.is-empty }
        match matches
            Cons (Cons(_, Cons(a, Cons(b, _))), Cons(_, rest)) ->
                result := result + a.string.parse-int.unjust * b.string.parse-int.unjust
                matches := rest
            _ -> throw("unreachable")
    println("Part 1: " ++ result.show)


fun part2(input: string)
    var matches := regex(r"do\(\)|don't\(\)|mul\(([\d]{1,3}),([\d]{1,3})\)").exec-all(input)
    matches := matches.tail
    var result := 0
    var enabled := True
    while { !matches.is-empty }
        match matches
            Cons (Cons(all, Cons(a, Cons(b, _))), Cons(_, rest)) ->
                matches := rest
                val all-s = all.string
                if all-s == "do()" then
                    enabled := True
                elif all-s == "don't()" then
                    enabled := False
                elif enabled then
                    result := result + a.string.parse-int.unjust * b.string.parse-int.unjust
            _ -> throw("unreachable")
    println("Part 2: " ++ result.show)


fun main()
    val input = read-text-file(path("input/d03.txt"))
    part1(input)
    part2(input)

