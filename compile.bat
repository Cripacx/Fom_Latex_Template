IF "%1" == "en" (
    lualatex --jobname=main_englisch  "\def\FOMEN{}\input{main.tex}"
    biber main_englisch
    lualatex --jobname=main_englisch  "\def\FOMEN{}\input{main.tex}"
    lualatex --jobname=main_englisch  "\def\FOMEN{}\input{main.tex}"
    main_englisch.pdf
) ELSE (
    lualatex main.tex
    biber main
    lualatex main.tex
    lualatex main.tex
    main.pdf
)
del *.bbl /f /q
del *.blg /f /q
del *.aux /f /q
del *.bcf /f /q
del *.ilg /f /q
del *.lof /f /q
del *.log /f /q
del *.lot /f /q
del *.nlo /f /q
del *.nls* /f /q
del *.out /f /q
del *.toc /f /q
del *.run.xml /f /q
del *.lot /f /q
