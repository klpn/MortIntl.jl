# MortIntl

This package can be used to analyze trends in cause-specific mortality and life
expectancy for different countries, with data from
[WHO Mortality Database](https://www.who.int/data/data-collection-tools/who-mortality-database)
and [Human Mortality Database](https://www.mortality.org/). It is conceptually
similar to my [Mortchartgen](https://github.com/klpn/Mortchartgen.jl) package, and uses a similar
[configuraton file](data/mortintl.json), but uses an AWK-based back-end for
data extraction, and thus avoids dependency on SQL databases.

Files from the mortality databases should be saved in the `data` subdirectory.
The package uses 1x1 HMD period life tables, which should be prefixed by
`[ISO 3166-code]_`, as given the configuration file (e.g. a life table for 
Norwegian women should be saved as `NO_fltper_1x1.txt`).

To generate a table with trends for proportion of deaths from circulatory
diseases in Denmark, and save it in `data` subdirectory for later
reuse (and load it from there, if it already has been saved).

```{.julia}
 MortIntl.ctry_caprop(4050, "circ", "all", MortIntl.datapath, MortIntl.datapath)
```

To plot life expectancy at birth vs proportion of deaths from circulatory
diseases for all ages in women, in Denmark, Finland, Norway and Sweden, using
[PGFPlotsX](https://github.com/KristofferC/PGFPlotsX.jl).

```{.julia}
 MortIntl.MortIntl.caprop_eplot([4050,4070,4220,4290], 2, "circ", "all",
 1, 0, "en", MortIntl.datapath, MortIntl.datapath)
```
