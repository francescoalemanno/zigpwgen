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
pub const map = std.StaticStringMap([]const u8).initComptime(.{")
for v in V
    println(io,".{\"",v[1],"\"",", \";",v[2],";\"},")
end
println(io,"});
")
end