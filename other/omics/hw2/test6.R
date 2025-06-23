for(i in 1:10){
  Sys.sleep(runif(1)*0.5+0.5)
  message("[",Sys.time(), "]", i)
}
