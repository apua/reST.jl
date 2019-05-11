module test_paragraphs

using Test: @testset, @test
using Printf: @sprintf
using PyCall: pyimport

function parse(input)
    frontend = pyimport("docutils.frontend")
    rst = pyimport("docutils.parsers.rst")
    utils = pyimport("docutils.utils")
    settings = frontend.OptionParser(components=[rst.Parser]).get_default_values()
    settings.report_level = 5
    settings.halt_level = 5
    doc = utils.new_document("test data", settings)
    rst.Parser().parse(input, doc)
    output = doc.pformat()
end

totest = Dict(
    "paragraphs" => [
        ["""
        A paragraph.
        """,
        """
        <document source="test data">
            <paragraph>
                A paragraph.
        """],
        ["""
        Paragraph 1.

        Paragraph 2.
        """,
        """
        <document source="test data">
            <paragraph>
                Paragraph 1.
            <paragraph>
                Paragraph 2.
        """],
        ["""
        Line 1.
        Line 2.
        Line 3.
        """,
        """
        <document source="test data">
            <paragraph>
                Line 1.
                Line 2.
                Line 3.
        """],
        ["""
        Paragraph 1, Line 1.
        Line 2.
        Line 3.

        Paragraph 2, Line 1.
        Line 2.
        Line 3.
        """,
        """
        <document source="test data">
            <paragraph>
                Paragraph 1, Line 1.
                Line 2.
                Line 3.
            <paragraph>
                Paragraph 2, Line 1.
                Line 2.
                Line 3.
        """],
        ["""
        A. Einstein was a really
        smart dude.
        """,
        """
        <document source="test data">
            <paragraph>
                A. Einstein was a really
                smart dude.
        """],
    ]
)

@testset "$(@__MODULE__)" begin
    for (name, cases) in totest
        @testset "$name" begin
            for (input, output) in cases
                @test parse(input) == output
            end
        end
    end
end

end  # module

