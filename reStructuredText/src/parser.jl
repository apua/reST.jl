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

function parse(text:: AbstractString)
    return Node{:document}([], nestedparse(preparse(text)))
end

function nestedparse(lines)
    all_children = []
    initial_state = State(:body)

    context = Context(:state => initial_state, :buffer => Buffer())
    for line in lines
        @info "(nestedparse) line: $line"
        context, children = parseline(line, context)
        @debug "context: $context"
        isempty(children) || push!(all_children, children...)
    end

    context, children = eof(context)
    @debug "context: $context"
    isempty(children) || push!(all_children, children...)
    return all_children
end

#eof(context) :: Tuple{Context, Manipulation} = eof(context[:state], context)
#parseline(line, context) :: Tuple{Context, Manipulation} = parseline(context[:state], line, context)
eof(context) :: Tuple{Context, Children} = eof(context[:state], context)
parseline(line, context) :: Tuple{Context, Children} = parseline(context[:state], line, context)

include("parseline.jl")
include("parseline_paragraph.jl")

include("quickspec.jl")

#macro p(text) :(println($text); parse($text)) end
macro p(text) :(println($text); s = parse($text); t = $text; run(`python poc.py "$t"`); print(s)) end
macro d(text) :(t = $text; run(`python poc.py "$t"`); return) end
