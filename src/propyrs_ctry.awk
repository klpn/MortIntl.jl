BEGIN {
        FS = ","
        print "yr,li,age,sex,ca1,ca2,rat"
}

function add_age(v) {
        for(i=1; i<=25; i++) {
                c = i+9
                v[$4,i,$7] += $c
        }
}

$5~li && $6~ca1 {
        add_age(ca1n)
}

$5~li && $6~ca2 {
        add_age(ca2n)
}

END {
        for (yragesex in ca1n) {
                split(yragesex, yassep, SUBSEP)
                n1 = ca1n[yragesex]
                n2 = ca2n[yragesex]
                rat = n1 / n2
                yr = yassep[1]
                age = yassep[2]
                sex = yassep[3]
                printf("%d,%d,%d,%d,%d,%d,%.3f\n", yr, li, age, sex, n1, n2, rat)
        }
}
