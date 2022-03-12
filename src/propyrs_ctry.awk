BEGIN {
        FS = ","
        print "yr,age,sex,ca1,ca2,rat"
}

function add_age(v) {
        for(i=1; i<=25; i++) {
                c = i+9
                v[$4][i][$7] += $c
        }
}

$5~li && $6~ca1 {
        add_age(ca1n)
}

$5~li && $6~ca2 {
        add_age(ca2n)
}

END {
        for (yr in ca1n) {
                for (age in ca1n[yr]) {
                        for (sex in ca1n[yr][age]) {
                                if (ca2n[yr][age][sex] > 0) {
                                        n1 = ca1n[yr][age][sex]
                                        n2 = ca2n[yr][age][sex]
                                        rat = n1 / n2
                                        printf("%d,%d,%d,%d,%d,%.3f\n", yr, age, sex, n1, n2, rat)
                                }
                        }
                }
        }
}
