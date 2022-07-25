positive_part(x) = (x ≥ 0) * x


"""
    nnode(; n)

Return the number of nodes of an unrooted binary tree with `n` outer nodes.
"""
nnode(n) = positive_part(2 * n - 2)
# muladd(2, n, -2)
nnode(; nview) = positive_part((nview + 2) ÷ 2)
# muladd(0.5, nview, 1)


"""
    nview(; n)
    nview(; N)

Return the number of views of an unrooted binary tree with `n` outer nodes or `N` nodes (inner + outer).
"""
nview(n) = positive_part(4 * n - 6)
# muladd(4, n, -6)
nview(; N) = positive_part(2 * N - 2)
