\l C:/developer/download/optionpricing-master/q/rand.q
\l C:/developer/download/optionpricing-master/q/norm.q

//function bsEuroCall, bsAsiaCall; original source code from https://code.kx.com/q/wp/option-pricing/

/ European
bsEuroCall:{[pd]
  / Calculate volatility*sqrt delta T coefficient
  coeff:(v:pd`v)*sqrt t:pd`t;
  / Calculate d1
  d1:(log[pd[`s]%pd`k]+t*(pd[`r]-pd`q)+.5*v*v)%coeff;
  / Calculate d2
  d2:d1-coeff;
  / Calculate the option price - P(S,t)
  (pd[`s]*exp[neg t*pd`q]*cnorm1 d1) -
    pd[`k]*exp[neg t*pd`r]*cnorm1 d2 }

/ Asian
bsAsiaCall:{[n;pd]
  / Calculate adjusted drift rate
  adjmu:.5*((r:pd`r)-.5*v2:v*v:pd`v)*n1:1+1.%n;
  / Calculate adjusted volatility squared
  adjv2:(v2%3)*n1*1+.5%n;
  / Calculate adjusted price
  adjS :pd[`s]*exp(t:pd`t)*(hv2:.5*adjv2)+adjmu-r;
  / Calculate d1
  d1:(log[adjS%k:pd`k]+t*(r-q:pd`q)+hv2)%rtv2:sqrt adjv2*t;
  / Calculate d2
  d2:d1-rtv2;
  / Calculate the option price - P(S,t)
  (adjS*exp[neg q*t]*cnorm1 d1)-k*exp[neg r*t]*cnorm1 d2 }

//function bsEuroCall, bsAsiaCall; original source code from https://code.kx.com/q/wp/option-pricing/

k:100+til 20
nsteps:512   

x1:{pd:`s`v`r`q`t!100 .2 .03 0 1; pd[`k]:"f"$x ; pd} each k
x2:{pd:`s`v`r`q`t!100 .2 .05 0 1; pd[`k]:"f"$x ; pd} each k
x3:{pd:`s`v`r`q`t!100 .2 .08 0 1; pd[`k]:"f"$x ; pd} each k

p1_eu: {bseuro:bsEuroCall x} each x1
p2_eu: {bseuro:bsEuroCall x} each x2
p3_eu: {bseuro:bsEuroCall x} each x3
p1_as: {bseuro:bsAsiaCall[nsteps]x} each x1
p2_as: {bseuro:bsAsiaCall[nsteps]x} each x2
p3_as: {bseuro:bsAsiaCall[nsteps]x} each x3

t1_eu:([]K:k;Price:p1_eu)
t2_eu:([]K:k;Price:p2_eu)
t3_eu:([]K:k;Price:p3_eu)
t1_as:([]K:k;Price:p1_as)
t2_as:([]K:k;Price:p2_as)
t3_as:([]K:k;Price:p3_as)

.qp.go[800;400]
    .qp.title["European Call Price: Spot price=100, Volatility=0.2, Interest rate=[0.03,0.05,0.08]"]
    .qp.stack (
        .qp.line[t1_eu; `K; `Price]
            .qp.s.geom[``fill`size!(::;`black;1)]
            , .qp.s.legend["legend"; `r0.03`r0.05`r0.08!(`black;`red;`blue)];     
        .qp.line[t2_eu; `K; `Price]
            .qp.s.geom[``fill`size!(::;`red;1)];
        .qp.line[t3_eu; `K; `Price]
            .qp.s.geom[``fill`size!(::;`blue;1)])

.qp.go[800;400]
    .qp.title["Asian Call Price: Spot price=100, Volatility=0.2, Interest rate=[0.03,0.05,0.08]"]
    .qp.stack (
        .qp.line[t1_as; `K; `Price]
            .qp.s.geom[``fill`size!(::;`black;1)]
            , .qp.s.legend["legend"; `r0.03`r0.05`r0.08!(`black;`red;`blue)];      
        .qp.line[t2_as; `K; `Price]
            .qp.s.geom[``fill`size!(::;`red;1)];
        .qp.line[t3_as; `K; `Price]
            .qp.s.geom[``fill`size!(::;`blue;1)])
