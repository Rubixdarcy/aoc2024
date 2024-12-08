import std/os/file
import std/os/path

val log-enabled = False
val input-filename = "input/d08.txt"

effect fun log(msg: string) : ()

fun main()
    with fun log(msg)
        if log-enabled then println(msg)

    val input = parse-input(read-text-file(path(input-filename)))

    part1(input)

fun parse-input(input: string) : <exn,log> (vector<list<(int, int)>>, (int, int))
    val result-mut = vector-init(256, fn(_i) ref(Nil))

    val rows = input.split("\n").filter(is-notempty)
    val height = rows.length
    val width = rows.head.unjust.count

    rows.foreach-indexed fn(y, row)
        row.list.foreach-indexed fn(x, c)
            if c != '.' then
                val l = result-mut.at(c.int).unjust
                l := Cons((x, y), !l)

    log("Width: " ++ width.show)
    log("Height: " ++ height.show)
    (result-mut.map(fn(r) !r), (width, height))

fun in-bounds((x, y): (int, int), (width, height): (int, int)) : bool
    0 <= x && x < width && 0 <= y && y < height

fun choose2(l: list<a>) : list<(a, a)>
    with l' <- splits(l).flatmap
    val (x, xs) = l'
    xs.map(fn(x') (x, x'))


fun splits(l: list<a>) : list<(a, list<a>)>
    splits-acc(l, Nil)

fun splits-acc(l: list<a>, acc: list<(a, list<a>)>) : list<(a, list<a>)>
    match l
        Nil -> acc
        Cons(x, xs) -> splits-acc(xs, Cons((x, xs), acc))

fun (+)((x1, y1): (int, int), (x2, y2): (int, int)) : (int, int)
    (x1 + x2, y1 + y2)

fun (-)((x1, y1): (int, int), (x2, y2): (int, int)) : (int, int)
    (x1 - x2, y1 - y2)

fun sorted-key(xs: list<a>, key: (a) -> pure int) : pure list<a>
    match xs
        Nil -> Nil
        Cons(x0, Nil) -> Cons(x0, Nil)
        Cons(x0, xs') ->
            val x0-key = x0.key
            val (le, gt) = xs'.partition(fn(x) x.key <= x0-key)
            le.sorted-key(key) ++ [x0] ++ gt.sorted-key(key)

 // Requires input list is sorted
fun unique(l: list<a>, ?(==) : (a, a) -> bool) : <div> list<a>
    match l
        Nil -> Nil
        Cons(x0, l') ->
            var x := x0
            var result := [x0]
            l'.foreach fn(x')
                if !(x == x') then
                    result := Cons(x', result)
                    x := x'
            result


fun part1((antennae, bounds): (vector<list<(int, int)>>, (int, int)))
    val result = antennae.list
        .flatmap fn(locs)
            with pair <- locs.choose2.flatmap
            val (a, b) = pair
            [a + (a - b), b + (b - a)].filter(fn(p) p.in-bounds(bounds))
        .sorted-key(fn((x, y)) x * 1000 + y)
        .unique

    log("Result: " ++ result.show)
    val total = result.length
    println("Part 1: " ++ total.show)




