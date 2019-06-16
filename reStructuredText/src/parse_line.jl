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

text = """
aaaa
bbbb
cccc
"""

macro match(regex)
    esc(:((matched = match($regex, line)) !== nothing))
end

parseline(line, context) = parseline(context[:state], line, context)

parseline(state::State{:body}, line, context) =
    if     @match r"^$"
        # `Body.blank`
    elseif @match r"^ +$"
        # `Body.indent`
    elseif @match r"^[-+*•‣⁃]( +|$)"
        # `Body.bullet`
    elseif @match r"^((?P<parens>\(([0-9]+|[a-z]|[A-Z]|[ivxlcdm]+|[IVXLCDM]+|#)\))|(?P<rparen>([0-9]+|[a-z]|[A-Z]|[ivxlcdm]+|[IVXLCDM]+|#)\))|(?P<period>([0-9]+|[a-z]|[A-Z]|[ivxlcdm]+|[IVXLCDM]+|#)\.))( +|$)"
        # `Body.enumerator`
    elseif @match r"^:(?![: ])([^:\\]|\\.)*(?<! ):( +|$)"
        # `Body.field_marker`
    elseif @match r"^((-|\+)[a-zA-Z0-9]( ?([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?|(--|/)[a-zA-Z0-9][a-zA-Z0-9_-]*([ =]([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?)(, ((-|\+)[a-zA-Z0-9]( ?([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?|(--|/)[a-zA-Z0-9][a-zA-Z0-9_-]*([ =]([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?))*(  +| ?$)"
        # `Body.option_marker`
    elseif @match r"^>>>( +|$)"
        # `Body.doctest`
    elseif @match r"^\|( +|$)"
        # `Body.line_block`
    elseif @match r"^\+-[-+]+-\+ *$"
        # `Body.grid_table_top`
    elseif @match r"^=+( +=+)+ *$"
        # `Body.simple_table_top`
    elseif @match r"^\.\.( +|$)"
        # `Body.explicit_markup`
    elseif @match r"^__( +|$)"
        # `Body.anonymous`
    elseif @match r"^([!-/:-@[-`{-~])\1* *$"
        # `Body.line`
    else # @match r""
        # `Body.text`
        context[:state] = State(:text)
        push!(context[:buffer], line)
        manipulation = nothing
        (context, manipulation)
    end

parseline(state::State{:text}, line, context) =
    if     @match r"^$"
        # `Text.blank`
    elseif @match r"^ +$"
        # `Text.indent`
    elseif @match r"^([!-/:-@[-`{-~])\1* *$"
        # `Text.underline`
    else # @match r""
        # `Text.text`
        context[:state] = State(:text)
        manipulation = nothing
        (context, manipulation)
    end
