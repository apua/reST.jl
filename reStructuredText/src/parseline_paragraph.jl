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

function test_literalblock()
    Doc(xs...) = Node(:document, xs...)
    Paragraph(xs::String...) = Node(:paragraph, xs...)
    LiteralBlock(xs::String...) = Node(:literal_block, :(xml:space)=>"preserve", xs...)
    ErrorIndent() = Node(:system_message, :type=>"ERROR", Paragraph("Unexpected indentation."))
    warn_unindent(s) = Node(:system_message, :type=>"WARNING", Node(:paragraph, "$s ends without a blank line; unexpected unindent."))
    warn_literal_notfound() = Node(:system_message, :type=>"WARNING", Node(:paragraph, "Literal block expected; none found."))

    @assert parse("AAA\nBBB::\nCCC") == Doc(Paragraph("AAA", "BBB::", "CCC"))

    @assert parse("AAA\nBBB::\n\n CCC") == Doc(Paragraph("AAA", "BBB:"), LiteralBlock("CCC"))
    @assert parse("AAA\nBBB::\n CCC") == Doc(Paragraph("AAA", "BBB:"), ErrorIndent(), LiteralBlock("CCC"))

    @assert parse("AAA\nBBB::\n\n CCC\n\nDDD") == Doc(Paragraph("AAA", "BBB:"), LiteralBlock("CCC"), Paragraph("DDD"))
    @assert parse("AAA\nBBB::\n\n CCC\nDDD") == Doc(Paragraph("AAA", "BBB:"), LiteralBlock("CCC"), warn_unindent("Literal block"), Paragraph("DDD"))
    @assert parse("AAA\nBBB::\n CCC\n\nDDD") == Doc(Paragraph("AAA", "BBB:"), ErrorIndent(), LiteralBlock("CCC"), Paragraph("DDD"))
end

eof(state::State{:paragraph}, context) =
    begin
        @info "paragraph.eof"
        @assert length(context[:buffer]) >= 2
        nextliteral, paragraph = buildparagraph(context[:buffer])
        empty!(context[:buffer])
        context[:state] = State(nextliteral ? :literalblock : :body)
        context, children = eof(context)
        return context, (paragraph, children...)
    end

eof(state::State{:literalblock}, context) =
    begin
        @info "literalblock.eof"
        @assert length(context[:buffer]) > 0
        literalblock = buildliteralblock(context[:buffer])
        empty!(context[:buffer])
        context[:state] = State(:body)
        context, children = eof(context)
        return context, (literalblock, children...)
    end

parseline(state::State{:paragraph}, line, context) =
    if isempty(line)
        @info "paragraph -- empty"
        @assert length(context[:buffer]) >= 2
        nextliteral, paragraph = buildparagraph(context[:buffer])
        empty!(context[:buffer])
        context[:state] = State(nextliteral ? :literalblock : :body)
        return context, (paragraph,)
    elseif startswith(line, ' ')
        @info "paragraph -- indent"
        @assert length(context[:buffer]) >= 2
        nextliteral, paragraph = buildparagraph(context[:buffer])
        empty!(context[:buffer])
        context[:state] = State(nextliteral ? :literalblock : :body)
        error_indent = Node{:system_message}([:type=>"ERROR"],[Node{:paragraph}([],["Unexpected indentation."])])
        context, children = parseline(line, context)
        return context, (paragraph, error_indent, children...)
    else
        @info "paragraph -- readline"
        @assert length(context[:buffer]) >= 2
        push!(context[:buffer], line)
        return context, ()
    end

parseline(state::State{:literalblock}, line, context) =
    if isempty(line) || startswith(line, ' ')
        @info "literalblock -- readline"
        push!(context[:buffer], line)
        return context, ()
    else
        @info "literalblock -- unindented found"
        if all(isempty, context[:buffer])
            try_quotedliteralblock
        else
            @assert length(context[:buffer]) > 0
            literalblock = buildliteralblock(context[:buffer])
            blanklinefinish = isempty(context[:buffer][end])
            warn_unindent(s) = Node(:system_message, :type=>"WARNING",
                                    Node(:paragraph, "$s ends without a blank line; unexpected unindent."))
            empty!(context[:buffer])
            context[:state] = State(:body)
            context, children = parseline(line, context)
            if blanklinefinish
                return context, (literalblock, children...)
            else
                return context, (literalblock, warn_unindent("Literal block"), children...)
            end
        end
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

function buildliteralblock(buffer)
    leadingspacelength(line) = length(line) - length(lstrip(line))
    indentlength = min(filter(i -> i > 0, map(leadingspacelength, buffer))...)
    isnonempty(line) = ! isempty(line)
    first, last = findfirst(isnonempty, buffer), findlast(isnonempty, buffer)
    LiteralBlock(xs::String...) = Node(:literal_block, :(xml:space)=>"preserve", xs...)
    LiteralBlock((line[indentlength+1:end] for line in buffer[first:last])...)
end
