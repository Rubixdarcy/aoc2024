
import std/os/file
import std/os/path
import std/core/sslice

alias mask-list = (list<bool>, list<bool>, list<bool>, list<bool>)

value struct bounds { width: int; height: int }
value struct point { x: int; y: int }

effect fun log(msg: string) : ()

val direction-list = [
    (1, 0), // Right
    (1, 1), // Down Right
    (0, 1), // Down
    (-1, 1), // Down Left
    (-1, 0), // Left
    (-1, -1), // Up Left
    (0, -1), // Up
    (1, -1), // Up Right
]

fun contains(b: bounds, p: point) : bool
    val Bounds(w, h) = b
    val Point(x, y) = p
    0 <= x && x < w && 0 <= y && y < h

fun show(p: point)
    "Point" ++ (p.x, p.y).show

fun parse-wordsearch(input: string) : pure (string, bounds)
    val lines: list<string> = input.split("\n").filter(is-notempty)

    val width = lines.head.unjust.count
    val height = lines.length

    (lines.join, Bounds(width, height))

fun build-masks-acc(input: sslice, (x, m, a, s): mask-list) : div mask-list
    match input.next
        Just ((c, input')) -> build-masks-acc(input', (
            Cons(c == 'X', x), Cons(c == 'M', m), Cons(c == 'A', a), Cons(c == 'S', s)
        ))
        Nothing -> (x.reverse, m.reverse, a.reverse, s.reverse)

fun part1(input: string)
    val (text, word-bounds) = parse-wordsearch(input)
    val Bounds(width, height) = word-bounds

    val (x, m, a, s) = build-masks-acc(text.slice, (Nil, Nil, Nil, Nil))

    val total = direction-list
        .map fn((dx, dy))
            val offset = width * dy + dx
            val offset-max = abs(offset * 3)
            val base = if offset > 0 then 0 else offset-max
            var x' := x.drop(base)
            var m' := m.drop(base + offset)
            var a' := a.drop(base + offset * 2)
            var s' := s.drop(base + offset * 3)

            var dir-total := 0
            for(0, width * height - offset-max - 1) fn(i)
                if (x'.head.unjust && m'.head.unjust && a'.head.unjust && s'.head.unjust) then
                    val (py, px) = divmod(i, width)
                    val sign = if offset > 0 then 1 else -1
                    val start = Point(px, py)
                    val end = Point(px + 3 * dx * sign, py + 3 * dy * sign)
                    if contains(word-bounds, start) && contains(word-bounds, end) then
                        log("Found at " ++ i.show ++ " " ++ start.show)
                        dir-total := dir-total + 1
                    else
                        log("Bounds failure at " ++ i.show ++ " " ++ start.show ++ " " ++ end.show)
                x' := x'.tail
                m' := m'.tail
                a' := a'.tail
                s' := s'.tail
            log("Dir total " ++ (dx, dy).show ++ " = " ++ dir-total.show)
            dir-total
        .sum

    println("Part 1: " ++ total.show)

fun part2(input: string)
    val (text, word-bounds) = parse-wordsearch(input)
    val Bounds(width, height) = word-bounds

    val (_x, m, a, s) = build-masks-acc(text.slice, (Nil, Nil, Nil, Nil))

    val dirs = [(False, False), (False, True), (True, False), (True, True)]

    val total = dirs
        .map fn((left-reversed, right-reversed))

            var tl := (if left-reversed then s else m)
            var tr := (if right-reversed then s else m).drop(2)
            var mid := a.drop(width + 1)
            var bl := (if right-reversed then m else s).drop(width * 2)
            var br := (if left-reversed then m else s).drop(width * 2 + 2)

            var dir-total := 0
            for(0, width * height - (width * 2 + 2) - 1) fn(i)
                if (tl.head.unjust && tr.head.unjust && mid.head.unjust && bl.head.unjust && br.head.unjust) then
                    val (py, px) = divmod(i, width)
                    val start = Point(px, py)
                    val end = Point(px + 2, py + 2)
                    if contains(word-bounds, end) then
                        log("Found at " ++ i.show ++ " " ++ start.show)
                        dir-total := dir-total + 1
                    else
                        log("Bounds failure at " ++ i.show ++ " " ++ start.show ++ " " ++ end.show)
                tl := tl.tail
                tr := tr.tail
                mid := mid.tail
                bl := bl.tail
                br := br.tail
            log("Dir total " ++ (left-reversed, right-reversed).show ++ " = " ++ dir-total.show)
            dir-total
        .sum

    println("Part 2: " ++ total.show)


fun main()
    val log-enabled = False
    with fun log(msg)
        if log-enabled then println(msg)

    val input = read-text-file(path("input/d04.txt"))

    part1(input)
    part2(input)
