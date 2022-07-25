"""
    brlength(node1, node2)
    brlength(nodeview)

Get the length of a branch between two nodes, or of a node view.
"""
brlength(nv::NodeView) = nv.branch.length
brlength(o1::ONode, o2::ONode) = brlength(getview(o1, o2))


"""
    brlength!(node1, node2, x)
    brlength!(nodeview, x)

Set the length of a branch between two nodes, or of a node view.
"""
function brlength!(nv::NodeView, x)
    nv.branch.length = x

    return x
end


"""
    brlabel(node1, node2)
    brlabel(nodeview)

Get the label of a branch between two nodes, or the branch of a node view.
"""
brlabel(nv::NodeView) = nv.branch.label
brlabel(o1::ONode, o2::ONode) = brlabel(getview(o1, o2))


"""
    brlabel!(node1, node2, x)
    brlabel!(nodeview, x)

Set the label of a branch between two nodes, or the branch of a node view.
"""
function brlabel(nv::NodeView, x)
    nv.branch.label = x

    return x
end
