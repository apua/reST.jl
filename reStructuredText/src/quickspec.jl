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
    AAA\nBBB\n
    AAA\nBBB\n\n
        ->   context = (AAA, BBB) ; line = ""     => empty line, i.e. State(:Body)

    AAA\n::\n
    AAA\n::\n\n
        ->   context = (AAA,) ; line = ""         => literal block

    AAA\nBBB\n CCC\n
        ->   context = (AAA, BBB) ; line = " CCC" => unexpected indent and quote block

    AAA\nBBB::\n
        ->   context = (AAA, BBB:) ; line = ""    => literal block

    AAA\nBBB   ::\n
        ->   context = (AAA, BBB) ; line = ""     => literal block

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
