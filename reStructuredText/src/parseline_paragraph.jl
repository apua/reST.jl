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
        nextliteral, paragraph = buildparagraph(context[:buffer])
        context[:buffer], context[:state] = [], State(nextliteral ? :literalblock : :body)
        context, children = eof(context)
        return context, (paragraph, children...)
    end

parseline(state::State{:paragraph}, line, context) =
    if isempty(line)
        @debug "paragraph -- empty"
        @assert length(context[:buffer]) >= 2
        nextliteral, paragraph = buildparagraph(context[:buffer])
        context[:buffer], context[:state] = [], State(nextliteral ? :literalblock : :body)
        return context, (paragraph,)
    elseif startswith(line, ' ')
        @debug "paragraph -- indent"
        @assert length(context[:buffer]) >= 2
        nextliteral, paragraph = buildparagraph(context[:buffer])
        context[:buffer], context[:state] = [], State(nextliteral ? :literalblock : :body)
        error_indent = Node{:system_message}([:type=>"ERROR"],[Node{:paragraph}([],["Unexpected indentation."])])
        context, children = parseline(line, context)
        return context, (paragraph, error_indent, children...)
    else
        @debug "paragraph -- readline"
        @assert length(context[:buffer]) >= 2
        push!(context[:buffer], line)
        return context, ()
    end

function buildparagraph(buffer)
    lastline = buffer[end]
    Paragraph(xs...) = Node{:paragraph}([], [xs...])
    if lastline == "::"
        @debug "buildparagraph -- double colons line"
        nextliteral, paragraph = true, Paragraph(buffer[1:end-1]...)
    elseif endswith(lastline, " ::")
        @debug "buildparagraph -- double colons tailing w/ space"
        nextliteral, paragraph = true, Paragraph(buffer[1:end-1]..., rstrip(lastline[1:end-2]))
    elseif !isnothing(match(r"(?<!\\)(\\\\)*::$", lastline))
        @debug "buildparagraph -- double colons tailing w/o space"
        nextliteral, paragraph = true, Paragraph(buffer[1:end-1]..., lastline[1:end-1])
    else
        @debug "buildparagraph -- no double colons"
        nextliteral, paragraph = false, Paragraph(buffer...)
    end
end
