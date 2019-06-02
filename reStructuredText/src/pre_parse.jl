s = """

    Title here
    ===========

    Content hahahahahah        
    ahahah
    ahahahahaahah.

    - qwer

    \t- asdf
        - zxcv

    - asf

    .. _`xxx`: http://google.com

    point is `xxx`_. `xxx`_.

    .. _`xxx`: http://google.com

    .. code:: sh        

        for i in range(10): print(i)
    """

t = join((
    "\n",
    "Title here\n",
    "===========\n",
    "\n",
    "Content hahahahahah        \n",
    "ahahah\n",
    "ahahahahaahah.\n",
    "\n",
    "- qwer\n",
    "\n",
    "\t- asdf\n",
    "    - zxcv\n",
    "\n",
    "- asf\n",
    "\n",
    ".. _`xxx`: http://google.com\n",
    "\n",
    "point is `xxx`_. `xxx`_.\n",
    "\n",
    ".. _`xxx`: http://google.com\n",
    "\n",
    ".. code:: sh        \n",
    "\n",
    "    for i in range(10): print(i)\n",
    ))

@assert s == t

a = [
    "",
    "Title here",
    "===========",
    "",
    "Content hahahahahah",
    "ahahah",
    "ahahahahaahah.",
    "",
    "- qwer",
    "",
    "        - asdf",
    "    - zxcv",
    "",
    "- asf",
    "",
    ".. _`xxx`: http://google.com",
    "",
    "point is `xxx`_. `xxx`_.",
    "",
    ".. _`xxx`: http://google.com",
    "",
    ".. code:: sh",
    "",
    "    for i in range(10): print(i)",
    ]

tab_width = 8

@doc raw"""
1. `r"[\v\f]" -> " "` not support; behavior of matching `\v` is different with in Python

2. `r"\s+\$" -> ""` done by `split`

3. `r"\t" -> " " x tab_width` done by `replace`

4. `str.splitlines` done by `rstrip` and regex rather than `readline(IOBuffer)` trick

Actually, those ASCII control characters should not appear in reST source today,
it is unnecessary to care about.
"""
pre_parse(s) = split(rstrip(replace(s, "\t" => " " ^ tab_width)), r" *(\n|\r\n)")

@assert pre_parse(s) == a
