L=5

rrr<-function(Y,T,X,p0,D_LB,D_add,max_iter,dict,lambda_minimax,mu_minimax,alpha_estimator,gamma_estimator,bias){
  
  n=nrow(X)
  folds <- split(sample(n, n,replace=FALSE), as.factor(1:L))
  
  Psi_tilde=numeric(0)
  
  for (l in 1:L){
    
    Y.l=as.matrix(Y[folds[[l]]])
    Y.nl=as.matrix(Y[-folds[[l]]])
    
    T.l=as.matrix(T[folds[[l]]])
    T.nl=as.matrix(T[-folds[[l]]])
    
    X.l=as.matrix(X[folds[[l]],])
    X.nl=as.matrix(X[-folds[[l]],])
    
    n.l=dim(T.l)[1]
    n.nl=dim(T.nl)[1]
    
    # get stage 1 (on nl)
    stage1_estimators<-get_stage1(Y.nl,T.nl,X.nl,p0,D_LB,D_add,max_iter,dict,lambda_minimax,mu_minimax,alpha_estimator,gamma_estimator)
    alpha_hat=stage1_estimators[[1]]
    gamma_hat=stage1_estimators[[2]]
    
    # debugging
    print(paste0('fold: ',l))
    #print(paste0('beta_hat: '))
    #print(paste0(round(beta_hat,2)))
    #print(paste0('rho_hat: '))
    #print(paste0(round(rho_hat,2)))
    
    #get stage 2 (on l)
    #psi_star
    if(bias){ #plug-in
        Psi_tilde.l=psi_tilde_bias(Y.l,T.l,X.l,m,alpha_hat,gamma_hat) # without subtracting theta_hat
    }else{ #DML
        Psi_tilde.l=psi_tilde(Y.l,T.l,X.l,m,alpha_hat,gamma_hat) # without subtracting theta_hat
    }
    Psi_tilde=c(Psi_tilde,Psi_tilde.l)
    
    #print(paste0('theta_hat: '))
    #print(paste0(round(mean(Psi_tilde.l),2)))
    
  }
  
  #point estimation
  ate=mean(Psi_tilde)
  
  #influences
  Psi=Psi_tilde-ate
  
  var=mean(Psi^2)
  se=sqrt(var/n)
  
  out<-c(table(T)[[2]],table(T)[[1]],ate,se)
  
  return(out)
}

printer<-function(spec1){
  print(paste(" treated: ",spec1[1], " untreated: ", spec1[2], "   ATE:    ",round(spec1[3],2), "   SE:   ", round(spec1[4],2), sep=""))
}

for_tex<-function(spec1){
  print(paste(" & ",spec1[1], " & ", spec1[2], "   &    ",round(spec1[3],2), "   &   ", round(spec1[4],2), sep=""))
}