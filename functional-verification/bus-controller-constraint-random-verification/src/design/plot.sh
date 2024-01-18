
set datafile separator ","

set output 'ret_prom.png'

set xlabel "Terminales" offset -4, 0, 0
set xtics left offset 0,-0.3 rotate by 45 right
set xrange [4:32]

set ylabel "Profundidad" offset 2, 0, 0
set ytics left offset 0,-0.5
set yrange [10:32]

set zlabel "Retardo [us]" offset -2, 0, 0 rotate by 90 right
set autoscale

set dgrid3d 50,50 qnorm 2
set hidden3d

splot "reporte_retardo_prom.csv" u 1:2:($3/1000) title "" with lines



{ head -n 1 reporte_bw_prom.csv; tail -n +2 reporte_retardo_prom.csv | sort -t',' -k3; } 


ya esta: 
bw_max
bw_prom
