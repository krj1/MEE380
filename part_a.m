clc;% clearing the comand window
clear all; %clears the workspace
close all; %closes all open figures

truss('data.txt')

for angel=20:5:80
    truss_b('final_data.txt')
end
