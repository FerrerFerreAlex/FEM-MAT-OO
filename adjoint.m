clc
clear variables
close all
% 
addpath(genpath(fileparts(mfilename('fullpath'))))
% run('test_fem.m')
%% Main.m

diff=1e10;
epsilon=1e-9;
% file_name='CantileverToy_Triangular';
% % file_name='cantilever_beam_LINEAR';
file_name='cantilever_test';
obj=solvePhysProblem(file_name);
coord_old=obj.mesh.coord;

nnodes=size(obj.mesh.coord,1);
ndim=size(obj.mesh.coord,2);

dfdu=zeros(nnodes*ndim,1);
dfdu(obj.dof.neumann)=1;
tic
lambda=zeros(nnodes*ndim,1);
lambda(obj.dof.free{1})=-obj.element.K(obj.dof.free{1},obj.dof.free{1})'\dfdu(obj.dof.free{1});
dfdx_dof=lambda'*computeAdjointGradient(obj,epsilon,obj.dof.dirichlet{1},file_name);
toc
for i_node=1:nnodes
    for i_dim=1:ndim
        gradient_adjoint(i_node,i_dim)=dfdx_dof(ndim*(i_node-1)+i_dim);
    end
end
tic
gradient=computeNumericalGradient(obj,epsilon,obj.dof.dirichlet{1},file_name);
toc
error_gradient=norm(gradient-gradient_adjoint)/norm(gradient);
l2_error=(norm(gradient)-norm(gradient_adjoint))/norm(gradient);
fprintf('Gradient error %f \nL-2 error %f \n',error_gradient,l2_error);

obj=Elastic_Problem(file_name);
obj.mesh.coord=coord_old+1e-6*gradient_adjoint;
coord_old=obj.mesh.coord;
obj.preProcess;
matProps = struct;
matProps.mu=1/3;
matProps.kappa=1;
obj.setMatProps(matProps)
obj.computeVariables;
obj.print('cantilever_test');
%     obj.print;
%     plot_geometry(obj.mesh.coord,obj.mesh.connec);
diff=norm(dfdx_dof);
f_obj=sum(obj.variables.d_u(obj.dof.neumann));
fprintf('Obj. func: %f, grad: %f \n \n',f_obj,diff);




function plot_geometry(coord,connec)
figure(1)
clf
hold on
    for i_elem=1:size(connec,1)
        for i_node=1:size(connec,2)
            if i_node==size(connec,2)
                i_node_next=1;
            else
                i_node_next=i_node+1;
            end
            x=[coord(connec(i_elem,i_node),1);coord(connec(i_elem,i_node_next),1)];
            y=[coord(connec(i_elem,i_node),2);coord(connec(i_elem,i_node_next),2)];
            plot(x,y,'r')         
        end
    end
drawnow update
end

function problem=solvePhysProblem(file_name)
    problem = Elastic_Problem(file_name);

    % obj.dof.neumann_values=1e-2;
    problem.preProcess;
    matProps = struct;
    matProps.mu=1/3;
    matProps.kappa=1;
    problem.setMatProps(matProps)
    problem.computeVariables;
end
function gradient=computeAdjointGradient(physProblem,epsilon,dirichlet_nodes,file_name)
    nnodes=size(physProblem.mesh.coord,1);
    ndim=size(physProblem.mesh.coord,2);
    d_u=physProblem.variables.d_u;
    fext_int=physProblem.element.K*d_u;

    gradient=zeros(nnodes*ndim,1);
 
    for i_node=1:nnodes
        for i_dim=1:ndim
            dof=ndim*(i_node-1)+i_dim;
            if ~any(dof==dirichlet_nodes)
                adjointProblem=Elastic_Problem(file_name);
                adjointProblem.mesh.coord=physProblem.mesh.coord;
                adjointProblem.mesh.coord(i_node,i_dim)=physProblem.mesh.coord(i_node,i_dim)+epsilon;
                adjointProblem.preProcess;
                matProps = struct;
                matProps.mu=1/3;
                matProps.kappa=1;
                adjointProblem.setMatProps(matProps)
                residual=(fext_int-adjointProblem.element.computeStiffnessMatrixSYM*d_u)/epsilon;
                gradient(:,dof)=residual; 
            else
                gradient(:,dof)=zeros(nnodes*ndim,1);
            end
        end
    end
end


function gradient=computeNumericalGradient(physProblem,epsilon,dirichlet_nodes,file_name)
    nnodes=size(physProblem.mesh.coord,1);
    ndim=size(physProblem.mesh.coord,2);
    f_initial=sum(physProblem.variables.d_u(physProblem.dof.neumann));
    gradient=zeros(nnodes,ndim);
    for i_node=1:nnodes
        for i_dim=1:ndim
            dof=ndim*(i_node-1)+i_dim;
            if ~any(dof==dirichlet_nodes)
                adjointProblem=Elastic_Problem(file_name);
                adjointProblem.mesh.coord=physProblem.mesh.coord;
                adjointProblem.mesh.coord(i_node,i_dim)=physProblem.mesh.coord(i_node,i_dim)+epsilon;
                adjointProblem.preProcess;
                matProps = struct;
                matProps.mu=1/3;
                matProps.kappa=1;
                adjointProblem.setMatProps(matProps);
                adjointProblem.computeVariables;
                gradient(i_node,i_dim)=(f_initial-sum(adjointProblem.variables.d_u(physProblem.dof.neumann)))/epsilon;%
            else
                gradient(i_node,i_dim)=0;
            end
        end
    end
end



