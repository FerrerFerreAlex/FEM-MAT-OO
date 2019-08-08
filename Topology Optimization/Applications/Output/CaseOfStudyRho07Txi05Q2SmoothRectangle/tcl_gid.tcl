GiD_Process PostProcess 
set arg1 " /home/alex/git-repos/SwanLab/Swan/Topology Optimization/Applications/Output/CaseOfStudyRho07Txi05Q2SmoothRectangle/CaseOfStudyRho07Txi05Q2SmoothRectangle1.flavia.res"
set arg2 "/home/alex/git-repos/SwanLab/Swan/Topology Optimization/Applications/Output/CaseOfStudyRho07Txi05Q2SmoothRectangle/Video_StressStressBasis1SxCaseOfStudyRho07Txi05Q2SmoothRectangle_1.gif"
set arg3 "StressStressBasis1"
set arg4 "Sx"
set arg5 "/home/alex/git-repos/SwanLab/Swan/Topology Optimization/Applications/Output/CaseOfStudyRho07Txi05Q2SmoothRectangle/StressStressBasis1SxCaseOfStudyRho07Txi05Q2SmoothRectangle.png"
set arg6 "NumericalHomogenizer"
source "/home/alex/git-repos/SwanLab/Swan/Topology Optimization/Applications/PostProcess/VideoMaker/Make_Video_standardField.tcl"
Make_Video_standardField $arg1 $arg2 $arg3 $arg4 $arg5 $arg6
GiD_Process Mescape Quit
