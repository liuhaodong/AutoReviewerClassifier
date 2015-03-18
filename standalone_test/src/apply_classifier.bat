python convert_outs.py ..\data\task.xls outs.csv engage upload.csv

python align.py . ..\data\task.xls upload.csv ..\result\label.xls

del upload.csv
