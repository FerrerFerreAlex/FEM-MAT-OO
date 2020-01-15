%==================================================================
%                        General Data File
% Title: TRIANGLE
% Units: SI
% Dimensions: 2D
% Type of problem: Plane_Stress
% Type of Phisics: ELASTIC
% Micro/Macro: MACRO
%
%==================================================================

%% Data

Data_prb = {
'TRIANGLE';
'SI';
'2D';
'Plane_Stress';
'ELASTIC';
'MACRO';
};

%% Coordinates
% Node                X                Y                Z

coord = [
    1   0.0000000000   1.0000000000   0.0000000000
    2   0.7840364501   0.5000000000   0.0000000000
    3   0.0000000000   0.0000000000   0.0000000000
    4   1.5680729003   1.0000000000   0.0000000000
    5   1.5680729003   0.0000000000   0.0000000000
    6   2.2840364501   0.5000000000   0.0000000000
    7   3.0000000000   1.0000000000   0.0000000000
    8   3.0000000000   0.0000000000   0.0000000000
];

%% Conectivities
% Element        Node(1)                Node(2)                Node(3)                Material

connec = [
1 6 7 4 0
2 1 3 2 0
3 2 6 4 0
4 5 2 3 0
5 7 6 8 0
6 6 5 8 0
7 1 2 4 0
8 2 5 6 0
];

%% Variable Prescribed
% Node            Dimension                Value

dirichlet_data = [
   1 1 0
   1 2 0
   3 1 0
   3 2 0
];

%% Force Prescribed
% Node                Dimension                Value

pointload_complete = [
    7 2 -1
    8 2 -1
];

%% Volumetric Force
% Element        Dim                Force_Dim

Vol_force = [
];

%% Group Elements
% Element        Group_num

Group = [
];

%% Initial Holes
% Elements that are considered holes initially
% Element

Initial_holes = [
];

%% Boundary Elements
% Elements that can not be removed
% Element

Boundary_elements = [
];

%% Micro gauss post
%
% Element

Micro_gauss_post = [
];


%% Micro Slave-Master
% Nodes that are Slaves
% Nodes             Value (1-Slave,0-Master)

Micro_slave = [
];

%% Nodes solid
% Nodes that must remain
% Nodes

nodesolid = unique(pointload_complete(:,1));

%% External border Elements
% Detect the elements that define the edge of the domain
% Element               Node(1)           Node(2)

External_border_elements = [
];

%% External border Nodes
% Detect the nodes that define the edge of the domain
% Node

External_border_nodes = [
];

%% Materials
% Materials that have been used
% Material_Num              Mat_density        Young_Modulus        Poisson

Materials = [
];
