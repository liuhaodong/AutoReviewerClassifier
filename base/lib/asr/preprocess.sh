#!/bin/bash

cat $1 | awk '{printf("%s ",$0);}' | sed '{s/[^ A-Z\ ]//g; s/\ \+/\ /g;}' | sed '{
s/\ /27\ /g;
s/A/1\ /g;
s/B/2\ /g;
s/C/3\ /g;
s/D/4\ /g;
s/E/5\ /g;
s/F/6\ /g;
s/G/7\ /g;
s/H/8\ /g;
s/I/9\ /g;
s/J/10\ /g;
s/K/11\ /g;
s/L/12\ /g;
s/M/13\ /g;
s/N/14\ /g;
s/O/15\ /g;
s/P/16\ /g;
s/Q/17\ /g;
s/R/18\ /g;
s/S/19\ /g;
s/T/20\ /g;
s/U/21\ /g;
s/V/22\ /g;
s/W/23\ /g;
s/X/24\ /g;
s/Y/25\ /g;
s/Z/26\ /g;}'
