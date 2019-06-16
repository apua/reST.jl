module inline end
####################
module section end
module paragraph
    emptystring = ""  # ·
    emptyline1 = "\n"  # · → Body.blank → Body.eof
    emptyline2 = "\n\n"  # · → Body.blank → Body.eof
    onestring = "AAA"  # · → Body.text → Text.eof
    oneline1 = "AAA\n"  # · → Body.text → Text.eof
    oneline2 = "AAA\n\n"  # · → Body.text → Text.eof
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
    """
    case 1::

        AAA
        BBB    ->   context = (AAA, BBB) ; line = ""     => empty line, i.e. State(:Body)
        ___

    case 2::

        AAA
        ::     ->   context = (AAA,) ; line = ""         => literal block
        ___

    case 3::

        AAA
        BBB    ->   context = (AAA, BBB) ; line = " CCC" => unexpected indent and quote block
         CCC

    case 4::

        AAA
        BBB::  ->   context = (AAA, BBB:) ; line = ""    => literal block
        ___

    case 5::

        AAA
        BBB :: ->   context = (AAA, BBB) ; line = ""     => literal block
        ___

    case 6::  it is never happened...

        ::     ->   context = () ; line = ""             => literal block
        ___

    case 7::  without empty line, it is handled by main loop

        AAA
        BBB::
    """
    end
module blockquote
    unexpected1 = "AAA\nBBB\n CCC\n"
    unexpected2 = "AAA\nBBB\n CCC\n DDD\n"
end
module lineblock end
module doctestblock end
####################
module tables end
####################
module explict end
