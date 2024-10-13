# Julia script that turns a word list into a Zig StaticStringMap

words = split(readline("assets/eff.txt"),";")
depth = 2
data = Dict{String,Set{String}}()
global data

for w in words 
    for i = 1:length(w)
        from = w[max(i-depth,1):i-1]
        to = w[i:min(i+depth-1,length(w))]
        if from == to
            continue
        end
        if !(from in keys(data))
            data[from] = Set{String}()
        end
       push!(data[from], to)
    end
end

V = [(k, join(filter(!=(""),collect(v)|>sort),";")) for (k,v) in data]
V = V[sortperm(V)]
open("src/lib.zig", "w") do io 
println(io,"const std = @import(\"std\");
const string = []const u8;
pub const map = std.StaticStringMap([]const string).initComptime(.{")
for v in V
    toks = split(v[2],";");
    jt = "\""*join(toks,"\", \"")*"\""
    println(io,"   .{\"$(v[1])\", &[_]string{$(jt)}},")
end
println(io,"});
")
end