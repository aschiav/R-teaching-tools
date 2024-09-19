

workers<-c(1,2)
output<-c(4,8)
output_per_worker<-output/workers
plot(workers, output, type="b")+title("group 1")
plot(workers, output_per_worker, type="b")+title("group 1")


workers<-c(1,2)
output<-c(2,8)
output_per_worker<-output/workers
plot(workers, output, type="b")+title("group 2")
plot(workers, output_per_worker, type="b")+title("group 2")
