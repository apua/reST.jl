module test_nodes

using Test: @testset, @test
using Printf: @sprintf

import Pkg; Pkg.activate("reStructuredText");
using reStructuredText: Node

@testset "$(@__MODULE__)" begin
    @testset "Represent Node" begin
        source_string = """
           Paragraph with bre-
           ak line.

           End with *emph*

           **Start** with strong

           How `about`_ ref and `title_ref` ?

           Tailing space does no effect

           - bullet

             - sub
             - bullet
           """

        doctree_string = """
            <document source="test data">
                <paragraph>
                    Paragraph with bre-
                    ak line.
                <paragraph>
                    End with
                    <emphasis>
                        emph
                <paragraph>
                    <strong>
                        Start
                     with strong
                <paragraph>
                    How
                    <reference name="about" refname="about">
                        about
                     ref and
                    <title_reference>
                        title_ref
                     ?
                <paragraph>
                    Tailing space does no effect
                <bullet_list bullet="-">
                    <list_item>
                        <paragraph>
                            bullet
                        <bullet_list bullet="-">
                            <list_item>
                                <paragraph>
                                    sub
                            <list_item>
                                <paragraph>
                                    bullet
            """

        doctree = Node{:document}([:source => "test data"], [
            Node{:paragraph}([], [
                "Paragraph with bre-\nak line."
            ]),
            Node{:paragraph}([], [
                "End with ",
                Node{:emphasis}([], ["emph"]),
            ]),
            Node{:paragraph}([], [
                Node{:strong}([], ["Start"]),
                " with strong",
            ]),
            Node{:paragraph}([], [
                "How ",
                Node{:reference}([:name => "about", :refname => "about"], ["about"]),
                " ref and ",
                Node{:title_reference}([], ["title_ref"]),
                " ?",
            ]),
            Node{:paragraph}([], [
                "Tailing space does no effect",
            ]),
            Node{:bullet_list}([:bullet => "-"], [
                Node{:list_item}([], [
                    Node{:paragraph}([], ["bullet"]),
                    Node{:bullet_list}([:bullet => "-"], [
                        Node{:list_item}([], [Node{:paragraph}([], ["sub"])]),
                        Node{:list_item}([], [Node{:paragraph}([], ["bullet"])]),
                    ]),
                ]),
            ]),
        ])

        @test repr(doctree) == doctree_string
    end

    @testset "TextTests" begin
        # Julia support unicode properly
        # No :type:`Text` here
        # will not support `shortrepr`
    end

    @testset "ElementTests" begin
        # Strange attribute `ids` of `Element` can store mulitple values ?
    end

    @testset "MiscTests" begin
        # Not support `make_id` currently
        # Those node operations may be useless
    end

    @testset "TreeCopyVisitorTests" begin
        # Not support `TreeCopyVisitor`, at least not now
    end

    @testset "MiscFunctionTests" begin
        # :test`test_set_id_default` may be important
        # `document.set_id` generate `ids`

    end
end

end  # module
