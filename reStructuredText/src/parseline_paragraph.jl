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
        @debug "paragraph -- line empty"
        # build a paragraph node
        @assert length(context[:buffer]) >= 2
        return buildparagraph(context)

    elseif startswith(line, ' ')
        @debug "paragraph -- line indent"
        # unexpected indentation ...

        # build a paragraph node
        @assert length(context[:buffer]) >= 2
        context, manipulation_1 = buildparagraph(context)

        # build a system_message node with error message
        ()

        # case 1: Body.indent → ... blockquote
        # case 2: literalblock
        context, manipulation_2 = parseline(line, context)
        return context, (manipulation_1, manipulation_2)

    else
        @debug "paragraph -- line reading"
        @assert length(context[:buffer]) >= 2
        # not finished yet
        push!(context[:buffer], line)
        return context, nothing
    end

function buildparagraph(context)
    # case 1: paragraph → Body.blank (due to `isempty(line)`)
    # case 2: paragraph → literalblock (due to double colons) → Body.*

    # question: the next state of literalblock is always Body?
    lastline = last(context[:buffer])
    if lastline == "::"
        @debug "next literalblock? -- double colons line"
        buffer = context[:buffer][1:end-1]
        next_state = State(:literalblock)
    elseif endswith(lastline, " ::")
        @debug "next literalblock? -- double colons tailing"
        buffer = [context[:buffer][1:end-1]..., rstrip(lastline)]
        next_state = State(:literalblock)
    elseif !isnothing(match(r"(?<!\\)(\\\\)*::$", lastline))
        @debug "next literalblock? -- double colons tailing without space"
        buffer = [context[:buffer][1:end-1]..., lastline[1:end-1]]
        next_state = State(:literalblock)
    else
        @debug "next literalblock? -- not"
        buffer = context[:buffer]
        next_state = State(:body)
    end

    paragraph = Node{:paragraph}([], buffer)
    context[:buffer] = []
    context[:state] = next_state
    manipulation = context[:doc] => paragraph
    return context, manipulation
end
