
function [obj] = SetParameter(obj, varargin)

ip = inputParser;
ip.CaseSensitive = true;
ip.addRequired('obj', @(x) isobject(x));
ip.addParameter('unit', [], @isobject);
ip.addParameter('close_surf', true, @islogical);
ip.addParameter('n_ico_sphere', 3, @isnumeric);
ip.addParameter('max_rep_allow', 5, @isnumeric);
ip.addParameter('dr', 0.0001, @isnumeric); %0.0001 l_bar(nat. unit)
ip.addParameter('ang_min',20,@isnumeric);
ip.addParameter('l0', 1, @isnumeric); % 1 l_bar(nat. unit)
ip.addParameter('kBT', 1, @isnumeric); % 1kBT at 300K
% ip.addParameter('gm', 1, @isnumeric);
ip.addParameter('k_c', 0, @isnumeric);% 10kBT at 300K
ip.addParameter('k_V', 0, @isnumeric);% 
ip.addParameter('k_A', 0, @isnumeric);% 
ip.addParameter('k_a', 0, @isnumeric);% 
ip.addParameter('V0', 150, @isnumeric);% 733.8 l_bar^3 for RBC
ip.addParameter('A0', 137, @isnumeric);% 553 l_bar^2 for RBC
ip.addParameter('nAVmean', 16, @isnumeric);% 
ip.addParameter('k_const', 0.2, @isnumeric);% 0.1kBT at 300K, namely V0 in V_in 
ip.addParameter('dt', 0.0001, @isnumeric);%s
ip.addParameter('nt', 10000, @isnumeric);
ip.addParameter('nt_relax', 1000, @isnumeric);
ip.addParameter('k_s', 1, @isnumeric);
ip.addParameter('k_e', 0, @isnumeric);
ip.addParameter('k_r', 1, @isnumeric);
ip.addParameter('kDiff', 1000000, @isnumeric);
% ip.addParameter('ah', 1, @isnumeric);
% ip.addParameter('bt', 2.1, @isnumeric);
ip.addParameter('split_or_not', true, @islogical);
ip.addParameter('merge_or_not', true, @islogical);
ip.addParameter('flip_bond', true, @islogical);
ip.addParameter('P', 0, @isnumeric);
ip.addParameter('n_val_max', 8, @isnumeric);
ip.addParameter('n_val_min', 5, @isnumeric);
ip.addParameter('Vdw_r_1',-0.05, @isnumeric); %-0.05 l0
ip.addParameter('Vdw_r_2', 2.2, @isnumeric); %2.2 l0
ip.addParameter('Vdw_rl_min', 0.8, @isnumeric); %0.7 l0
ip.addParameter('Vdw_rs_max', 0.1, @isnumeric); %0.1 l0
ip.addParameter('Vdw_r_best_min', 0.8, @isnumeric);%0.8 l0
ip.addParameter('Vdw_r_best_max', 1.2, @isnumeric);%1.2 l0
ip.addParameter('Vdw_rl_max', 1.2, @isnumeric);%1.3 l0
ip.addParameter('Vdw_rd_min', 1.7, @isnumeric);%1.7 l0
ip.addParameter('Vdw_rb_11', 0.05, @isnumeric);%0.05 l0
ip.addParameter('Vdw_rb_12', 0.75, @isnumeric);%0.75 l0
ip.addParameter('Vdw_rb_21', 1.25, @isnumeric);%1.25 l0
ip.addParameter('Vdw_rb_22', 1.75, @isnumeric);%1.75 l0
ip.addParameter('Vdw_k_b11',50, @isnumeric);
ip.addParameter('Vdw_k_b12',25, @isnumeric);
ip.addParameter('Vdw_k_b21',25, @isnumeric);
ip.addParameter('Vdw_k_b22',50, @isnumeric);
ip.addParameter('Vdw_e_b1',1, @isnumeric);
ip.addParameter('Vdw_e_b2',1, @isnumeric);
ip.addParameter('Vdw_k_w',100, @isnumeric);
ip.addParameter('Vdw_e_w',2, @isnumeric);
ip.addParameter('col_min',0., @isnumeric);
ip.addParameter('col_max',1.5, @isnumeric);
ip.addParameter('plot_or_not',false, @islogical);
ip.addParameter('r_plane',0.2, @isnumeric);
ip.addParameter('f_const_rsq_std',0.5, @isnumeric);
ip.addParameter('f_const_std_std',0.001, @isnumeric);
ip.addParameter('remeshScheme',1, @isnumeric); %0: bondFlip only, 1:bondFlip and slipMerge, 2: slipMerge only
ip.addParameter('D',1.0000e-07, @isnumeric); % previous (0.0001cm)^2/s diffusion coefficient
ip.parse(obj, varargin{:});
%--------------------------------------------------------------------------------------------------------
plot_or_not=ip.Results.plot_or_not;
unit=ip.Results.unit;
%================================================================================
% gm = 1/(3*ip.Results.ah)*(ip.Results.bt^2-(ip.Results.bt-3*ip.Results.ah*ip.Results.l0^2)^2);

