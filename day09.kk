
import std/os/file
import std/os/path

val log-enabled = False
val input-filename = "input/d09.txt"

effect fun log(msg: string) : ()

fun main()
    with fun log(msg)
        if log-enabled then println(msg)

    val input = parse-input(read-text-file(path(input-filename)))

    part1(input)
    //part2(input)

fun parse-input(input: string) : <exn,log> (list<int>, list<int>)
    val Cons(file0, rest) = input.trim.list
    val file0-n = (file0 - '0').int
    val result = parse-input-acc(rest, 1, replicate(0, file0-n), [])
    log("Files: " ++ result.fst.show)
    log("Free: " ++ result.snd.show)
    result

fun parse-input-acc(chars: list<char>, next-id: int, files-acc: list<int>, free-acc: list<int>) : <exn,log> (list<int>, list<int>)
    match chars
        Nil -> (files-acc.reverse, free-acc.reverse)
        Cons(free, Cons(file, rest)) ->
            val file-n = (file - '0').int
            val free-n = (free - '0').int
            parse-input-acc(rest, next-id + 1, replicate(next-id, file-n) ++ files-acc, Cons(free-n, free-acc))

effect dual-stack
    fun popl() : maybe<int>
    fun popr() : maybe<int>
    fun peekl() : maybe<int>

fun run-with-stack(stack: vector<int>, action: () -> <dual-stack,pure|e> ()) : <pure|e> ()
    var l := 0
    var r := stack.length - 1
    with handler
        fun popl()
            if l <= r then
                val result = stack.at(l).unjust
                l := l + 1
                Just(result)
            else Nothing
        fun popr()
            if l <= r then
                val result = stack.at(r).unjust
                r := r - 1
                Just(result)
            else Nothing
        fun peekl()
            if l <= r then
                val result = stack.at(l).unjust
                Just(result)
            else Nothing
    action()

fun part1((files, free): (list<int>, list<int>))
    var result := Nil
    var free-acc := free
    var total := 0
    var loc := 0
    run-with-stack(files.vector)
        while { peekl() != Nothing }
            val Just(id) = peekl()
            println(total)
            while { peekl() == Just(id) }
                total := total + (popl().unjust * loc)
                loc := loc + 1
            val n = free-acc.head.unjust
            free-acc := free-acc.tail
            repeat(n)
                popr().map fn(id')
                    total := total + (id' * loc)
                    loc := loc + 1
                    ()
                ()

    println("Part 1: " ++ total.show)
