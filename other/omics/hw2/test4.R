myArgs = commandArgs(TRUE)

outputRoot="./"
if(length(myArgs)>=2){
  outputRoot=myArgs[2] 
  # must end with /
  if(substring(outputRoot, nchar(outputRoot)) != "/"){
    outputRoot=paste0(outputRoot, "/")
  }
  # the dir must exist
  if(!dir.exists(outputRoot)){
    stop( sprintf("dir not exist, outputRoot=%s", outputRoot) )
  }
}
message( sprintf("settings: outputRoot=%s", outputRoot) )
