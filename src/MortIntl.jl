module MortIntl

using Colors, CSV, DataFrames, JSON, PGFPlotsX
srcpath = @__DIR__
mainpath = normpath(@__DIR__, "..")
datapath = normpath(mainpath, "data")
conf = JSON.parsefile(normpath(datapath, "mortintl.json"))
sexes = ["m", "f"]
agest = [0; 0:4; 5:5:95]
ageend = ["ω"; 0:4; 9:5:94; "ω"]

function hmddf_ctrysex(ctry, sex)
        iso = conf["countries"]["$ctry"]["iso3166"]
        hmddf(normpath(datapath, "$(iso)_$(sexes[sex])ltper_1x1.txt"))
end

function hmddf(path)
        of = tempname()
        run(pipeline(`sed 's/110+/110/' $path`, stdout = of))
        CSV.File(of, delim=' ', header=3, ignorerepeated=true) |> DataFrame
end

save_ctry_caprop(cc, path) = cc[:propframe] |>
CSV.write(normpath(path, fname(cc[:ctry], cc[:ca1], cc[:ca2])))

fname(ctry, ca1, ca2) = "$(ca1)$(ca2)$(ctry).csv"

function ctry_caprop(ctry, ca1, ca2, loadpath, savepath)
        ca1d = conf["causes"][ca1]
        ca2d = conf["causes"][ca2]
        loadfullpath = normpath(loadpath, fname(ctry, ca1, ca2))
        if (loadpath != "" && ispath(loadfullpath))
                df = CSV.File(loadfullpath) |> DataFrame
        else
                df = caprop(ctry, ca1d["causeexpr"], ca2d["causeexpr"])
        end
        cc = Dict(:ca1 => ca1, :ca2 => ca2, :ctry => ctry, :propframe => df)
        if savepath != ""
                save_ctry_caprop(cc, savepath)
        end
        cc
end

function caprop(ctry, ca1es, ca2es)
        df = DataFrame()
        for (li, ca1e) in ca1es
                of = tempname()
                le = conf["listexpr"][li]
                ca2e = ca2es[li]
                run(pipeline(Cmd(`$srcpath/propyrs_ctry.sh $ctry "$ca1e" "$ca2e" "$le"`, dir = srcpath),
                             stdout = of))
                dfli = CSV.File(of) |> DataFrame
                df = vcat(df, dfli)
        end
        sort(df, [:yr, :age])
end

function caprop_eplot(ctries, sex, ca1, ca2, caage, eage, lang, loadpath, savepath)
        ca1lab = conf["causes"][ca1]["alias"][lang]
        ca2lab = conf["causes"][ca2]["alias"][lang]
        sexlab = conf["sexes"]["$sex"]["alias"][lang]
        dlab = conf["deaths"]["alias"][lang]
        elab = uppercasefirst(conf["expectancy"]["alias"][lang])
        if lang == "sv"
                pgfnf = @pgf {"/pgf/number format/use comma"}
        else
                pgfnf = @pgf {}
        end
        p = @pgf Axis({xlabel = "e($(eage))",
                      ylabel = "$dlab $ca1lab/$ca2lab $(agest[caage])–$(ageend[caage])",
                      "yticklabel style"=pgfnf,
                      "legend style"={"font=\\tiny"},
                      legend_pos="outer north east",
                      title = "$elab vs $dlab $sexlab", xmajorgrids, ymajorgrids})
        plotcolors = distinguishable_colors(length(ctries)+1, [RGB(1,1,1)])[2:end]
        for (i, ctry) in enumerate(ctries)
                caprop_eplot_ctry(p, plotcolors[i], ctry, sex, ca1, ca2,
                                  caage, eage, loadpath, savepath)
        end
        p
end

function caprop_eplot_ctry(p, pcol, ctry, sex, ca1, ca2, caage, eage, loadpath, savepath)
        propf = ctry_caprop(ctry, ca1, ca2, loadpath, savepath)[:propframe]
        propf_sex_caage = propf[(propf[!, :sex].==sex) .& (propf[!, :age].==caage), :]
        ef = hmddf_ctrysex(ctry, sex)
        ef_age = ef[ef[!, :Age].==eage, :]
        pef = innerjoin(ef_age, propf_sex_caage, on = [:Year=>:yr])
        @pgf push!(p, PlotInc({"mark=+", color = pcol},
                              Table([pef[!, :ex], pef[!, :rat]])),
                   LegendEntry(conf["countries"]["$(ctry)"]["iso3166"]))
end

end
