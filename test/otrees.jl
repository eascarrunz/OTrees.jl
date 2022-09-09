using Test
using OTrees

"""
Get the `i`th view in a node
"""
function OTrees.getview(o, i)
    viewi = o.lastview
    for _ in 1:i
        viewi = getfield(viewi, :next)
    end

    return viewi
end

"""
Check that the views between nodes `p` and `c` are reciprocally connected and in the expected order
"""
function check_link(tree, indp, indc, indvp, indvc)
    p = tree.nodes[indp]
    c = tree.nodes[indc]

    vp = getview(p, indvp)
    vc = getview(c, indvc)

    @test vp.node == p
    @test vc.node == c
    @test vp.out == vc
    @test vc.out == vp
end


"""
Check the structure of tree (2,3,(5,6)4)1;
"""
function check_6_node_tree(tree)
    check_link(tree, 1, 2, 1, 1)
    check_link(tree, 1, 3, 2, 1)
    check_link(tree, 1, 4, 3, 1)
    check_link(tree, 4, 5, 2, 1)
    check_link(tree, 4, 6, 3, 1)

    @test length(neighbours(tree.nodes[1])) == 3
    @test length(neighbours(tree.nodes[2])) == 1
    @test length(neighbours(tree.nodes[3])) == 1
    @test length(neighbours(tree.nodes[4])) == 3
    @test length(neighbours(tree.nodes[5])) == 1
    @test length(neighbours(tree.nodes[6])) == 1

    return nothing
end


@testset "Manual construction of trees" begin
    # Create a tree with five nodes and no internal structure
    tree = create_tree(6)

    #=
    The trees created with `create_tree` have these properties:
    1. All `ONode`s are unlinked from other `ONode`s -> `ONodes` have no neighbours
    2. All `ONode`s, except the anchor (#1 by default), have a "stem" `NodeView`
    3. "Stem" `NodeViews` are linked to a `NodeView` pointing to `nothing` instead of an `ONode` -> Stem views have one neighbour
    =#
    @test length(neighbours(tree.nodes[1])) == 0
    for o in tree.nodes[2:end]
        # Property 1
        @test length(neighbours(o)) == 0

        # Properties 2 and 3
        @test length(neighbours(o.lastview)) == 1
    end

    # Link up tree (2,3,(5,6)4)1;
    link!(tree.nodes[1], tree.nodes[2])
    link!(tree.nodes[1], tree.nodes[3])
    link!(tree.nodes[1], tree.nodes[4])
    link!(tree.nodes[4], tree.nodes[5])
    link!(tree.nodes[4], tree.nodes[6])
    
    check_6_node_tree(tree)
end


function node_order(vp::OTrees.NodeView, vec = Int[])
    push!(vec, vp.node.id)
    for vc in children(vp) 
        node_order(vc, vec)
    end

    return vec
end

function node_order(o::OTrees.ONode)
    vec = Int[]
    push!(vec, o.lastview.next.node.id)
    node_order(o.lastview.next.out, vec)
    for oc in children(o.lastview.next)
        node_order(oc, vec)
    end

    return vec
end


@testset "Construct symmetric trees" begin
    for r in 1:10
        tree = symmetric_tree(r)
        r -= 1
        N = muladd(4, 2^r, -2)
        @test all(node_order(tree.anchor) .== 1:N)
    end
end


@testset "Wikipedia reference strings" begin
    test_strings = (
        "(,,(,));",                                         # no nodes are named
        "(A,B,(C,D));",                                     # leaf nodes are named
        "(A,B,(C,D)E)F;",                                   # all nodes are named
        "(:0.1,:0.2,(:0.3,:0.4):0.5);",                     # all but root node have a distance to parent
        "(A:0.1,B:0.2,(C:0.3,D:0.4):0.5);",                 # distances and leaf names (popular)
        "(A:0.1,B:0.2,(C:0.3,D:0.4)E:0.5)F;",               # distances and all names
        "((B:0.2,(C:0.3,D:0.4)E:0.5)F:0.1)A;"               # a tree rooted on a leaf node (rare))
    )


    @testset "One tree per string" begin
        for test_string in test_strings
            tree = OTrees.read(test_string, OTree)
            @test test_string == OTrees.write(tree)
        end
    end


    @testset "Multiple trees in one string" begin
        trees = OTrees.read(join(test_strings))
        for (tree, test_string) in zip(trees, test_strings)
            @test test_string == OTrees.write(tree)
        end
    end


    # @testset "Root with branch length" begin
    #     test_string = "(A:0.1,B:0.2,(C:0.3,D:0.4)E:0.5)F:0.1;"

    #     @test_throws ErrorException OTrees.read(test_string)
    # end
end


@testset "Complex labels" begin
    test_strings = (
        # singly-quoted labels
        "('A':0.1,'B':0.2,('C':0.3,'D':0.4)'E':0.5)'F';",

        # doubly-quoted labels
        """("A":0.1,"B":0.2,("C":0.3,"D":0.4)"E":0.5)"F";""",
        
        # mix of label quoting styles
        """('A':0.1,"B":0.2,('C':0.3,D:0.4)E:0.5)"F";""",
        
        # with white space
        """("A 1":0.1,"B 2":0.2,("C 3":0.3,"D 4":0.4)"E 5":0.5)"F 6";""",

        # with parens, not necessarily matched
        """("A (1)":0.1,"B (2)":0.2,("C (3)":0.3,"D (4)":0.4)"E (5":0.5)"F 6)";""",
    )

    #TODO: Implement complex label tests for Newick functions
end
