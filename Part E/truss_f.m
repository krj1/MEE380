function truss_d(file_name_in, file_name_out);

% Constants from part d
angle=58.01;
E = 100e9;
Area = 0.0001;



% OPEN DATA FILE
fid = fopen(file_name_in, 'r');
% READ DATA - READ NODE DATA - First read the number of nodes in the truss
Number_nodes = fscanf(fid, '%d', 1);
% Read the coordinates for each node
for i=1:Number_nodes
    Node=fscanf(fid, '%d', 1);
    Coordinate(Node, 1) = fscanf(fid, '%g', 1);
    Coordinate(Node, 2) = fscanf(fid, '%g', 1);
    %the negative one tells it to rebilt that part of the 8x2 matrix in the
    %2nd columb
    if Coordinate(Node,2) == -1
        opposite=120*tand(angle);
        Coordinate(Node,2) = opposite;
    end
end

% READ DATA - READ ELEMENT DATA - Now read the number of elements and the
% element definition

Number_elements=fscanf(fid, '%d', 1);
M = zeros(Number_nodes, 2);
K = zeros(2*Number_nodes, 2*Number_nodes);





for i = 1:Number_elements
    Element = fscanf(fid, '%d', 1);
    Node_from = fscanf(fid, '%d', 1);
    Node_to = fscanf(fid, '%d', 1);
    
    dx = Coordinate(Node_to,1)-Coordinate(Node_from,1);
    dy = Coordinate(Node_to,2)-Coordinate(Node_from,2);
    Length = sqrt(dx^2 + dy^2);
    
    c = dx/Length; % cosine
    s = dy/Length; % sine
    %{
          M(2*Node_from-1,Element) = dx/Length;
     M(2*Node_to-1, Element) = -dx/Length;
     M(2*Node_from, Element) = dy/Length;
     M(2*Node_to, Element) = -dy/Length;
    %}
    M(i,1:2) = [Node_from, Node_to];
    ke = E*Area/Length*[c^2 c*s -c^2 -c*s;
        c*s s^2 -c*s -s^2;
        -c^2 -c*s c^2 c*s;
        -c*s -s^2 c*s s^2];
    
    ni = 2*M(i,1)-1; % map left node of the truss global dof
    nj = 2*M(i,2)-1; % map right node of the truss global dof
    % map local dof to global K, see eqn(3.37)
    K(ni:ni+1,ni:ni+1) = K(ni:ni+1,ni:ni+1)+ke(1:2,1:2);
    K(ni:ni+1,nj:nj+1) = K(ni:ni+1,nj:nj+1)+ke(1:2,3:4);
    K(nj:nj+1,ni:ni+1) = K(nj:nj+1,ni:ni+1)+ke(3:4,1:2);
    K(nj:nj+1,nj:nj+1) = K(nj:nj+1,nj:nj+1)+ke(3:4,3:4);
    
end

Number_reactions = fscanf(fid, '%d', 1);




BC = ones(2*Number_nodes, 1);

for i = 1:Number_reactions;
    Reaction = fscanf(fid, '%d', 1);
    Node=fscanf(fid, '%d', 1);
    Direction = fscanf(fid, '%s', 1);
    if ((Direction == 'y') || (Direction == 'Y'))
        BC(2*Node) = 0;
    elseif ((Direction == 'x')||(Direction == 'X'))
        BC(2*Node-1) = 0;
    else
        error('Invalid direction for reaction')
    end
end

% READ DATA - READ EXTERNAL FORCE DATA - Now read in the external forces
External = zeros(2*Number_nodes,1);
Number_forces = fscanf(fid, '%d', 1);
for i=1:Number_forces
    Node = fscanf(fid, '%d', 1);
    Force = fscanf(fid, '%g', 1);
    Direction = fscanf(fid, '%g', 1);
    
    Force = Force * 1000; % converting from kips to lbs
    
    forceX = Force * sind(Direction);
    forceY = Force * cosd(Direction);
    
    External(2*Node-1) = External(2*Node-1) + forceX;
    External(2*Node) = External(2*Node) - forceY;
end

for i = 1:height(BC)
    if BC(i) == 0
        K(i,:) = [];
        K(:,i) = [];
        External(i) = [];
    end
end




External
% COMPUTE FORCES - Solve the system of equations
A = K\External;

out = zeros(height(BC), 1);

tick = 1;
for i = 1:height(BC)
    if BC(i) ~= 0
        out(i) = A(tick);
        tick = tick + 1;
    end
end

% REPORT FORCES - FORCES IN THE ELEMENTS

tick = 1;
for i = 1:2:height(BC)
     fprintf('Element deformation in x %d = %g \n', tick, out(i))
     fprintf('Element deformation in y %d = %g \n', tick, out(i + 1))
     tick = tick + 1;
end

% output deformation text file


deformation = zeros(Number_nodes, 2);

tick = 1;
for i = 1:Number_nodes*2
    if mod(i,2) == 1
        deformation(tick, 1) = out(i);
    else
        deformation(tick, 2) = out(i);
        tick = tick + 1;
    end
    
end

Coordinate = Coordinate + deformation;



fid2 = fopen(file_name_out, 'w');
fprintf(fid2, '%g\n', Number_nodes);

for i = 1:Number_nodes
    %Node_r = fscanf(fid2, '%d', 1);
    fprintf(fid2, '%g', i);
    fprintf(fid2, '\40');
    fprintf(fid2, '%g', Coordinate(i, 1));
    fprintf(fid2, '\40');
    fprintf(fid2, '%g\15', Coordinate(i, 2));


end





fclose(fid2);
end % End of program



