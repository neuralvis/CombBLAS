set title "Effects of Filter Permeability (2048 processes)"
set terminal png
set output "gnuplot_perm_2048.png"
set xrange [-5:105]
set yrange [0.1:32]
set logscale y
set grid ytics mytics lt 1 lc rgb "#EEEEEE"
set xlabel 'Filter Permeability'
set ylabel 'Mean BFS Time (seconds, log scale)'
set key right bottom
set xtics ('1%%' 1, '10%%' 10, '25%%' 25, '100%%' 100)
plot\
 "gnuplot_perm_2048.dat" every ::1 using 1:2:3:4 title '' ps 0 lc rgb '#FF0000' with errorbars,\
 "gnuplot_perm_2048.dat" every ::1 using 1:2 title 'Python/Python KDT' lc rgb '#FF0000' with lines,\
 "gnuplot_perm_2048.dat" every ::1 using 1:5:6:7 title '' ps 0 lc rgb '#8B0000' with errorbars,\
 "gnuplot_perm_2048.dat" every ::1 using 1:5 title 'Python/SEJITS KDT' lc rgb '#8B0000' with lines,\
 "gnuplot_perm_2048.dat" every ::1 using 1:8:9:10 title '' ps 0 lc rgb '#0000FF' with errorbars,\
 "gnuplot_perm_2048.dat" every ::1 using 1:8 title 'SEJITS/SEJITS KDT' lc rgb '#0000FF' with lines,\
 "gnuplot_perm_2048.dat" every ::1 using 1:11:12:13 title '' ps 0 lc rgb '#DAA520' with errorbars,\
 "gnuplot_perm_2048.dat" every ::1 using 1:11 title 'C++/C++ CombBLAS' lc rgb '#DAA520' with lines