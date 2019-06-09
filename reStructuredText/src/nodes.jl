# ==============================
#  Functional Node Base Classes
# ==============================

#abstract type Node end
#abstract type Element end

#abstract type TextElement <: Element end
#abstract type FixedTextElement <: TextElement end


# ========
#  Mixins
# ========

#abstract type Resolvable end
#abstract type BackLinkable end


# ====================
#  Element Categories
# ====================

#=
They might be used for type system, so treat them as abstract types.
=#

abstract type Root end
abstract type Titular end
abstract type PreBibliographic end
abstract type Bibliographic end
abstract type Decorative <: PreBibliographic end  #??
abstract type Structural end

abstract type Body end
abstract type General <: Body end
abstract type Sequential <: Body end
abstract type Admonition <: Body end
abstract type Special <: Body end
abstract type Invisible <: PreBibliographic end
abstract type Part end  # why is it not a subtype of `Body` ??
abstract type Inline end
#abstract type Referential <: Resolvable end
#abstract type Targetable <: Resolvable end
abstract type Labeled end


# ==============
#  Root Element
# ==============

struct document <: Root end


# ================
#  Title Elements
# ================

struct title <: Titular end
struct subtitle <: Titular end
struct rubric <: Titular end  # it should be `Body Elements`_


# ========================
#  Bibliographic Elements
# ========================

struct docinfo <: Bibliographic end
#struct info <: Bibliographic end  # missing
struct author <: Bibliographic end
struct authors <: Bibliographic end
struct organization <: Bibliographic end
struct address <: Bibliographic end
struct contact <: Bibliographic end
struct version <: Bibliographic end
struct revision <: Bibliographic end
struct status <: Bibliographic end
struct date <: Bibliographic end
struct copyright <: Bibliographic end


# =====================
#  Decorative Elements
# =====================

struct decoration <: Decorative end
struct header <: Decorative end
struct footer <: Decorative end


# =====================
#  Structural Elements
# =====================

struct section <: Structural end
struct topic <: Structural end
struct sidebars <: Structural end
struct transition <: Structural end


# ===============
#  Body Elements
# ===============

struct paragraph <: General end
struct compound <: General end
struct container <: General end
struct bullet_list <: Sequential end
struct enumerated_list <: Sequential end
struct list_item <: Part end
struct definition_list <: Sequential end
struct definition_list_item <: Part end
struct term <: Part end
struct classifier <: Part end
struct definition <: Part end
struct field_list <: Sequential end
struct field <: Part end
struct field_name <: Part end
struct field_body <: Part end
struct option <: Part end
struct option_argument <: Part end
struct option_group <: Part end
struct option_list <: Sequential end
struct option_list_item <: Part end
struct option_string <: Part end
struct description <: Part end
struct literal_block <: General end
struct doctest_block <: General end
struct math_block <: General end
struct line_block <: General end
struct line <: Part end
struct block_quote <: General end
struct attribution <: Part end
struct attention <: Admonition end
struct caution <: Admonition end
struct danger <: Admonition end
struct error <: Admonition end
struct important <: Admonition end
struct note <: Admonition end
struct tip <: Admonition end
struct hint <: Admonition end
struct warning <: Admonition end
struct admonition <: Admonition end
struct comment <: Special end
struct substitution_definition <: Special end
struct target <: Special end
struct footnote <: General end
struct citation <: General end
struct label <: Part end
#missing `rubric`
struct figure <: General end
struct image <: General end
struct caption <: Part end
struct legend <: Part end
struct table <: General end
struct tgroup <: Part end
struct colspec <: Part end
struct thead <: Part end
struct tbody <: Part end
struct row <: Part end
struct entry <: Part end
struct system_message <: Special end
struct pending <: Special end
struct raw <: Special end


# =================
#  Inline Elements
# =================

struct emphasis <: Inline end
struct strong <: Inline end
struct literal <: Inline end
struct reference <: Inline end
struct footnote_reference <: Inline end
struct citation_reference <: Inline end
struct substitution_reference <: Inline end
struct title_reference <: Inline end
struct abbreviation <: Inline end
struct acronym <: Inline end
struct superscript <: Inline end
struct subscript <: Inline end
struct math <: Inline end
struct inline <: Inline end
struct problematic <: Inline end
struct generated <: Inline end


struct Node{S}
    attributes
    children
end

"""
TODO:

- [v] represent node structure in "semi-XML" style
- [ ] represent node attributes sorted by name
- [v] unit test for representing node structure
"""
Base.show(io::IO, n::Node{S}, indent="") where S = begin
    println(io, indent, "<$S", (" $k=\"$v\"" for (k, v) in n.attributes)..., ">")
    indent *= "    "
    for child in n.children
        if (child isa AbstractString)
            println(io, (indent * line for line in split(child, r"^"m))...)
        else
            Base.show(io, child, indent)
        end
    end
end
