
import std/os/file
import std/os/path

val log-enabled = True
val input-filename = "input/d09.txt"

effect fun log(msg: string) : ()

fun main()
    with fun log(msg)
        if log-enabled then println(msg)

    val input = parse-input(read-text-file(path(input-filename)))
    part1(input)

    val input2 = parse-input-v2(read-text-file(path(input-filename)))
    part2(input2)

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




fun parse-input-v2(input: string) : <exn,log,st<h>> vector<ref<h,int>>
    val input' = input.trim.list.map(fn(c) (c - '0').int)
    val vec = vector-init(input'.sum, fn(_i) ref(-1))
    var id := 0
    var is-file := True
    var i := 0
    list/foreach(input') fn(n)
        if is-file then
            for(i, i + n - 1) fn(j)
                val r = vec.at(j).unjust
                r := id
                ()
            id := id + 1
        i := i + n
        is-file := !is-file
    vec

fun seek(input: vector<ref<h,int>>, id: int) : <exn,read<h>,log> (int, int)
    var found := False
    var first := -1
    var i := 0
    val result = input.foreach-while fn(n)
        if found then
            if !n != id then
                return Just((first, i - first))
        else
            if !n == id then
                found := True
                first := i
        i := i + 1
        Nothing

    match result
        Just(x) -> x
        Nothing -> (first, input.length - first)

fun delete(input: vector<ref<h,int>>, (i, length): (int, int)) : <exn,st<h>> ()
    for(i, i + length - 1) fn(j)
        val elem = input.at(j).unjust
        elem := -1

fun place(input: vector<ref<h,int>>, id: int, length: int, start-limit: int) : <exn,st<h>> bool
    var i := 0
    var first := -1
    var free-length := 0

    val result = input.foreach-while() fn(n-ref)
        val n = !n-ref
        if n == -1 then
            if first == -1 then
                first := i
            free-length := free-length + 1
            if free-length == length then
                // fill in
                for(first, first + length - 1) fn(j)
                    val m-ref = input.at(j).unjust
                    m-ref := id
                return Just(True)
        else
            first := -1
            free-length := 0
        i := i + 1

        if i == start-limit then
            // we've reached the original location fail the move
            Just(False)
        else
            Nothing

    match result
        Just(x) -> x
        Nothing -> throw("Unable to place ID: " ++ id.show)


fun part2(input: vector<ref<h,int>>) : <exn, st<h>,console,log> ()
    var max-id := 0
    input.foreach fn(n-ref)
        if !n-ref > max-id then
            max-id := !n-ref

    for(0, max-id - 1) fn(x)
        val id = max-id - x

        val (i, length) = seek(input, id)
        val placed = place(input, id, length, i)
        if placed then
            delete(input, (i, length))


    val result = input.list
        .map-indexed(fn(i, id) if !id != -1 then i * !id else 0)
        .sum

    println("Part 2: " ++ result.show)
