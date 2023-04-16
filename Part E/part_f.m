clc;% clearing the comand window
clear all; %clears the workspace
close all; %closes all open figures

truss('Part_f.txt')


truss_f('Part_F3.txt', 'truss_deformation_f3.txt')

