function truss_d(file_name);
% OPEN DATA FILE
angle=58.01;
    fid = fopen(file_name, 'r');
    % READ DATA - READ NODE DATA - First read the number of nodes in the truss
    Number_nodes=fscanf(fid, '%d', 1);
    % Read the coordinates for each node
    for i=1:Number_nodes
     Node=fscanf(fid, '%d', 1);
     Coordinate(Node, 1)=fscanf(fid, '%g', 1);
     Coordinate(Node, 2)=fscanf(fid, '%g', 1);
     %the negative one tells it to rebilt that part of the 8x2 matrix in the
     %2nd columb
         if Coordinate(Node,2)==-1
         opposite=120*tand(angle);
         Coordinate(Node,2)=opposite;
         end
    end
    
    % READ DATA - READ ELEMENT DATA - Now read the number of elements and the
    % element definition
    Number_elements=fscanf(fid, '%d', 1);
    M=zeros(2*Number_nodes, 2*Number_nodes);
    for i=1:Number_elements
     Element=fscanf(fid, '%d', 1);
     Node_from=fscanf(fid, '%d', 1);
     Node_to=fscanf(fid, '%d', 1);
    
     dx=Coordinate(Node_to,1)-Coordinate(Node_from,1);
     dy=Coordinate(Node_to,2)-Coordinate(Node_from,2);
     Length=sqrt(dx^2 + dy^2);
    
     M(2*Node_from-1,Element) = dx/Length;
     M(2*Node_to-1, Element) = -dx/Length;
     M(2*Node_from, Element) = dy/Length;
     M(2*Node_to, Element) = -dy/Length;
    end
    
    % READ DATA - READ REACTION DATA - Now read in the reactions
    Number_reactions = fscanf(fid, '%d', 1);
    if (2*Number_nodes ~= (Number_elements + Number_reactions)) error('Invalid number of nodes, elements, and reactions'); end
    for i=1:Number_reactions;
     Reaction = fscanf(fid, '%d', 1);
     Node=fscanf(fid, '%d', 1);
     Direction = fscanf(fid, '%s', 1);
     if ((Direction == 'y') || (Direction == 'Y'))
     M(2*Node, Number_elements+Reaction)=M(2*Node,Number_elements+Reaction)+1;
     elseif ((Direction == 'x')||(Direction == 'X'))
     M(2*Node-1, Number_elements+Reaction)=M(2*Node-1,Number_elements+Reaction)+1;
     else
     error('Invalid direction for reaction')
     end
    end
    % READ DATA - READ EXTERNAL FORCE DATA - Now read in the external forces
    External=zeros(2*Number_nodes,1);
    Number_forces=fscanf(fid, '%d', 1);
    for i=1:Number_forces
     Node =fscanf(fid, '%d', 1);
     Force=fscanf(fid, '%g', 1);
     Direction = fscanf(fid, '%g', 1);
     External(2*Node-1)=External(2*Node-1)-Force*cos(Direction*(pi/180)); External(2*Node) =External(2*Node) -Force*sin(Direction*(pi/180));end
    
    External;
    % COMPUTE FORCES - Solve the system of equations
    A=M\External;
    % REPORT FORCES - FORCES IN THE ELEMENTS
%{
    for i = 1:Number_elements
     fprintf('Element %d = %g \n', i, A(i))
     end
    % REPORT FORCES - REACTION FORCES
    for i = 1:Number_reactions
     fprintf('Reaction %d = %g \n', i, A(Number_elements + i)) 
    end
%}
[weight,Area]=truss_tron_3000(A, Coordinate)
Forces=A([1:13]);
E=29.5e6;
Stress=Forces./Area;
displacment=abs(Forces/(Area*E));
displacment=displacment(:,1);
 
The_Element=[' 1 (AB)';' 2 (AC)';' 3 (BC)';' 4 (BD)';' 5 (BE)';' 6 (CE)';' 7 (DE)';' 8 (DF)';' 9 (EF)';'10 (EG)';'11 (FG)';'12 (FH)';'13 (GH)'];
The_Starting_Node=[' 1 (A)';' 1 (A)';' 6 (B)';' 6 (B)';' 6 (B)';' 2 (C)';' 7 (D)';' 7 (D)';' 3 (E)';' 3 (E)';' 8 (F)';' 8 (F)';' 4 (G)'];
The_Ending_Node=  [' 6 (B)';' 2 (C)';' 2 (C)';' 7 (D)';' 3 (E)';' 3 (E)';' 3 (E)';' 8 (F)';' 8 (F)';' 4 (G)';' 4 (G)';' 5 (H)';' 5 (H)'];

Table=table(The_Element,The_Starting_Node,The_Ending_Node,Forces,Area,Stress,displacment)
end