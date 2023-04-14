clc;% clearing the comand window
clear all; %clears the workspace
close all; %closes all open figures

truss('Part_f.txt')


truss_e('final_data.txt', 'truss_deformation_f.txt')

