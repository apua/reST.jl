function test_paragraph()
    node(symbol, xs::Vector, ys...) = Node{symbol}([xs...], [ys...])
    node(symbol, ys...) = Node{symbol}([], [ys...])
    doc(ys...) = node(:document, ys...)

    test_cases = [
        :emptystring => ( # · → Body.eof
            "",
            doc(),
            ),
        :emptyline1 => ( # · → Body.blank → Body.eof
            "\n",
            doc(),
            ),
        :emptyline2 => ( # · → Body.blank → Body.eof
            "\n\n",
            doc(),
            ),
        :onestring => ( # · → Body.text → Text.eof
            "AAA",
            doc(node(:paragraph, "AAA")),
            ),
        :oneline1 => ( # · → Body.text → Text.eof
            "AAA\n",
            doc(node(:paragraph, "AAA")),
            ),
        :oneline2 => ( # · → Body.text → Text.blank → Body.eof
            "AAA\n\n",
            doc(node(:paragraph, "AAA")),
            ),
        :twostrings => ( # · → Body.text → Text.text → Body.eof
            "AAA\nBBB",
            doc(node(:paragraph, "AAA", "BBB")),
            ),
        :twolines => ( # · → Body.text → Text.text → Body.eof
            "AAA\nBBB\n",
            doc(node(:paragraph, "AAA", "BBB")),
            ),
        :threelines => ( # · → Body.text → Text.text → Body.eof
            "AAA\nBBB\nCCC\n",
            doc(node(:paragraph, "AAA", "BBB", "CCC")),
            ),
        :twoblocks => ( # · → Body.text → Text.blank → Body.text → Text.text → Body.eof
            "AAA\n\nBBB\nCCC\n\n",
            doc(node(:paragraph, "AAA"), node(:paragraph, "BBB", "CCC")),
            ),
        ]

    for (name, (string, tree)) in test_cases
        @assert parse(string) == tree name
    end
end

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
