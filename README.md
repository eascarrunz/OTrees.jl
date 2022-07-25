# OTrees

[![Build Status](https://github.com/eascarrunz/OTrees.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/eascarrunz/OTrees.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/eascarrunz/OTrees.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/eascarrunz/OTrees.jl)

> 🚧 Work in progress

This package implements a tree data structure that is "unrooted", but also "rooted" at the same time. Nodes have *views*, one coming from each neighbour. The node views represent the root of a subtree.

This kind of data structure is useful for phylogenetic maximum likelihood algorithms and branch swapping economies (Felsenstein 2004, p. 589). Very similar data structures are used in Phylip and the Phylogenetic Likelihood Library used in RAxML. However, the data structure is complex, and difficult to use in interactive programming. The goal here is give an interface that takes care of the most fiddly bits for the user. Traversing the tree is made easier with iterators for neighbour and children nodes.

## References

Felsenstein. Inferring Phylogenies. 1st ed. Sunderland, Massachusetts, USA: Sinauer Associates, Inc, 2004.
