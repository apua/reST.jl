module inline end
####################
module section end
module paragraph
    emptystring = ""  # · → Body.eof
    emptyline1 = "\n"  # · → Body.blank → Body.eof
    emptyline2 = "\n\n"  # · → Body.blank → Body.eof
    onestring = "AAA"  # · → Body.text → Text.eof
    oneline1 = "AAA\n"  # · → Body.text → Text.eof
    oneline2 = "AAA\n\n"  # · → Body.text → Text.blank → Body.eof
    twostrings = "AAA\nBBB"  # · → Body.text → Text.text → Body.eof
    twolines = "AAA\nBBB\n"  # · → Body.text → Text.text → Body.eof
    threelines = "AAA\nBBB\nCCC\n"   # · → Body.text → Text.text → Body.eof
    twoblocks = "AAA\n\nBBB\nCCC\n\n"  # · → Body.text → Text.blank → Body.text → Text.text → Body.eof
    end
module transition end
####################
module bulletlist end
module enumeratedlist end
module definitionlist end
module fieldlist end
module optionlist end
####################
module literalblock
    emptystring = "::"  # · → Body.line → Line.eof × Body.text → Text.eof
    emptyline = "::\n"  # · → Body.line → Line.eof × Body.text → Text.eof
    onestring = "AAA::"  # · → Body.text → Text.eof
    oneline = "AAA\n::"  # · → Body.text → Text.underline × Text.text → Body.eof
    twostrings = "AAA\nBBB::"  # · → Body.text → Text.text → Body.eof
    twolines = "AAA\nBBB\n::"  # · → Body.text → Text.text → Body.eof

    onelinecontent = "AAA::\n\n  BBB"  # · → Body.text → Text.blank → Body.eof
    twolinescontent = "AAA\nBBB::\n\n  CCC"  # · → Body.text → Text.text→ Body.eof

    """
    warn_with_different_lines = [
        :emptystring => ( # · → Body.line → Line.eof × Body.text → Text.eof
            "::",
            doc(warn_literal_notfound),
            ),
        :emptyline => ( # · → Body.line → Line.eof × Body.text → Text.eof
            "::\n",
            doc(warn_literal_notfound),
            ),
        :onestring => ( # · → Body.text → Text.eof
            "AAA::",
            doc(node(:paragraph, "AAA"), warn_literal_notfound),
            ),
        :oneline => ( # · → Body.text → Text.underline × Text.text → Body.eof
            "AAA\n::",
            doc(info_title_underline, node(:paragraph, "AAA"), warn_literal_notfound),
            ),
        :twostrings => ( # · → Body.text → Text.text → Body.eof
            "AAA\nBBB::",
            doc(node(:paragraph, "AAA", "BBB"), warn_literal_notfound),
            ),
        :twolines => ( # · → Body.text → Text.text → Body.eof
            "AAA\nBBB\n::",
            doc(node(:paragraph, "AAA", "BBB"), warn_literal_notfound),
            ),
        ]
    """
    end
module blockquote
    unexpected1 = "AAA\nBBB\n CCC\n"  # · → Body.text → Text.text → Body.indent → Body.text → Text.eof
    unexpected2 = "AAA\nBBB\n CCC\n DDD\n"
end
module lineblock end
module doctestblock end
####################
module tables end
####################
module explict end


raw"""
=============================
Double quote related cases
=============================

info_incomplete_section
    msg(info, "Possible incomplete section title.",
        "Treating the overline as ordinary text because it's so short.")

info_title_underline
    msg(info, "Possible title underline, too short for the title.",
        "Treating it as ordinary text because it's so short.")

info_blankline_missing
    msg(info, "Blank line missing before literal block (after the "::")? Interpreted as a definition list item.")

warn_literal_notfound
    msg("WARNING", "Literal block expected; none found.")

warn_definitionlist_endswithout_blankline
    msg(warn, "Definition list ends without a blank line; unexpected unindent.")

warn_blockquote_endswithout_blankline
    msg(warn, "Block quote ends without a blank line; unexpected unindent.")

--------------------

:: warn_literal_notfound
::\n warn_literal_notfound

--------------------

::\n:
    info_incomplete_section
    info_title_underline
    paragraph("::", ":")
::\n::
    info_incomplete_section
    section(title("::"))

--------------------

::A
    paragraph("::A")
::\nA
    info_incomplete_section
    paragraph("::", "A")
::\nA\n:
    info_incomplete_section
    paragraph("::", "A", ":")
::\nA\n::
    section(title("A"))
::\nAAA
    info_incomplete_section
    paragraph("::", "AAA")
::\n AAA
    info_incomplete_section
    definition_list(definition_list_item(term("::"), definition(
        info_blankline_missing,
        paragraph("AAA"),
        )))
::\n ::
    info_incomplete_section
    definition_list(definition_list_item(term("::"), definition(
        info_blankline_missing,
        warn_literal_notfound,
        )))
::\nA\n:
    info_incomplete_section
    paragraph("::", "A", ":")

--------------------

::\nA\n:: section(title("A"))
::\n A\n:: section(title("A"))
::\n  A\n::
    info_incomplete_section
    definition_list(definition_list_item(term("::"), definition(
        info_blankline_missing,
        paragraph("A")
        )))
    warn_definitionlist_endswithout_blankline
    warn_literal_notfound

--------------------

::\nA\n:: section(title("A"))
::\nA:::
    info_incomplete_section
    paragraph("::", "AA", "::")
    warn_literal_notfound

--------------------

A\n:: section(title("A"))
AA\n:: section(title("AA"))
 A\n::
    block_quote(paragraph("A"))
    warn_blockquote_endswithout_blankline
    warn_literal_notfound
"""
