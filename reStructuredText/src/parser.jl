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
const Buffer = Vector{String}
#const Manipulation = Union{Pair, Nothing}
const Children = Tuple

function parse(text:: AbstractString, source="")
    #doc = Node{:document}([], [])
    doc_children = []
    initial_state = State(:body)

    context = Context(:state => initial_state, :buffer => Buffer())
    for line in preparse(text)
        @info "line: $line"
        context, children = parseline(line, context)
        @debug "context: $context"
        isempty(children) || push!(doc_children, children...)
    end

    # TODO: manipulation should be Tuple or Array

    context, children = eof(context)
    @debug "context: $context"
    isempty(children) || push!(doc_children, children...)
    return Node{:document}([], doc_children)
end

#eof(context) :: Tuple{Context, Manipulation} = eof(context[:state], context)
#parseline(line, context) :: Tuple{Context, Manipulation} = parseline(context[:state], line, context)
eof(context) :: Tuple{Context, Children} = eof(context[:state], context)
parseline(line, context) :: Tuple{Context, Children} = parseline(context[:state], line, context)

include("parseline.jl")
include("parseline_paragraph.jl")

include("quickspec.jl")

macro p(text) :(println($text); parse($text)) end