pm = struct(...
    'close_surf', ip.Results.close_surf,...
    'l0', ip.Results.l0,...
    'max_rep_allow', ip.Results.max_rep_allow,...
    'dr',ip.Results.dr,...
    'ang_min',ip.Results.ang_min,...
    'kBT',ip.Results.kBT,...
    'k_c', ip.Results.k_c,...
    'k_V', ip.Results.k_V,...
    'k_A', ip.Results.k_A,...
    'k_a',ip.Results.k_a,...
    'V0', ip.Results.V0,...
    'A0', ip.Results.A0,...
    'nAVmean', ip.Results.nAVmean,...
    'k_const', ip.Results.k_const,...
    'dt', ip.Results.dt,...
    'nt', ip.Results.nt,...
    'nt_relax',ip.Results.nt_relax,...
    'k_s', ip.Results.k_s,...
    'k_e', ip.Results.k_e,...
    'k_r', ip.Results.k_r,...
    'kDiff',ip.Results.kDiff,...
    'split_or_not', ip.Results.split_or_not,...
    'merge_or_not', ip.Results.merge_or_not,...
    'P', ip.Results.P,...
    'flip_bond',ip.Results.flip_bond,...
    'n_val_max',ip.Results.n_val_max,...
    'n_val_min',ip.Results.n_val_min,...
    'n_ico_sphere', ip.Results.n_ico_sphere, ...
    'Vdh', [],... %double hill
    'Vdw', [],... %double well
    'r_ext',[],...
    'col_min',ip.Results.col_min,...
    'col_max',ip.Results.col_max,...
    'f',[],...
    'r_plane',ip.Results.r_plane,...
    'f_const_rsq_std',ip.Results.f_const_rsq_std,...
    'f_const_std_std',ip.Results.f_const_std_std,...
    'remeshScheme',ip.Results.remeshScheme,...
    'mu',[] ...
     );
%==========================================================================
u=convert(unit,'energy',ComUnit.kBT_to_erg(pm.kBT,300));
pm.kBT=u.unit_nat.energy;
%--------------------------------------------------------------------------
u=convert(unit,'energy',ComUnit.kBT_to_erg(pm.k_c,300));
pm.k_c=u.unit_nat.energy;
%--------------------------------------------------------------------------
u=convert(unit,'energy',ComUnit.kBT_to_erg(pm.k_const,300));
pm.k_const=u.unit_nat.energy;
%==========================================================================
unit=convert_high_order(unit,ip.Results.D/unit.unit.kBT,2,-1); % D=mu*kBT
pm.mu=unit.unit_nat_any;
%==========================================================================            
 
if pm.nt_relax > pm.nt
    fprintf('wrong: relax time longer than total time\n')
end

pm.Vdh = struct('r_1', -0.05*pm.l0,...
                'r_2', 2.2*pm.l0,...
                'r_best_min', 0.7*pm.l0,...
                'r_best_max', 1.3*pm.l0,...
                'rl_min',0.7*pm.l0,...
                'rs_max',0.1*pm.l0,...
                'rl_max',1.3*pm.l0,...
                'rd_min',1.7*pm.l0,...
                'rb_11',0.05*pm.l0,...
                'rb_12',0.75*pm.l0,...
                'rb_21',1.25*pm.l0,...
                'rb_22',1.75*pm.l0,...
                'k_b11',50,...
                'k_b12',25,...
                'k_b21',25,...
                'k_b22',50,...
                'e_b1',1,...
                'e_b2',1,...
                'k_w', 100,...
                'e_w', 2 ,...
                'V0', pm.k_const ...
                );
            
pm.Vdw = struct('r_1', 0.85*pm.l0,...
                'r_2', 2.0*pm.l0,...
                'r_best_min', 0.85*pm.l0,...
                'r_best_max', 1.2*pm.l0,...
                'rl_max',1.25*pm.l0,...
                'rd_min',1.7*pm.l0,...
                'rb_21',1.2*pm.l0,...
                'rb_22',1.7*pm.l0,...
                'k_b21',50,...
                'k_b22',50,...
                'e_b2',1,...
                'k_w', 200,...
                'e_w', 2, ...
                'V0', pm.k_const ...
                );            
%--------------------------------------------------------------------------------------------------------
%%
obj.pm=pm;
%%
