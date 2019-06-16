####    # TODO: require line number information
####    # TODO: support `line isa SubString` which might be efficient
####    #lines = pre_parse(text)
####
####    # use macro to be extensible
####    macro next_line(lines)
####        :(r = iterate($(esc(lines))); r === nothing ? nothing : first(r))
####    end
####
####    function parse_rst(lines)
####        # This function just initializes parsing
####        doctree = Node{:document}([:source => "test data"], [])
####        context = ()
####        parse_rst_nested(lines, doctree, context)
####    end
####
####    struct State{Symbol} end
####    State(x) = State{x}()
####
####    include("check_line.jl")
####
####    # similar with `RSTState.nested_parse`
####    function parse_rst_nested(lines, doctree, context)
####        # Iterate line by line.
####        # Extend funtionality in `@next_line`.
####        # May need some post-operation while EOF.
####
####        state = State(:body)
####        while true
####            line = @next_line lines
####            line === nothing && break
####            @show line
####            state, result, context = check_line(state, line, context)
####            #@show state, result, context
####            result !== nothing && push!(doctree.children, result)
####        end
####        doctree
####    end

###################

const TAB_WIDTH = 8

@doc raw"""
1. `r"[\v\f]" -> " "` not support; behavior of matching `\v` is different with in Python
2. `r"\s+\$" -> ""` done by `split`
3. `r"\t" -> " " x tab_width` done by `replace`
4. `str.splitlines` done by `eachline`

Actually, those ASCII control characters should not appear in reST source today,
it is unnecessary to care about.
"""
preparse(s::AbstractString) = preparse(IOBuffer(s))
preparse(s::IO) = (rstrip(replace(line, "\t" => " " ^ TAB_WIDTH)) for line in eachline(s))

struct State{Symbol}
end

State(x) = State{x}()

const Context = Dict{Symbol, Any}

function parse(text:: AbstractString, source="")
    doc = Node{:document}([:source => source], [])
    initial_state = State(:body)

    context = Context(:doc => doc, :state => initial_state, :buffer => [])
    for line in preparse(text)
        context, manipulation = parseline(line, context)
        @info "line: $line"
        @info "context: $context"
        isnothing(manipulation) || @info "manipulation: $manipulation"
    end
    return doc
end

include("parse_line.jl")
