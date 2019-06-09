function parse_rst(iter_lines)

    doctree = Node{:document}([:source => "test data"], [])
    parent = doctree
    context = ()

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
            context :: Tuple,
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
        (line_number < 5) || break
    end

    return doctree
end


function check_line(context, state, line)
    @debug "check_line: line -> $line"

# :state:`Body` may happen only when `context` is empty
if isempty(context)
    @debug ":state:`Body` (?)"
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
else
    @debug ":state:`Text` (?)"
    if false
    elseif nothing != (matched = match(r"^$", line))  # "blank" inherits `statemachine.StateWS.ws_patterns`
        @debug "match: blank"
        # export context as a paragraph node
        child = Node{:paragraph}([], collect(context))
        return parent, parent => child, ()
    elseif nothing != (matched = match(r"^ +$", line))  # "indent" inherits `statemachine.StateWS.ws_patterns`
        
    elseif nothing != (matched = match(r"([!-/:-@[-`{-~])\1* *$", line))  # "underline" is `Body.patterns['line']`
        
    elseif nothing != (matched = match(r"", line))  # text

    end
end

end
