using Gadfly


dynaplot = layer(x = collect(1:length(benchDyna)), y = benchDyna,
                Geom.step(),
                Theme(default_color = "blue"))


dynaplotplus = layer(x = collect(1:length(benchDynaplus)), y = benchDynaplus,
                Geom.step(),
                Theme(default_color = "red"))

dynaplot2 = layer(x = collect(1:length(benchDynaplus)), y = benchDyna2,
                Geom.step(),
                Theme(default_color = "green"))

plot(dynaplot,dynaplotplus,dynaplot2, Theme(background_color = "white"))
