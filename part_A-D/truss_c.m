% truss - this program uses a matrix method to solve for the forces in% the members of a statically determinate truss. It also% computes the reaction forces.
%
% The program is started by typing
%
% truss('input_data_file.txt')
%
% at the MATLAB prompt. In this case the input data file is% named input_data_file.txt Any file name can be used. The % file is a common text file and can be created with NOTEPAD%
% Written by: Robert Greenlee
function truss_c(file_name)
% OPEN DATA FILE
w=[];
Ar=[];
for angle=58:.001:58.2
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
    [weight,Area]=truss_tron_3000(A, Coordinate);

    w=[w;[weight,angle]];
    Ar=[Ar,Area];
end
The_Angle=w(:,2);
The_Weight_lb=w(:,1);

%Table=table(The_Angle,The_Weight_lb);

figure;plot(The_Angle,The_Weight_lb,LineWidth=2,Color='k')
xlabel('Changing Angle (degree)')
ylabel('Weight(lb)')

[Minimum_Weight,id]=min(The_Weight_lb);
The_Min_Weight_Angle=The_Angle(11);

new_table=table(Minimum_Weight,The_Min_Weight_Angle)


end
