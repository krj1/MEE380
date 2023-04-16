% function to plot the shape of a 2D truss given the node coordinates 
% and number of elements (directions too)

function plot_truss(filename,color,shape,mark_color)

% OPEN DATA FILE
fid = fopen(filename, 'r');

% READ DATA - READ NODE DATA - First read the number of nodes in the truss
Number_nodes = fscanf(fid, '%d', 1);

% Read the coordinates for each node
Coordinate = zeros(Number_nodes, 2);
    for i = 1:Number_nodes
        Node = fscanf(fid, '%d', 1);
        Coordinate(Node, 1) = fscanf(fid, '%g', 1);
        Coordinate(Node, 2) = fscanf(fid, '%g', 1);
    end

% READ DATA - READ ELEMENT DATA - Now read the number of elements and the
% element definition
Number_elements = fscanf(fid, '%d', 1);

% Store element connectivity information in a matrix
Element_connectivity = zeros(Number_elements, 2);
    for i = 1:Number_elements
        Element = fscanf(fid, '%d', 1);
        Element_connectivity(Element, 1) = fscanf(fid, '%d', 1);
        Element_connectivity(Element, 2) = fscanf(fid, '%d', 1);
    end

% CLOSE DATA FILE
%fclose(fid);

% PLOT THE TRUSS
%figure;
hold on;
    for i = 1:Number_elements
        Node_from = Element_connectivity(i, 1);
        Node_to = Element_connectivity(i, 2);
        plot([Coordinate(Node_from, 1), Coordinate(Node_to, 1)], ...
           [Coordinate(Node_from, 2), Coordinate(Node_to, 2)], ...
           'Color',color, 'LineWidth', 3);
    end
hold on 
plot(Coordinate(:, 1), Coordinate(:, 2), 'Marker',shape, ...
    'MarkerFaceColor', mark_color,'MarkerEdgeColor', 'k', 'MarkerSize', 15);
        % plot the nodes to really see comparison


%axis('auto'); % take out for now
%xlim([-0.2, 1.4]);
%ylim([-0.1, 0.25]);

grid on;
xlabel('X Position (m)');
ylabel('Y Position (m)');
% title('2D Truss Comparison'); % inclduing outside due to different cases

 hold on; % KEEP HOLD ON INCASE THE FUNCTION IS CALLED AGAIN OR CHANGE 

end
