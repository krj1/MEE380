clc
% Open the file for reading
fid = fopen('filename.txt', 'r');

% Read the first section (8x3 matrix)
data1 = fscanf(fid, '%d %d %d\n', [3, 8])'; % read as 8 rows of 3 columns
fclose(fid);

% Open the file again for reading the second section
fid = fopen('filename.txt', 'r');

% Skip the first section
for i = 1:8
    fgetl(fid);
end

% Read the second section (edge list)
data2 = fscanf(fid, '%d %d %s\n', [3, Inf])'; % read as 3 columns of unknown number of rows
fclose(fid);

% Sum the X and Y coordinates for each vertex in the edge list
vertices = unique(data2(:, 2:3));
for i = 1:size(vertices, 1)
    v = vertices(i, :);
    mask = (data2(:, 2:3) == repmat(v, size(data2, 1), 1));
    x_sum = sum(data1(v(1), 2) + data1(v(2), 2));
    y_sum = sum(data1(v(1), 3) + data1(v(2), 3));
    data2(mask(:, 1), 2) = x_sum;
    data2(mask(:, 2), 3) = y_sum;
end

% Write the new file
fid = fopen('newfile.txt', 'w');
fprintf(fid, '%d %d %d\n', data1');
fprintf(fid, '%d %d %s\n', data2');
fclose(fid);
