struct Node{S}
    attributes
    children
end

Node(symbol::Symbol, xs...) =
    begin
        attributes, children = [], []
        for x in xs push!(x isa Pair ? attributes : children, x) end
        @show attributes, children
        Node{symbol}(attributes, children)
    end

# TODO: represent node attributes sorted by name
# TODO: node attributes needs to be unique
Base.show(io::IO, node::Node{S}, indent=""::AbstractString) where S =
    begin
        print(io, indent, "<$S", (" $k=\"$v\"" for (k, v) in node.attributes)..., ">")

        isempty(indent) && (indent = "\n")
        indent *= "    "
        for child in node.children
            if child isa AbstractString
                print(io, (indent * line for line in split(child, r"^"m))...)
            else
                Base.show(io, child, indent)
            end
        end
    end


@assert Node{:document}(1,[]) != Node{:document}(1,[])

Base.:(==)(ns::Node{S}, nt::Node{T}) where S where T =
    S == T && ns.attributes == nt.attributes && ns.children == nt.children

@assert Node{:document}(1,[]) == Node{:document}(1,[])
