classdef Hexahedra_Linear < Interpolation
    properties
    end
    methods
        %constructor
        function obj=Hexahedra_Linear(mesh)
            obj = obj@Interpolation(mesh);
            obj.type = 'HEXAHEDRA';
            obj.order = 'LINEAR';
            obj.ndime = 3;          % 1D/2D/3D
            obj.nnode = 8;
            obj.dvolu = 8;
            obj.pos_nodes=[-1 -1 -1;
                +1 -1 -1;
                +1 +1 -1;
                -1 +1 -1;
                -1 -1 +1;
                +1 -1 +1;
                +1 +1 +1;
                -1 +1 +1];
            obj.iteration=[1 1 1 2 2 3 3 4 5 5 6 7;
                2 4 5 3 6 4 7 8 6 8 7 8];  
            %Case 1 to 8: Node i different
            %Case 9 to 20: Nodes iteration(:,i) different
            %Case 21 to 45: Three consecutive nodes equal 
            obj.cases(:,:,1)=[
                10     8    11     7
                5    11     8     6
                4     8    10     3
                6    11     8     7
                10     7     9     3
                10     8     7     3
                9     7     6     3
                9     6     2     3
                9     7    11     6
                10     7    11     9
                10    11     1     9;
                zeros(4,4)];                    
            obj.cases(:,:,2)=[
                4    10     8     9
                4     5     1     9
                4     8     5     9
                7    10     8     3
                4     3     8    10
                11     5     8     9
                10    11     8     9
                2    11    10     9
                7    11     8    10
                7     6     8    11
                6     5     8    11;
                zeros(4,4)];
            obj.cases(:,:,3)=[
                11     5     8    10
                4     5     1    10
                4     8     5    10
                6     5     8    11
                9    11     3    10
                7     6     8    11
                9     5    11    10
                1     5     9    10
                1     5     2     9
                2     5     6     9
                6     5    11     9;
                zeros(4,4)];
            obj.cases(:,:,4)=[
                11     6     5     9
                10     9     2     6
                10     6     2     3
                9     5     2     6
                10     7     6     3
                11     8     5     6
                11     7     6    10
                11     8     6     7
                11     9     4    10
                11     6     9    10
                9     5     1     2;
                zeros(4,4)];
            obj.cases(:,:,5)=[
                11     5     9    10
                11    10     9     3
                4     8    11     3
                4     9     2     3
                4    11     9     3
                11     8     7     3
                2     9    10     3
                10     7     6     3
                11     7    10     3
                2    10     6     3
                4     9     1     2;
                zeros(4,4)];
            obj.cases(:,:,6)=[
                4     5     1    10
                4     3     8    11
                4     9     3    11
                4     8     5    10
                4     9    11    10
                3     7     8    11
                4    11     8    10
                4     1     9    10
                11     9     6    10
                4     2     3     9
                4     1     2     9;
                zeros(4,4)];
            obj.cases(:,:,7)=[
                4     5     1    11
                4     8     5    11
                4     1     2     9
                4     2     3     9
                4     1     9    11
                1     5    10    11
                9    10     7    11
                1    10     9    11
                2     5     6    10
                1     5     2    10
                1     2     9    10;
                zeros(4,4)];
            obj.cases(:,:,8)=[
                7     6    11     3
                6     2    10    11
                9    10     2    11
                6     2    11     3
                9    11     2     3
                9     2     4     3
                9     1     4     2
                5     2    10     6
                9     8    10    11
                5     1    10     2
                9    10     1     2;
                zeros(4,4)];
            obj.cases(:,:,9)=[
                9     8    12    11
                4     8     9    11
                9    12     2    11
                4     3     8    11
                3     7     8    11
                7    12     8    11
                6    12     8     7
                9    10     1     2
                5    12     8     6
                5    10     8    12
                9     8    10    12
                9    10     2    12
                zeros(3,4)];
            obj.cases(:,:,10)=[
                12     9     4    11
                2     6     3    11
                12     6    10     9
                12     5    10     6
                9     6     2    11
                12     8     5     6
                12     6     9    11
                12    10     4     9
                6     7     3    11
                12     7     6    11
                12     8     6     7
                4    10     1     9
                zeros(3,4)];
            obj.cases(:,:,11)=[
                9    12    11     3
                4    12    10     3
                8     7    12     3
                9    12     5    11
                4     8    12     3
                10    12     9     3
                9    11     2     3
                7     6    11     3
                6     2    11     3
                7    11    12     3
                10     5     1     9
                10    12     5     9
                zeros(3,4)];
            obj.cases(:,:,12)=[
                11     4     9     8
                1     5     9     4
                4     5     9     8
                5    10     9     8
                5     6    10     8
                2    11     9    10
                10    11     9     8
                6     7    12     8
                10     6    12     8
                12    11    10     8
                3    11    10    12
                3    11     2    10
                zeros(3,4)];
            obj.cases(:,:,13)=[
                9     5    11     8
                4     5     9     8
                1     5     9     4
                7     3    12     8
                3    10    12     8
                12    10    11     8
                10     9    11     8
                10     4     9     8
                3     4    10     8
                2     9    11    10
                6     2    11    10
                6    10    11    12
                zeros(3,4)];
            obj.cases(:,:,14)=[
                12    11    10     3
                5     2     9     6
                12     8     5     6
                12     5     9     6
                12    10     4     3
                12     9     4    10
                8     7     6    11
                12     8     6    11
                5     1     9     2
                12     6     9    10
                10     6     9     2
                12     6    10    11
                zeros(3,4)];
            obj.cases(:,:,15)=[
                10     5    12     8
                4     5    10     8
                1     5    10     4
                10     5     1     9
                12     5    10     9
                12     9    10     3
                9     5     2     6
                9     5     1     2
                11     5     9     6
                12     5     9    11
                12     9     3    11
                12    11     3     7
                zeros(3,4)];
            obj.cases(:,:,16)=[
                12     7     6     3
                4    11     9    10
                4     8    11    10
                11     2     9    10
                11     8    12    10
                11    12     2    10
                11    12     6     2
                11     5     2     6
                12     3     6     2
                12     3     2    10
                5     1     9     2
                11     5     9     2
                zeros(3,4)];
            obj.cases(:,:,17)=[
                11     6    10    12
                4    12    10     3
                12     8     7     3
                4    11     9    10
                4     8    12     3
                4     8    11    12
                4    11    10    12
                4    10     2     3
                4     9     1     2
                11     5     9    10
                11     5    10     6
                4     9     2    10
                zeros(3,4)];
            obj.cases(:,:,18)=[
                12     6     2     3
                12     7     6     3
                10    12     2     3
                10     2     4     3
                10    12    11     2
                10     8     5    11
                10     5     9    11
                12     6    11     2
                10     8    11    12
                10    11     9     2
                10     9     4     2
                4     9     1     2
                zeros(3,4)];
            obj.cases(:,:,19)=[
                12     4    11     8
                1     5    11     4
                4     5    11     8
                10     4     9    12
                7    10     6    12
                9     4    11    12
                6    10     9    12
                3     9    10     4
                6     9    11    12
                3     2     9     4
                2     1     9     4
                9     1    11     4
                zeros(3,4)];
            obj.cases(:,:,20)=[
                6     2    11    12
                10     8    11    12
                10     9     2     3
                10    12     2     9
                10    11     2    12
                10     2     4     3
                10     8    12     9
                8     7    12     9
                5     2    11     6
                10     1     4     2
                10    11     1     2
                5     1    11     2
                zeros(3,4)];
            obj.cases(:,:,21)=[
                5    10     8    11
                11    10     8    13
                7     6     8    13
                6     5     8    11
                6    11     8    13
                9    10     1     2
                9    11     2    12
                12    13    11     3
                9    10     2    11
                12    11     2     3
                12     8    10    13
                12    13    10    11
                9    12    10    11
                4     8     9    12
                9     8    10    12
                ];            
            obj.cases(:,:,22)=[
                13     9     4    12
                11     8     6     7
                4     9     1    12
                10     7     3    12
                1     9    10    12
                13     7    11    12
                11     8     5     6
                13    11     9    12
                11     7    10    12
                13     5     9    11
                13     8     5    11
                13     8    11     7
                10     9    11    12
                2     9    11    10
                1     9     2    10                
                ];            
            obj.cases(:,:,23)=[
                8     7    10     3
                9    13    12    11
                8     7    13    10
                7    12    13    11
                9    12     1    11
                6    12     7    11
                4     8    10     3
                4     8    13    10
                4    13     9    10
                9    13     5    12
                9     5     1    12
                7    11    13    10
                9    13    11    10
                9    11     2    10
                9    11     1     2                
                ];            
            obj.cases(:,:,24)=[
                9     8    10    12
                4     8    11     3
                5    10     8    12
                7    13     8     3
                11    12     6    13
                9    12    11    13
                11     8     9    13
                11     8    13     3
                9     8    12    13
                9    10     1     2
                4     8     9    11
                9    10     2    11
                11    10     2    12
                2    12     6    11
                9    10    11    12                
                ];
            obj.cases(:,:,25)=[
                13     6    10    12
                13    12    11     3
                13     8     6    12
                9     6     2    11
                7     6     8    12
                10     6    11    12
                13    11     4     3
                13    12    10    11
                13     8     5     6
                13     5    10     6
                13    10     4     9
                4    10     1     9
                13     9     4    11
                13    11    10     9
                10     6     9    11                
                ];
            obj.cases(:,:,26)=[
                10     7    12     6
                12     2    10     6
                11     7    12    10
                12     9    10     2
                10     7     6     3
                11     8    13     7
                11     7    13    12
                6     2    10     3
                5     9    13    12
                11    13     9    12
                11    12     9    10
                11     9     4    10
                5     1    13     9
                11    13     1     9
                11     1     4     9                
                ];
            obj.cases(:,:,27)=[
                12     6     9    13
                4    12    10    11
                11    13     2     3
                11    13     9     2
                4     8    12    11
                13     7     6     3
                11     8    12    13
                2    13     9     6
                2    13     6     3
                12     5    10     6
                11    12     9    13
                11    12    10     9
                12     6    10     9
                4    10     9    11
                4    10     1     9
                ];
            obj.cases(:,:,28)=[
                10     7    12     6
                12     2    10     6
                11     7    12    10
                12     9    10     2
                10     7     6     3
                11     8    13     7
                11     7    13    12
                6     2    10     3
                5     9    13    12
                11    13     9    12
                11    12     9    10
                11     9     4    10
                5     1    13     9
                11    13     1     9
                11     1     4     9
                ];
            obj.cases(:,:,29)=[
                13     8     7     3
                9    11     2     3
                12     6    11    13
                13    11    10     3
                4     8    13     3
                4    13    10     3
                4    12    10    13
                4     8    12    13
                11     9    10     3
                12    11    10    13
                12     5    11     6
                12     5     9    11
                12     9    10    11
                12     5    10     9
                5     1    10     9                
                ];            
            obj.cases(:,:,30)=[
                11    10     4     3
                13     7     6     3
                13     6    12     2
                13     2    12     9
                11     5    10    12
                13     6     2     3
                13     2     9     3
                1    10     5     9
                9    10     5    12
                11     8    12    13
                11     8     5    12
                11    12     9    13
                11    13     9     3
                11     9    10     3
                11    12    10     9                
                ];
            obj.cases(:,:,31)=[
                13    10     4     3
                8     6    11    12
                13    12    10     3
                8     6     5    11
                8     7     6    12
                2     9    11     3
                1    10     5     9
                13     8    11    12
                13     8     5    11
                13     5    10     9
                13     9    10    12
                9    10    12     3
                11     9    12     3
                13     5     9    11
                13    11     9    12                
                ];                        
            obj.cases(:,:,32)=[
                9     4     5     8
                9     1     5     4
                4     9    10     8
                10    12    13     8
                7    11    13     8
                10     9    12     8
                12     9     5     8
                10    13    11     8
                10     9     2    11
                10     2     3    11
                2     9    13    11
                10     9    11    13
                10     9    13    12
                2     9    12    13
                6     2    12    13                
                ];
            obj.cases(:,:,33)=[
                3    12     7    13
                9    10     2    11
                2    10     3    11
                11    12     3    13
                10     5     6    12
                10    12     3    11
                11    10    12    13
                10     5    12    13
                8     9     4    11
                8     9    11    13
                11     9    10    13
                9     5    10    13
                8     5     9    13
                8     5     4     9
                5     1     4     9                
                ];           
            obj.cases(:,:,34)=[
                8    12     4    11
                8     7    13     3
                5    10    12     6
                8    11     4     3
                6    10    12    13
                11    12     9    13
                4    12     9    11
                9     6    11    13
                8    13    11     3
                10     6     9    13
                9    12    10    13
                4    12    10     9
                4    10     1     9
                9     6     2    11
                8    12    11    13                
                ];
            obj.cases(:,:,35)=[
                9     4     5     8
                9     1     5     4
                11    10    12    13
                6    11    12    13
                9     4     8    13
                10     9    12    13
                2     9    12    10
                7    11     6    13
                9     8    12    13
                9     8     5    12
                4    10    11    13
                4     9    10    13
                4    10     3    11
                6    10    12    11
                6     2    12    10                
                ];
            obj.cases(:,:,36)=[
                13    12    10     3
                13     7    12     3
                11    13    10     3
                11     8     5    13
                11     5     9    13
                11    10     4     3
                5     2     9     6
                5     6     9    12
                5    12     9    13
                5     1     9     2
                11     9     4    10
                11    13     9    10
                13    12     9    10
                12     6     9    10
                10     6     9     2                
                ];                     
            obj.cases(:,:,37)=[
                4    13     9    11
                11    10     6    13
                2    12     6    10
                7     6    13    11
                4    11    10     3
                4     8    12    13
                4    12     9    13
                10    12     6    13
                2    12     5     6
                9    12     5     2
                9     5     1     2
                9    10    11    13
                9    12    10    13
                9    12     2    10
                4    11     9    10                
                ];            
            obj.cases(:,:,38)=[
                7    10     6    13
                11     4    12     8
                1     5    12     4
                4     5    12     8
                13    11    12     8
                11     1    12     4
                6    10    12    13
                2     1    10     9
                10    11    12    13
                9    11    10    13
                9     1    10    11
                10     1    12    11
                7     9    10    13
                7     3     9    13
                3    11     9    13                
                ];            
            obj.cases(:,:,39)=[
                9     1    12    10
                7     3    13    10
                13     9    12    10
                11     1     4    10
                11    12     1    10
                11    13    12    10
                6     9    12    13
                11     7    13    10
                6     2    12     9
                2     1    12     9
                13     3     9    10
                11     8    13     7
                11     8    12    13
                5     2    12     6
                5     1    12     2                
                ];            
            obj.cases(:,:,40)=[
                9    12     2    11
                13    12    11     2
                12    10     8    13
                9     8    10    13
                7     6    13     3
                13     6     2     3
                13     2    11     3
                4     8     9    11
                9     8    13    11
                9    13    10    12
                5    10     8    12
                9    13    12    11
                13    12     2     6
                9    10     2    12
                9    10     1     2
                ];            
            obj.cases(:,:,41)=[
                10    11    13     2
                10    12    13    11
                8    13    12    11
                9    13     2    10
                10    11     2     3
                10     8    12    11
                8     7    13    11
                9    12    13    10
                4     8    12    10
                4    12     9    10
                2    12     5     6
                2    12     6    13
                9    12     2    13
                9    12     5     2
                9     5     1     2                
                ];            
            obj.cases(:,:,42)=[
                5    10    12     6
                4    11    10     3
                6    10    12    13
                4    12     9    13
                4    11     9    10
                8    12     4    13
                11    13     9    10
                4    13     9    11
                10     9    12    13
                5     9    12    10
                4    10     2     3
                4     9     2    10
                4     9     1     2
                6    11    13     7
                6    10    13    11                
                ];            
            obj.cases(:,:,43)=[
                12     5     9    10
                10    13    12     3
                11    13    10     3
                13     7    12     3
                11     5     9    13
                11     2     4     3
                11     8     5    13
                10    13     9    12
                11    10     2     3
                13     5     9    12
                4     9     1     2
                11     9     4     2
                11    13     9    10
                11    10     9     2
                12     5    10     6                
                ];            
            obj.cases(:,:,44)=[
                11    13     9    10
                11    12     9    13
                9    13    12     2
                9    10    13     2
                11     8    12    13
                7    13     8    10
                11     8    13    10
                12    13     6     2
                11     8     5    12
                11     5     9    12
                11     2     4     3
                11    10     2     3
                11    10     9     2
                4     9     1     2
                11     9     4     2                
                ];
            obj.cases(:,:,45)=[
                12    10     6     9
                8     7    13    10
                11    13    12    10
                11    12     9    10
                6    12     7    10
                7    12    13    10
                11     8    13    10
                11     9     2     3
                5     1    13    12
                11    13     1    12
                11    10     9     3
                11     2     4     3
                11     1     4     2
                11     9     1     2
                11    12     1     9                
                ];
            obj.cases(:,:,46)=[
                10    11     6    12
                8     7    12     3
                10     8    12     3
                10     8    11    12
                4     8    10     3
                2    11     5     6
                9     5     1     2
                9    11     5     2
                4    11     9    10
                9    11     2    10
                2    11     6    10
                4     8    11    10                
                zeros(3,4)]; 
            obj.cases(:,:,47)=[
                1     5     9     4
                10    11     2    12
                5    11     9     8
                5     8     9     4
                9     8    10     4
                9    11    10     8
                10    11    12     8
                9    11     2    10
                10     2     3    12
                2     6     3    12
                3     6     7    12
                2    11     6    12
                zeros(3,4)];
            obj.cases(:,:,48)=[
                10     8     6    11
                7     6     8    11
                12     2     4     3
                12    10     2     3
                10     8     5     6
                12     8    10    11
                12    11    10     3
                4     9     1     2
                12     9     4     2
                12    10     9     2
                12     5     9    10
                12     8     5    10                
                zeros(3,4)];
            
            obj.main_loop=[11 4];
            obj.extra_cases=[9:20];
            obj.selectcases=zeros(35,93,7);
            obj.selectcases(1,1,1)=1;
            obj.selectcases(2,2,1)=2;
            obj.selectcases(3,4,1)=3;
            obj.selectcases(4,7,1)=4;
            obj.selectcases(5,11,1)=5;
            obj.selectcases(6,16,1)=6;
            obj.selectcases(7,23,1)=7;
            obj.selectcases(8,30,1)=8;
            obj.selectcases(35,93,7)=1;
            obj.selectcases(34,92,7)=2;
            obj.selectcases(33,90,7)=3;
            obj.selectcases(32,87,7)=4;
            obj.selectcases(31,83,7)=5;
            obj.selectcases(30,78,7)=6;
            obj.selectcases(29,71,7)=7;
            obj.selectcases(28,64,7)=8;
            obj.selectcases(3,3,2)=9;
            obj.selectcases(33,91,6)=9;
            obj.selectcases(5,8,2)=10;
            obj.selectcases(31,86,6)=10;
            obj.selectcases(6,12,2)=11;
            obj.selectcases(30,82,6)=11;
            obj.selectcases(5,6,2)=12;
            obj.selectcases(31,88,6)=12;
            obj.selectcases(8,18,2)=13;
            obj.selectcases(28,76,6)=13;
            obj.selectcases(7,11,2)=14;
            obj.selectcases(29,83,6)=14;
            obj.selectcases(10,27,2)=15;
            obj.selectcases(26,67,6)=15;
            obj.selectcases(12,37,2)=16;
            obj.selectcases(24,57,6)=16;
            obj.selectcases(11,27,2)=17;
            obj.selectcases(25,67,6)=17;
            obj.selectcases(13,41,2)=18;
            obj.selectcases(23,53,6)=18;
            obj.selectcases(13,39,2)=19;
            obj.selectcases(23,55,6)=19;
            obj.selectcases(15,23,2)=20;
            obj.selectcases(21,41,6)=20;
            obj.selectcases(6,7,3)=21;
            obj.selectcases(30,87,5)=21;
            obj.selectcases(7,10,3)=22;
            obj.selectcases(29,84,5)=22;
            obj.selectcases(8,14,3)=23;
            obj.selectcases(28,80,5)=23;
            obj.selectcases(9,19,3)=24;
            obj.selectcases(27,75,5)=24;
            obj.selectcases(8,12,3)=25;
            obj.selectcases(28,82,5)=25;
            obj.selectcases(10,19,3)=26;
            obj.selectcases(26,75,5)=26;
            obj.selectcases(13,38,3)=27;
            obj.selectcases(23,56,5)=27;
            obj.selectcases(6,12,2)=28;
            obj.selectcases(30,82,6)=28;
            obj.selectcases(12,28,3)=29;
            obj.selectcases(24,66,5)=29;
            obj.selectcases(14,42,3)=30;
            obj.selectcases(22,52,5)=30;
            obj.selectcases(9,13,3)=31;
            obj.selectcases(27,81,5)=31;
            obj.selectcases(11,22,3)=32;
            obj.selectcases(25,72,5)=32;
            obj.selectcases(12,29,3)=33;
            obj.selectcases(24,65,5)=33;
            obj.selectcases(13,29,3)=34;
            obj.selectcases(23,65,5)=34;
            obj.selectcases(15,41,3)=35;
            obj.selectcases(21,53,5)=35;
            obj.selectcases(14,34,3)=36;
            obj.selectcases(22,60,5)=36;
            obj.selectcases(15,41,3)=37;
            obj.selectcases(21,53,5)=37;
            obj.selectcases(16,43,3)=38;
            obj.selectcases(20,51,5)=38;
            obj.selectcases(18,57,3)=39;
            obj.selectcases(18,37,5)=39;
            obj.selectcases(17,48,3)=40;
            obj.selectcases(19,46,5)=40;
            obj.selectcases(19,60,3)=41;
            obj.selectcases(17,34,5)=41;
            obj.selectcases(18,50,3)=42;
            obj.selectcases(18,44,5)=42;
            obj.selectcases(19,57,3)=43;
            obj.selectcases(17,37,5)=43;
            obj.selectcases(20,64,3)=44;
            obj.selectcases(16,30,5)=44;
            obj.selectcases(21,69,3)=45;
            obj.selectcases(15,25,5)=45;
            obj.selectcases(14,30,4)=46;
            obj.selectcases(22,64,4)=46;
            obj.selectcases(18,45,4)=47;
            obj.selectcases(18,49,4)=47;
            obj.selectcases(10,14,4)=48;
            obj.selectcases(26,80,4)=48;
        end
        function computeShapeDeriv(obj,posgp)
            obj.shape=[];
            obj.deriv=[];            
            s=posgp(1,:);
            t=posgp(2,:);
            u=posgp(3,:);
            lcord(1,1)= -1; lcord(1,2)= -1; lcord(1,3)= -1;
            lcord(2,1)=  1; lcord(2,2)= -1; lcord(2,3)= -1;
            lcord(3,1)=  1; lcord(3,2)=  1; lcord(3,3)= -1;
            lcord(4,1)= -1; lcord(4,2)=  1; lcord(4,3)= -1;
            lcord(5,1)= -1; lcord(5,2)= -1; lcord(5,3)=  1;
            lcord(6,1)=  1; lcord(6,2)= -1; lcord(6,3)=  1;
            lcord(7,1)=  1; lcord(7,2)=  1; lcord(7,3)=  1;
            lcord(8,1)= -1; lcord(8,2)=  1; lcord(8,3)=  1;
            for inode=1:obj.nnode
                obj.shape(inode,:)=(ones(1,size(posgp,2))+...
				    lcord(inode,1)*s).*(ones(1,size(posgp,2))+...
				    lcord(inode,2)*t).*(ones(1,size(posgp,2))+...
				    lcord(inode,3)*u)/8;
                obj.deriv(1,inode,:)=lcord(inode,1).*(ones(1,size(posgp,2))+lcord(inode,2)*t).*(ones(1,size(posgp,2))+lcord(inode,3)*u)/8;
                obj.deriv(2,inode,:)=lcord(inode,2).*(ones(1,size(posgp,2))+lcord(inode,1)*s).*(ones(1,size(posgp,2))+lcord(inode,3)*u)/8;
                obj.deriv(3,inode,:)=lcord(inode,3).*(ones(1,size(posgp,2))+lcord(inode,1)*s).*(ones(1,size(posgp,2))+lcord(inode,2)*t)/8;
            end
        end
    end
    
end
