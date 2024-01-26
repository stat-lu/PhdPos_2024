## I you haven't yet installed the INLA package, run
##   install.packages('INLA', repos='https://inla.r-inla-download.org/R/stable')
## or
##   install.packages('INLA', repos='https://inla.r-inla-download.org/R/testing')
## See http://r-inla.org/download/ for more information.

library("INLA")
library("excursions")
library("fields")
library("RColorBrewer")
library("splancs")

seed <- 1
exc.seed <- 123
set.seed(seed)

x <- seq(from = 0, to = 10, length.out = 20)
mesh <- inla.mesh.create(lattice = inla.mesh.lattice(x = x, y = x), extend = FALSE,
  refine = FALSE)
spde <- inla.spde2.matern(mesh, alpha = 2)
obs.loc <- 10 * cbind(runif(100), runif(100))
Q <- inla.spde2.precision(spde, theta = c(log(sqrt(0.5)), 0))
x <- inla.qsample(Q = Q, seed = seed)

A <- inla.spde.make.A(mesh = mesh, loc = obs.loc)
sigma2.e <- 0.01
Y <- as.vector(A %*% x + rnorm(100) * sqrt(sigma2.e))
Q.post <- (Q + (t(A) %*% A)/sigma2.e)
mu.post <- as.vector(solve(Q.post, (t(A) %*% Y)/sigma2.e))

cmap <- colorRampPalette(brewer.pal(9, "YlGnBu"))(100)
proj <- inla.mesh.projector(mesh, dims = c(100, 100))
image.plot(proj$x, proj$y, inla.mesh.project(proj, field = mu.post), col = cmap, axes = FALSE,
  xlab = "", ylab = "", asp = 1)
points(obs.loc[, 1], obs.loc[, 2])

sd.post <- diag(inla.qinv(Q.post))
cmap.sd <- colorRampPalette(brewer.pal(9, "Reds"))(100)
jpeg("sd.jpeg", bg = "transparent")
image.plot(proj$x, proj$y, inla.mesh.project(proj, field = sd.post), col = cmap.sd, axes = FALSE,
  xlab = "", ylab = "", asp = 1)
points(obs.loc[, 1], obs.loc[, 2])
dev.off()
