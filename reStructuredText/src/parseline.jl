macro match(regex)
    esc(:((matched = match($regex, line)) !== nothing))
end

eof(state::State{:body}, context) =
    begin
        @info "docutils method -> Body.eof"
        return context, nothing
    end

eof(state::State{:text}, context) =
    if !isempty(context[:buffer])
        @info "docutils method -> Text.eof"
        @assert length(context[:buffer]) == 1
        context, paragraph = build_paragraph(context)
        context[:state] = State(:body)
        manipulation = context[:doc] => paragraph
        return context, manipulation
    end

parseline(state::State{:body}, line, context) =
    if isempty(line)
        @info "docutils method -> Body.blank"
        @assert length(context[:buffer]) == 0
        manipulation = nothing
        return context, manipulation
    elseif @match r"^ +"
        @info "docutils method -> Body.indent"
    elseif @match r"^[-+*•‣⁃]( +|$)"
        @info "docutils method -> Body.bullet"
    elseif @match r"^((?P<parens>\(([0-9]+|[a-z]|[A-Z]|[ivxlcdm]+|[IVXLCDM]+|#)\))|(?P<rparen>([0-9]+|[a-z]|[A-Z]|[ivxlcdm]+|[IVXLCDM]+|#)\))|(?P<period>([0-9]+|[a-z]|[A-Z]|[ivxlcdm]+|[IVXLCDM]+|#)\.))( +|$)"
        @info "docutils method -> Body.enumerator"
    elseif @match r"^:(?![: ])([^:\\]|\\.)*(?<! ):( +|$)"
        @info "docutils method -> Body.field_marker"
    elseif @match r"^((-|\+)[a-zA-Z0-9]( ?([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?|(--|/)[a-zA-Z0-9][a-zA-Z0-9_-]*([ =]([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?)(, ((-|\+)[a-zA-Z0-9]( ?([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?|(--|/)[a-zA-Z0-9][a-zA-Z0-9_-]*([ =]([a-zA-Z][a-zA-Z0-9_-]*|<[^<>]+>))?))*(  +| ?$)"
        @info "docutils method -> Body.option_marker"
    elseif @match r"^>>>( +|$)"
        @info "docutils method -> Body.doctest"
    elseif @match r"^\|( +|$)"
        @info "docutils method -> Body.line_block"
    elseif @match r"^\+-[-+]+-\+ *$"
        @info "docutils method -> Body.grid_table_top"
    elseif @match r"^=+( +=+)+ *$"
        @info "docutils method -> Body.simple_table_top"
    elseif @match r"^\.\.( +|$)"
        @info "docutils method -> Body.explicit_markup"
    elseif @match r"^__( +|$)"
        @info "docutils method -> Body.anonymous"
    elseif @match r"^([!-/:-@[-`{-~])\1* *$"
        @info "docutils method -> Body.line"
    else # @match r""
        @info "docutils method -> Body.text"
        context[:state] = State(:text)
        push!(context[:buffer], line)
        manipulation = nothing
        return context, manipulation
    end

parseline(state::State{:text}, line, context) =
    if isempty(line)
        @info "docutils method -> Text.blank"
        @assert length(context[:buffer]) == 1
        context, paragraph = build_paragraph(context)
        context[:state] = State(:body)
        manipulation = context[:doc] => paragraph
        return context, manipulation
    elseif @match r"^ +"
        @info "docutils method -> Text.indent"
        @assert length(context[:buffer]) == 1
    elseif @match r"^([!-/:-@[-`{-~])\1* *$"
        @info "docutils method -> Text.underline"
        @assert length(context[:buffer]) == 1
    else # @match r""
        @info "docutils method -> Text.text"
        @assert length(context[:buffer]) == 1
        push!(context[:buffer], line)
        context[:state] = State(:paragraph)
        return context, nothing
    end
