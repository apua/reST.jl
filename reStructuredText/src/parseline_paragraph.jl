eof(state::State{:paragraph}, context) =
    begin
        @info "paragraph.eof"
        @assert length(context[:buffer]) >= 2
        context, manipulation = buildparagraph(context)
        context, _ = eof(context)
        return context, manipulation
    end

parseline(state::State{:paragraph}, line, context) =
    if isempty(line)
        # build a paragraph node
        @assert length(context[:buffer]) >= 2
        return buildparagraph(context)
    elseif startswith(line, ' ')
        # unexpected indentation ...
        #   ... build a paragraph node
        #   and build a system_message node with error message
        @assert length(context[:buffer]) >= 2
        return buildparagraph(context)
    else
        @assert length(context[:buffer]) >= 2
        # not finished yet
        push!(context[:buffer], line)
        return context, nothing
    end

buildparagraph(context) =
    begin
        paragraph = Node{:paragraph}([], context[:buffer])
        manipulation = context[:doc] => paragraph
        context[:buffer] = []
        context[:state] = State(:body)
        return context, manipulation
    end
