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
    if !(all(x -> x[1] == x[2], zip(model(w), "cvccvccvccvccvccvccvc")) && length(w) >= 6)
        continue
    end
    zush!(a_c, w[1] * "")
    zush!(a_v, w[2] * "")
    zush!(a_cc, w[3:4] * "")
    zush!(a_tail, w[5:end] * "")
end
log2(length(a_c) * length(a_v) * length(a_cc) * length(a_tail))



open("src/lib.zig", "w") do io
    fmtp(name, cont) = "pub const $name = [_]string{\"" * join(collect(cont)|>sort, "\", \"") * "\"};"
    println(io, "pub const string = []const u8;")
    println(io, fmtp("a_c", a_c))
    println(io, fmtp("a_v", a_v))
    println(io, fmtp("a_cc", a_cc))
    println(io, fmtp("a_tail", a_tail))
end

#=

# Julia script that turns a word list into a Zig StaticStringMap

words = split(readline("assets/eff.txt"), ";")

depth = 2
data = Dict{String,Set{String}}()
global data

for w in words
    for i = 1:length(w)
        from = w[max(i - depth, 1):i-1]
        to = w[i:min(i + depth - 1, length(w))]
        if from == to
            continue
        end
        if !(from in keys(data))
            data[from] = Set{String}()
        end
        push!(data[from], to)
    end
end

V = [(k, join(filter(!=(""), collect(v) |> sort), ";")) for (k, v) in data]
V = V[sortperm(V)]
open("src/lib.zig", "w") do io
    println(
        io,
        "const std = @import(\"std\");
pub const string = []const u8;
pub const chain_depth: usize = $(depth);
pub const map = std.StaticStringMap([]const string).initComptime(.{"
    )
    for v in V
        toks = split(v[2], ";")
        jt = "\"" * join(toks, "\", \"") * "\""
        println(io, "   .{\"$(v[1])\", &[_]string{$(jt)}},")
    end
    println(
        io,
        "});
"
    )
end




=#
