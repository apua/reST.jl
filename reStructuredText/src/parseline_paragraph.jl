eof(state::State{:get_paragraph_block}, context) =
    begin
        @info "get_paragraph_block.eof -> Body.eof"
        @assert length(context[:buffer]) >= 2
        context, paragraph = build_paragraph(context)
        context[:state] = State(:body)
        manipulation = context[:doc] => paragraph
        context, _ = eof(context)
        return context, manipulation
    end

parseline(state::State{:get_paragraph_block}, line, context) =
    if isempty(line)
        "build a paragraph node"
        @assert length(context[:buffer]) >= 2
        context, paragraph = build_paragraph(context)
        context[:state] = State(:body)
        manipulation = context[:doc] => paragraph
        return context, manipulation
    elseif startswith(line, ' ')
        "unexpected indentation ..."
        "  ... build a paragraph node"
        "  and build a system_message node with error message"
        @assert length(context[:buffer]) >= 2
        context, paragraph = build_paragraph(context)
        context[:state] = State(:body)
        manipulation = context[:doc] => paragraph
        return context, manipulation
    else
        @assert length(context[:buffer]) >= 2
        "not finished yet"
        push!(context[:buffer], line)
        return context, nothing
    end

"Dump buffer to build paragraph node"
build_paragraph(context) :: Tuple{Context, Node{:paragraph}} =
    begin
        buffer, context[:buffer] = context[:buffer], []
        paragraph = Node{:paragraph}([], buffer)
        return context, paragraph
    end
