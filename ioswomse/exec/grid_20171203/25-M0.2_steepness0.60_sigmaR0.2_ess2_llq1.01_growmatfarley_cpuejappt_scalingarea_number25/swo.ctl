#C control file created using the SS_writectl function in the R package r4ss
#C should work with SS version: SSv3.24
#C file write time: 2017-12-03 06:14:05
#
1 # N_Growth_Patterns
1 #_N_Morphs_Within_GrowthPattern
4 #_number of recruitment assignments (overrides GP*area*seas parameter values)
0 #_recruitment interaction requested
#_GP	seas	area
1	1	1	#_recr_dist_pattern1
1	1	2	#_recr_dist_pattern2
1	1	3	#_recr_dist_pattern3
1	1	4	#_recr_dist_pattern4
8 #_N_movement_definitions goes here if N_areas > 1
0.6 #_first age that moves (real age at begin of season, not integer) also cond on do_migration>0
#_move definition for seas, morph, source, dest, age1, age2
1	1	1	2	9	30	#_moveDef1
1	1	1	3	9	30	#_moveDef2
1	1	2	1	9	30	#_moveDef3
1	1	2	4	9	30	#_moveDef4
1	1	3	1	9	30	#_moveDef5
1	1	3	4	9	30	#_moveDef6
1	1	4	2	9	30	#_moveDef7
1	1	4	3	9	30	#_moveDef8
0 #_Nblock_Patterns
#_Cond 0 #_blocks_per_pattern
# begin and end years of blocks
#
0.5 #_fracfemale
0 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate
#_Age_natmort_by gender x growthpattern
1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_speciific_K; 4=not implemented
0.01 #_Growth_Age_for_L1
999 #_Growth_Age_for_L2 (999 to use as Linf)
0 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)
0 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)
3 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity by GP; 4=read age-fecundity by GP; 5=read fec and wt from wtatage.ss; 6=read length-maturity by GP
#_Age_0	Age_1	Age_2	Age_3	Age_4	Age_5	Age_6	Age_7	Age_8	Age_9	Age_10	Age_11	Age_12	Age_13	Age_14	Age_15	Age_16	Age_17	Age_18	Age_19	Age_20	Age_21	Age_22	Age_23	Age_24	Age_25	Age_26	Age_27	Age_28	Age_29	Age_30
0.001	0.006	0.027	0.109	0.354	0.711	0.917	0.98	0.996	0.999	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	#_Age_Maturity1
1 #_First_Mature_Age
1 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W
0 #_hermaphroditism option:  0=none; 1=age-specific fxn
1 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)
1 #_env/block/dev_adjust_method (1=standard; 2=logistic transform keeps in base parm bounds; 3=standard w/ no bound check)
#
#_growth_parms
#_LO	HI	INIT	PRIOR	PR_type	SD	PHASE	env_var	use_dev	dev_minyr	dev_maxyr	dev_stddev	Block	Block_Fxn
