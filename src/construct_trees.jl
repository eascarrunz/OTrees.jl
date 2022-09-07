function _add_node_with_stem!(treedata, i, labels)
    j = 2 * i - 3    # Index of the first view of the stem
    o = ONode(treedata.ND, i, labels[i])
    br = Branch{treedata.BD}()
    p = NodeView(j, o)
    c = NodeView(j + 1, nothing)

    o.lastview = p

    p.node = o
    # p.next = p
    setfield!(p, :next, p)
    p.out = c
    # p.branch = br
    setfield!(p, :branch, br)

    c.node = nothing
    # c.next = c
    setfield!(c, :next, c)
    c.out = p
    # c.branch = br
    setfield!(c, :branch, br)

    treedata.nodes[i] = o
    treedata.nodeviews[j] = p
    treedata.nodeviews[j+1] = c

    return nothing
end


"""
Create a tree object with unlinked nodes.

The number of nodes can be given as `N`. It is also possible to give the number `n` of outer nodes, or a taxon set with `n` taxa, and it will create the number of inner nodes appropriate for an unrooted binary tree.
"""
function create_tree(dtypes::NTuple{3,Type}, N, labels = string.(1:N))
    TD, ND, BD = dtypes # Tree data type, node data type, branch data type
    nv = nview(N=N)

    nodes = Vector{ONode{ND}}(undef, N)
    nodeviews = Vector{NodeView{ONode}}(undef, nv)

    treedata = (ND=ND, BD=BD, nodes=nodes, nodeviews=nodeviews)

    #=
    The node of index 1 is the anchor whith no stem.
    Nodes with a stem (two views) begin at index 2 and end at N.
    So for a node of index `i`, the view indices are `2 * i - 2` and `2 * i - 1`
    See `_add_node_with_stem!`
    =#
    nodes[begin] = ONode(ND, 1, first(labels))
    for i in 2:N
        _add_node_with_stem!(treedata, i, labels)
    end

    tree = OTree{TD}(nodes[begin], nodes, nodeviews)

    return tree
end

create_tree(N) = create_tree(DEFAULT_DTYPES, N)


function _bifurcate!(tree, p, ic, r)
    if r > 0
        for _ in 1:2
            ic += 1
            c = tree.nodes[ic]
            link!(p, c)
            ic = _bifurcate!(tree, c, ic, r - 1)
        end
    end

    return ic
end


"""
    symmetric_tree(r)

Create a fully symmetric unrooted bicentered tree of radius `r`.
"""
function symmetric_tree(dtypes::NTuple{3,Type}, r::Number)
    # N = 2 * (2 * (2^r) - 1)
    r -= 1
    N = muladd(4, 2^r, -2)
    tree = create_tree(dtypes, N)
    i = _bifurcate!(tree, tree.anchor, 1, r) + 1
    link!(tree.anchor, tree.nodes[i])

    _bifurcate!(tree, tree.nodes[i], i, r)

    return tree
end


symmetric_tree(r::Number) = symmetric_tree(DEFAULT_DTYPES, r)


function preprint(p::NodeView)
    println("Node #$(p.id) $(p.label): NodeView $(p.viewid)")

    for c in children(p)
        preprint(c)
    end

    return nothing
end


function preprint(tree::OTree)
    println("Node #$(tree.anchor.id) $(tree.anchor.label)")
    
    for c in neighbours(tree.anchor.lastview.next)
        preprint(c)
    end

    return nothing
end


function preprint(p)
    println("View #$(p.id) - Node #$(p.node.id)")

    for c in children(p)
        preprint(c)
    end

    return nothing
end

tree = create_tree(OTrees.DEFAULT_DTYPES, 5)


"""
Create a unrooted star tree.
"""
function star_tree(n)
    tree = create_tree(n)
    for c in tree.node[2:end]
        link!(tree.nodes[1], c)
    end

    return tree
end

