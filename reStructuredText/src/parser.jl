text = """

    Abstract
             
    H1 Title
    ========

    Para 1,
    conti *em* ... **strong!!** and
    the end of para::

        some literal
        and literal

    - item 1

      - item 2
      - item 3

    ~~~~

    And more...
    """

# TODO: require line number information
# TODO: support `line isa SubString` which might be efficient
lines = pre_parse(text)

# use macro to be extensible
macro next_line(lines)
    :(r = iterate($lines); r === nothing ? nothing : first(r))
end

function parse_rst(lines)
    # This function just initializes parsing
    doctree = Node{:document}([:source => "test data"], [])
    context = ()
    parse_rst_nested(lines, doctree, context)
end

# similar with `RSTState.nested_parse`
function parse_rst_nested(lines, doctree, context)
    # Iterate line by line.
    # Extend funtionality in `@next_line`.
    # May need some post-operation while EOF.

    state = :body
    while true
        line = @next_line lines
        line === nothing && break
        state, result, context = check_line(state, line, context)
    end
end

struct State{S<:Symbol} end
State(x) = State{x}()

function check_line(state::State{:body}, line, contenxt)
    if false
        # StateMachine.check_line: state="Body",
        # transitions=['blank', 'indent', 'bullet', 'enumerator', 'field_marker', 'option_marker',
        #              'doctest', 'line_block', 'grid_table_top', 'simple_table_top', 'explicit_markup',
        #              'anonymous', 'line', 'text'].
        #
        # StateMachine.check_line: Matched transition "blank" in state "Body".
    elseif nothing != (matched = match(r"^$", line))  # "blank" inherits `statemachine.StateWS.ws_patterns`
        @debug "match: blank"
        return parent, nothing, context
    elseif nothing != (matched = match(r"^ +$", line))  # "indent" inherits `statemachine.StateWS.ws_patterns`

    elseif nothing != (matched = match(r"^[-+*•‣⁃]( +|$)", line))  # bullet

    elseif nothing != (matched = match(r"((?P<parens>\(([0-9]+|[a-z]|[A-Z]|[ivxlcdm]+|[IVXLCDM]+|#)\))|(?P<rparen>([0-9]+|[a-z]|[A-Z]|[ivxlcdm]+|[IVXLCDM]+|#)\))|(?P<period>([0-9]+|[a-z]|[A-Z]|[ivxlcdm]+|[IVXLCDM]+|#)\.))( +|$)", line))  # enumerator

    elseif nothing != (matched = match(r":(?![: ])([^:\\]|\\.)*(?<! ):( +|$)", line))  # field_marker

    elseif nothing != (matched = match(r"((-|\+)[a-zA-Z0-9]( ?([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?|(--|/)[a-zA-Z0-9][a-zA-Z0-9_-]*([ =]([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?)(, ((-|\+)[a-zA-Z0-9]( ?([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?|(--|/)[a-zA-Z0-9][a-zA-Z0-9_-]*([ =]([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?))*(  +| ?$)", line))  # option_marker

    elseif nothing != (matched = match(r">>>( +|$)", line))  # doctest

    elseif nothing != (matched = match(r"\|( +|$)", line))  # line_block

    elseif nothing != (matched = match(r"\+-[-+]+-\+ *$", line))  # grid_table_top

    elseif nothing != (matched = match(r"=+( +=+)+ *$", line))  # simple_table_top

    elseif nothing != (matched = match(r"\.\.( +|$)", line))  # explicit_markup

    elseif nothing != (matched = match(r"__( +|$)", line))  # anonymous

    elseif nothing != (matched = match(r"([!-/:-@[-`{-~])\1* *$", line))  # line

    elseif nothing != (matched = match(r"", line))  # text
        @debug "match: text"
        # if could be the first line of a paragraph, or a section title
        return parent, nothing, (line,)
    else
        # `state.no_match(context, transitions)`
    end
end
