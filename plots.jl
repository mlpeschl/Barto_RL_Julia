using Gadfly


splot = layer(x = collect(1:length(steps)), y = steps, Geom.smooth(smoothing = 0.2),
                Theme(default_color = "red"))
qplot = layer(x = collect(1:length(steps2)), y = steps2, Geom.smooth(smoothing = 0.2),
                Theme(default_color = "blue"))
nplot = layer(x = collect(1:length(steparr)), y = steparr, Geom.smooth(smoothing = 0.2),
                Theme(default_color = "orange"))
mplot = layer(x = collect(1:length(lengthsMC)), y = lengthsMC, Geom.smooth(smoothing = 0.2),
                Theme(default_color = "green"))
#testplot = layer(x = collect(1:length(test)), y= test, Geom.smooth(smoothing = 0.2))

plot(splot,qplot,nplot,mplot, Guide.manual_color_key("",["Sarsa","QLearn","nSarsa","MC-OffPolicy"],
                            ["red","blue","orange","green"]),
                            Theme(background_color = "white"),
                            Guide.ylabel("Number of Steps"),
                            Guide.xlabel("Episode"),
                            Coord.Cartesian(ymin = 0, ymax = 10^2.5,xmin = 0, xmax = 5*10^3))
