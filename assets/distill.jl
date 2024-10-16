# Julia script that turns a word list into a Zig arrays
words = split(readline("assets/eff.txt"), ";")

function model(w)
    vowels = collect("aeiouy")
    consonants = filter(x -> x ∉ vowels, 'a':'z')
    s = ""
    for c in w
        s *= c in vowels ? 'v' : 'c'
    end
    s
end

mpm = ""
while length(mpm) < 5
    A = filter(words) do w
        all(z -> z[1] == z[2], zip(mpm * "c", model(w)))
    end
    B = filter(words) do w
        all(z -> z[1] == z[2], zip(mpm * "v", model(w)))
    end
    if length(A) > length(B)
        mpm *= "c"
    end
    if length(A) < length(B)
        mpm *= "v"
    end
    if length(A) == length(B)
        mpm *= mpm[end] == 'c' ? "v" : "c"
    end
end

mpm
a_c = Set{String}()
a_v = Set{String}()
a_cc = Set{String}()
a_tail = Set{String}()

function zush!(a, b)
    if 'y' ∉ b
        push!(a, b)
    end
end
for w in words
    if !(all(x -> x[1] == x[2], zip(model(w), mpm)) && length(w) >= 5)
        continue
    end
    zush!(a_c, w[1] * "")
    zush!(a_v, w[2] * "")
    zush!(a_cc, w[3:4] * "")
    zush!(a_tail, w[5:end] * "")
end

log2(length(a_c) * length(a_v) * length(a_cc) * length(a_tail))

open("src/lib.zig", "w") do io
    fmtp(name, cont) = "pub const $name = [_]string{\"" * join(collect(cont) |> sort, "\", \"") * "\"};"
    println(io, "pub const string = []const u8;")
    println(io, fmtp("a_c", a_c))
    println(io, fmtp("a_v", a_v))
    println(io, fmtp("a_cc", a_cc))
    println(io, fmtp("a_tail", a_tail))
end
run(`zig fmt src/`)
