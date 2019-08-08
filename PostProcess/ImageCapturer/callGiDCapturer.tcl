set path "/home/alex/git-repos/SwanLab/Swan/PostProcess/ImageCapturer/"
set tclFile "CaptureImage.tcl"
source $path$tclFile 
set output /home/alex/Dropbox/Amplificators/Images//home/alex/Dropbox/Amplificators/GregoireMeeting4/Rho07Txi05/CaseOfStudyRho07Txi05Q32SmoothRectangle/StressStressBasis1SxCaseOfStudyRho07Txi05Q32SmoothRectangleCrop.png 
set inputFile /home/alex/Dropbox/Amplificators/GregoireMeeting4/Rho07Txi05/CaseOfStudyRho07Txi05Q32SmoothRectangle/CaseOfStudyRho07Q32SmoothRectangle1.flavia.res
CaptureImage $inputFile $output 
