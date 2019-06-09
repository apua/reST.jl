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
lines = pre_parse_lines(text)
G = pre_parse(text)

function parse_rst(iter_lines)

    doctree = Node{:document}([:source => "test data"], [])
    parent = doctree
    context = []

    # it should read and parse all lines once
    for (line_number, line) in enumerate(iter_lines)
        # provide necessary information to the core, and the core return the
        # information for next operation, for example, appending doctree.
        #
        # Finally, the core is a pure function.
        #
        # As a high readability markup language, it should be sufficient
        # to determine the next step with given line and context information.
        (
            parent,
            appending :: Union{Pair, Nothing},
            context :: Vector,
        ) = check_line(
            doctree = doctree,
            parent = parent,
            context = context,
            line_number = line_number,
            line = line,
        )
        if appending != nothing
            addto, child = appending
            push!(addto.children, child)
        end
        #(line_number < 5) || break
    end

    return doctree
end

function check_line(; doctree, parent, context, line_number, line)
    @show line

if (parent isa Node{:document})
    if false
        # StateMachine.check_line: state="Body",
        # transitions=['blank', 'indent', 'bullet', 'enumerator', 'field_marker', 'option_marker',
        #              'doctest', 'line_block', 'grid_table_top', 'simple_table_top', 'explicit_markup',
        #              'anonymous', 'line', 'text'].
        #
        # StateMachine.check_line: Matched transition "blank" in state "Body".
    elseif nothing != (matched = match(r"^$", line))  # "blank" comes from `statemachine.StateWS.ws_patterns`
        return (parent, nothing, context)
    elseif nothing != (matched = match(r"^ +$", line))  # "indent" comes from `statemachine.StateWS.ws_patterns`
        return (parent, nothing, context)
    elseif nothing != (matched = match(r"^[-+*•‣⁃]( +|$)", line))  # bullet
        return (parent, nothing, context)
    elseif nothing != (matched = match(r"((?P<parens>\(([0-9]+|[a-z]|[A-Z]|[ivxlcdm]+|[IVXLCDM]+|#)\))|(?P<rparen>([0-9]+|[a-z]|[A-Z]|[ivxlcdm]+|[IVXLCDM]+|#)\))|(?P<period>([0-9]+|[a-z]|[A-Z]|[ivxlcdm]+|[IVXLCDM]+|#)\.))( +|$)", line))  # enumerator
        return (parent, nothing, context)
    elseif nothing != (matched = match(r":(?![: ])([^:\\]|\\.)*(?<! ):( +|$)", line))  # field_marker
        return (parent, nothing, context)
    elseif nothing != (matched = match(r"((-|\+)[a-zA-Z0-9]( ?([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?|(--|/)[a-zA-Z0-9][a-zA-Z0-9_-]*([ =]([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?)(, ((-|\+)[a-zA-Z0-9]( ?([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?|(--|/)[a-zA-Z0-9][a-zA-Z0-9_-]*([ =]([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?))*(  +| ?$)", line))  # option_marker
        return (parent, nothing, context)
    elseif nothing != (matched = match(r">>>( +|$)", line))  # doctest
        return (parent, nothing, context)
    elseif nothing != (matched = match(r"\|( +|$)", line))  # line_block
        return (parent, nothing, context)
    elseif nothing != (matched = match(r"\+-[-+]+-\+ *$", line))  # grid_table_top
        return (parent, nothing, context)
    elseif nothing != (matched = match(r"=+( +=+)+ *$", line))  # simple_table_top
        return (parent, nothing, context)
    elseif nothing != (matched = match(r"\.\.( +|$)", line))  # explicit_markup
        return (parent, nothing, context)
    elseif nothing != (matched = match(r"__( +|$)", line))  # anonymous
        return (parent, nothing, context)
    elseif nothing != (matched = match(r"([!-/:-@[-`{-~])\1* *$", line))  # line
        return (parent, nothing, context)
    elseif nothing != (matched = match(r"", line))  # text
        child = Node{:paragraph}([], [line])
        return (parent, parent => child, context)
    else
        # `state.no_match(context, transitions)`
    end

    return (parent, 1=>2, [])
end

end
