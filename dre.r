library(data.table)
library(glmnet)

n_perm=10000

args <- commandArgs()
name=args[4]

file=as.matrix(fread(name))
matrix=file[,-1]
drug_names=colnames(matrix)


write.table(x=t(c("drug_name","mean_prediction","stddev_prediction")),file="dre_output.txt",quote=FALSE,append=TRUE,sep="\t",col.names=FALSE,row.names=FALSE)

for (drug in 1:265){
	m_drug=na.omit(as.matrix(cbind(matrix[,1:17420],matrix[,17420+drug])))
	obs=dim(m_drug)[1]
	sub_matrix=c()
	for (i in 1:17420){
		m=cbind(m_drug[,i],m_drug[,drug])
		m_sorted=m[order(-m[,1]),]	
		m_tb=m_sorted[-(trunc(obs/10):(obs-trunc(obs/10))),]
		cor=cor(m_tb[,1],m_tb[,2])
		if (cor > 0.40 | cor < -0.40){
			sub_matrix=cbind(sub_matrix,m_drug[,i])
        
		}
	}
	sub_matrix=cbind(sub_matrix,m_drug[,17421])
	len<-dim(sub_matrix)[1]
	col<-dim(sub_matrix)[2]
	test<-trunc(len/10)
	v<-c()
	for (i in 1:n_perm){
		sub_matrix<-as.matrix(sub_matrix[sample(len),])
		IC50<-as.matrix(sub_matrix[,col])
		GE<-as.matrix(sub_matrix[,-col])
		i=1
		f<-test*2
		x<-as.matrix(GE[-c(i:f),])
		y<-as.matrix(IC50[-c(i:f),])
		if (dim(x)[2]<2){
			break
		}
		cvfit<-cv.glmnet(x,y)
		x_test<-as.matrix(GE[(1:test),])
		y_test<-as.matrix(IC50[(1:test),])
		pred<-predict(cvfit, x_test, s = "lambda.min")
		cor<-cor(pred,y_test)
		v<-union(cor,v)
	}
	row=c(drug_names[17420+drug],mean(as.numeric(v),na.rm=TRUE),sd(as.numeric(v),na.rm=TRUE))
	write.table(x=t(row),file="dre_output.txt",quote=FALSE,append=TRUE,sep="\t",col.names=FALSE,row.names=FALSE)
}
